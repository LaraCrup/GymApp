-- Catálogo compartido de ejercicios: grupos musculares, ejercicios con alias y video de YouTube.

create extension if not exists pg_trgm with schema extensions;
create extension if not exists unaccent with schema extensions;

-- Minúsculas y sin tildes, para buscar "biceps" y encontrar "Bíceps".
-- unaccent con diccionario explícito es inmutable en la práctica y se puede usar en índices.
create or replace function public.normalize_text(t text)
returns text
language sql
immutable
parallel safe
set search_path = ''
as $$
  select lower(extensions.unaccent('extensions.unaccent'::regdictionary, coalesce(t, '')))
$$;

-- ── Grupos musculares (lista fija, se cambia solo por migración) ─────────────
create table public.muscle_groups (
  id text primary key,
  name text not null,
  sort_order smallint not null
);

insert into public.muscle_groups (id, name, sort_order) values
  ('pecho', 'Pecho', 1),
  ('espalda', 'Espalda', 2),
  ('hombros', 'Hombros', 3),
  ('biceps', 'Bíceps', 4),
  ('triceps', 'Tríceps', 5),
  ('cuadriceps', 'Cuádriceps', 6),
  ('femorales', 'Femorales', 7),
  ('gluteos', 'Glúteos', 8),
  ('gemelos', 'Gemelos', 9),
  ('abdominales', 'Abdominales', 10),
  ('cardio', 'Cardio', 11);

-- ── Ejercicios ───────────────────────────────────────────────────────────────
create table public.exercises (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 80),
  aliases text[] not null default '{}',
  muscle_group_id text not null references public.muscle_groups (id),
  -- Solo el ID de 11 caracteres; la URL se arma en la app con youtube-nocookie.
  youtube_id text check (youtube_id ~ '^[A-Za-z0-9_-]{11}$'),
  -- Nombre + alias normalizados. Lo mantiene el trigger; no se escribe a mano.
  search_text text not null default '',
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on column public.exercises.aliases is 'Otros nombres con los que se conoce el ejercicio en el gimnasio.';

-- Última barrera contra duplicados: "Remo con barra" y "remo con BARRA" son el mismo.
create unique index exercises_name_key on public.exercises (public.normalize_text(name));
create index exercises_search_trgm_idx on public.exercises using gin (search_text extensions.gin_trgm_ops);
create index exercises_muscle_group_idx on public.exercises (muscle_group_id);

create or replace function public.exercises_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.name := btrim(regexp_replace(new.name, '\s+', ' ', 'g'));

  -- Alias limpios: sin espacios de más, sin vacíos, sin repetidos y distintos del nombre.
  new.aliases := coalesce((
    select array_agg(a order by pos)
    from (
      select distinct on (public.normalize_text(a)) a, pos
      from (
        select btrim(regexp_replace(x, '\s+', ' ', 'g')) as a, pos
        from unnest(new.aliases) with ordinality as t (x, pos)
      ) raw
      where a <> '' and public.normalize_text(a) <> public.normalize_text(new.name)
      order by public.normalize_text(a), pos
    ) cleaned
  ), '{}');

  new.search_text := public.normalize_text(new.name || ' ' || array_to_string(new.aliases, ' '));

  if tg_op = 'UPDATE' then
    new.created_by := old.created_by;
    new.created_at := old.created_at;
    new.updated_at := now();
  end if;

  return new;
end;
$$;

create trigger exercises_before_write
before insert or update on public.exercises
for each row execute function public.exercises_before_write();

-- ── Búsqueda ────────────────────────────────────────────────────────────────
-- Encuentra por cualquier nombre o alias, sin importar tildes ni mayúsculas.
-- Cada palabra buscada tiene que aparecer ("remo barra" → "Remo con barra");
-- si nada coincide así, cae a parecido difuso para tolerar errores de tipeo ("sentadiya").
create or replace function public.search_exercises(
  q text default '',
  group_id text default null,
  max_results integer default 60
)
returns setof public.exercises
language sql
stable
security invoker
set search_path = ''
as $$
  with params as (
    select public.normalize_text(btrim(coalesce(q, ''))) as nq
  ),
  words as (
    select w from params, unnest(string_to_array(params.nq, ' ')) as w where w <> ''
  ),
  scored as (
    select
      e,
      p.nq,
      not exists (select 1 from words where strpos(e.search_text, words.w) = 0) as all_words,
      extensions.word_similarity(p.nq, e.search_text) as fuzzy
    from public.exercises e, params p
    where group_id is null or e.muscle_group_id = group_id
  )
  select (s.e).*
  from scored s
  where s.nq = ''
     or s.all_words
     -- Difuso solo si no hubo ninguna coincidencia exacta: "triceps" no tiene que traer "cuádriceps".
     or (s.fuzzy >= 0.45 and not exists (select 1 from scored x where x.all_words))
  order by
    case
      when s.nq = '' then 0
      when public.normalize_text((s.e).name) like s.nq || '%' then 0
      when s.all_words then 1
      else 2
    end,
    s.fuzzy desc,
    (s.e).name
  -- Sin texto se lista el catálogo entero; el tope es solo para búsquedas.
  limit (select case when nq = '' then null else greatest(1, least(coalesce(max_results, 60), 100)) end from params)
$$;

-- Antes de crear un ejercicio: ¿ya hay alguno con un nombre parecido?
-- Compara cada nombre propuesto contra el nombre y cada alias existentes, frase completa
-- (no palabra suelta: "Remo con mancuernas" no tiene que sugerir "Curl con mancuernas").
create or replace function public.similar_exercises(
  name text,
  aliases text[] default '{}'
)
returns table (id uuid, name text, aliases text[], muscle_group_id text, youtube_id text, score real)
language sql
stable
security invoker
set search_path = ''
as $$
  with terms as (
    select public.normalize_text(btrim(t)) as t
    from unnest(array_prepend(name, coalesce(aliases, '{}'))) as t
    where char_length(btrim(coalesce(t, ''))) >= 3
  ),
  candidates as (
    select e.id, public.normalize_text(c) as c
    from public.exercises e, unnest(array_prepend(e.name, e.aliases)) as c
  ),
  scores as (
    select candidates.id, max(extensions.similarity(terms.t, candidates.c)) as score
    from candidates cross join terms
    group by candidates.id
  )
  select e.id, e.name, e.aliases, e.muscle_group_id, e.youtube_id, scores.score
  from scores join public.exercises e on e.id = scores.id
  where scores.score >= 0.45
  order by scores.score desc, e.name
  limit 5
$$;

-- ── Permisos ────────────────────────────────────────────────────────────────
alter table public.muscle_groups enable row level security;
alter table public.exercises enable row level security;

revoke all on public.muscle_groups, public.exercises from anon;

create policy "Los usuarios logueados ven los grupos musculares"
on public.muscle_groups for select to authenticated
using (true);

create policy "Los usuarios logueados ven el catálogo"
on public.exercises for select to authenticated
using (true);

create policy "Los usuarios logueados agregan ejercicios a su nombre"
on public.exercises for insert to authenticated
with check (created_by = (select auth.uid()));

create policy "Solo el admin edita ejercicios"
on public.exercises for update to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy "Solo el admin borra ejercicios"
on public.exercises for delete to authenticated
using ((select public.is_admin()));

revoke execute on function public.search_exercises(text, text, integer) from public, anon;
revoke execute on function public.similar_exercises(text, text[]) from public, anon;
grant execute on function public.search_exercises(text, text, integer) to authenticated;
grant execute on function public.similar_exercises(text, text[]) to authenticated;
