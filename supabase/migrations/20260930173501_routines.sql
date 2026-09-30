-- Rutinas personales: cada persona ve y edita solo las suyas.

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ── Rutinas ─────────────────────────────────────────────────────────────────
create table public.routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 60),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index routines_user_idx on public.routines (user_id, created_at);

create trigger routines_touch_updated_at
before update on public.routines
for each row execute function public.touch_updated_at();

-- ── Ejercicios dentro de una rutina ────────────────────────────────────────
create table public.routine_exercises (
  id uuid primary key default gen_random_uuid(),
  routine_id uuid not null references public.routines (id) on delete cascade,
  -- restrict: no se puede borrar del catálogo un ejercicio que alguien usa.
  exercise_id uuid not null references public.exercises (id) on delete restrict,
  -- Copia del dueño de la rutina: RLS simple y rápido sin subconsultas en cada lectura.
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  -- 0 = "al final": lo resuelve el trigger al insertar.
  position integer not null default 0,
  sets smallint not null default 3 check (sets between 1 and 20),
  reps smallint not null default 10 check (reps between 1 and 100),
  weight_kg numeric(5, 2) not null default 0 check (weight_kg between 0 and 999),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (routine_id, exercise_id)
);

create index routine_exercises_routine_idx on public.routine_exercises (routine_id, position);
create index routine_exercises_exercise_idx on public.routine_exercises (exercise_id);

-- Al agregar sin posición (0), va al final de la rutina.
create or replace function public.routine_exercises_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.position <= 0 then
    select coalesce(max(position), 0) + 1 into new.position
    from public.routine_exercises
    where routine_id = new.routine_id;
  end if;
  return new;
end;
$$;

create trigger routine_exercises_before_insert
before insert on public.routine_exercises
for each row execute function public.routine_exercises_before_insert();

create trigger routine_exercises_touch_updated_at
before update on public.routine_exercises
for each row execute function public.touch_updated_at();

-- Reordenar todos los ejercicios de una rutina en una sola transacción.
-- p_ids: los ids en el orden nuevo. RLS garantiza que solo se toque lo propio.
create or replace function public.reorder_routine_exercises(p_routine_id uuid, p_ids uuid[])
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if (select count(*) from public.routine_exercises where routine_id = p_routine_id)
     <> coalesce(array_length(p_ids, 1), 0) then
    raise exception 'La lista no coincide con los ejercicios de la rutina' using errcode = '22023';
  end if;

  update public.routine_exercises re
  set position = t.ord
  from unnest(p_ids) with ordinality as t (id, ord)
  where re.id = t.id and re.routine_id = p_routine_id;
end;
$$;

-- ── Permisos ────────────────────────────────────────────────────────────────
alter table public.routines enable row level security;
alter table public.routine_exercises enable row level security;

revoke all on public.routines, public.routine_exercises from anon;

create policy "Cada persona ve sus rutinas"
on public.routines for select to authenticated
using (user_id = (select auth.uid()));

create policy "Cada persona crea sus rutinas"
on public.routines for insert to authenticated
with check (user_id = (select auth.uid()));

create policy "Cada persona edita sus rutinas"
on public.routines for update to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

create policy "Cada persona borra sus rutinas"
on public.routines for delete to authenticated
using (user_id = (select auth.uid()));

create policy "Cada persona ve los ejercicios de sus rutinas"
on public.routine_exercises for select to authenticated
using (user_id = (select auth.uid()));

-- Además de ser suyo, la rutina de destino tiene que ser suya.
create policy "Cada persona agrega ejercicios a sus rutinas"
on public.routine_exercises for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (select 1 from public.routines r where r.id = routine_id and r.user_id = (select auth.uid()))
);

create policy "Cada persona edita los ejercicios de sus rutinas"
on public.routine_exercises for update to authenticated
using (user_id = (select auth.uid()))
with check (
  user_id = (select auth.uid())
  and exists (select 1 from public.routines r where r.id = routine_id and r.user_id = (select auth.uid()))
);

create policy "Cada persona quita ejercicios de sus rutinas"
on public.routine_exercises for delete to authenticated
using (user_id = (select auth.uid()));

revoke execute on function public.reorder_routine_exercises(uuid, uuid[]) from public, anon;
grant execute on function public.reorder_routine_exercises(uuid, uuid[]) to authenticated;
