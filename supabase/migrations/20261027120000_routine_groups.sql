-- Grupos de rutinas ("carpetas"): «Gimnasio», «Casa», «Verano 2026»…
-- Una rutina está en un grupo o en ninguno (group_id = null → «Sin grupo»).
-- Borrar un grupo no borra sus rutinas: quedan sin grupo.

create table public.routine_groups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 60),
  -- 0 = "al final": lo resuelve el trigger al insertar.
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index routine_groups_user_idx on public.routine_groups (user_id, position);

-- Al crear un grupo sin posición (0), va al final de la lista.
create or replace function public.routine_groups_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.position <= 0 then
    select coalesce(max(position), 0) + 1 into new.position
    from public.routine_groups
    where user_id = new.user_id;
  end if;
  return new;
end;
$$;

create trigger routine_groups_before_insert
before insert on public.routine_groups
for each row execute function public.routine_groups_before_insert();

create trigger routine_groups_touch_updated_at
before update on public.routine_groups
for each row execute function public.touch_updated_at();

-- ── La rutina pasa a saber en qué grupo está ────────────────────────────────
alter table public.routines
  add column group_id uuid references public.routine_groups (id) on delete set null;

comment on column public.routines.group_id is 'Grupo ("carpeta") al que pertenece. null = sin grupo.';

create index routines_group_idx on public.routines (user_id, group_id, created_at);

-- Reordenar todos los grupos de la persona en una sola transacción.
-- p_ids: los ids en el orden nuevo. RLS garantiza que solo se toque lo propio.
create or replace function public.reorder_routine_groups(p_ids uuid[])
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if (select count(*) from public.routine_groups) <> coalesce(array_length(p_ids, 1), 0) then
    raise exception 'La lista no coincide con tus grupos' using errcode = '22023';
  end if;

  update public.routine_groups g
  set position = t.ord
  from unnest(p_ids) with ordinality as t (id, ord)
  where g.id = t.id;
end;
$$;

-- ── Permisos ────────────────────────────────────────────────────────────────
alter table public.routine_groups enable row level security;

revoke all on public.routine_groups from anon;

create policy "Cada persona ve sus grupos"
on public.routine_groups for select to authenticated
using (user_id = (select auth.uid()));

create policy "Cada persona crea sus grupos"
on public.routine_groups for insert to authenticated
with check (user_id = (select auth.uid()));

create policy "Cada persona edita sus grupos"
on public.routine_groups for update to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

create policy "Cada persona borra sus grupos"
on public.routine_groups for delete to authenticated
using (user_id = (select auth.uid()));

revoke execute on function public.reorder_routine_groups(uuid[]) from public, anon;
grant execute on function public.reorder_routine_groups(uuid[]) to authenticated;

-- Además de ser suya, el grupo de destino tiene que ser suyo.
drop policy "Cada persona crea sus rutinas" on public.routines;
create policy "Cada persona crea sus rutinas"
on public.routines for insert to authenticated
with check (
  user_id = (select auth.uid())
  and (
    group_id is null
    or exists (select 1 from public.routine_groups g where g.id = group_id and g.user_id = (select auth.uid()))
  )
);

drop policy "Cada persona edita sus rutinas" on public.routines;
create policy "Cada persona edita sus rutinas"
on public.routines for update to authenticated
using (user_id = (select auth.uid()))
with check (
  user_id = (select auth.uid())
  and (
    group_id is null
    or exists (select 1 from public.routine_groups g where g.id = group_id and g.user_id = (select auth.uid()))
  )
);
