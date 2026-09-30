-- Historial de pesos: un punto por día, por persona y ejercicio (no por rutina).
-- Así, si el mismo ejercicio está en dos rutinas, se ve una sola progresión,
-- y borrar una rutina no borra el historial.

create table public.weight_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  -- restrict: el catálogo no puede borrar un ejercicio con historial de alguien.
  exercise_id uuid not null references public.exercises (id) on delete restrict,
  routine_exercise_id uuid references public.routine_exercises (id) on delete set null,
  weight_kg numeric(5, 2) not null check (weight_kg between 0 and 999),
  logged_on date not null,
  updated_at timestamptz not null default now(),
  unique (user_id, exercise_id, logged_on)
);

create index weight_logs_exercise_idx on public.weight_logs (exercise_id);

-- Lo escribe la base, no el cliente: cada vez que cambia el peso de un ejercicio en una rutina.
-- Varios cambios el mismo día quedan como un solo punto (el último).
-- security definer: la tabla no tiene permiso de escritura para nadie más; el dueño ya lo
-- validó RLS al escribir en routine_exercises.
create or replace function public.log_weight_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Peso 0 al agregar = "todavía no lo cargué" (o peso corporal): no ensucia el gráfico.
  if new.weight_kg <= 0 then
    return new;
  end if;
  if tg_op = 'UPDATE' and new.weight_kg is not distinct from old.weight_kg then
    return new;
  end if;

  insert into public.weight_logs (user_id, exercise_id, routine_exercise_id, weight_kg, logged_on)
  values (
    new.user_id,
    new.exercise_id,
    new.id,
    new.weight_kg,
    (now() at time zone 'America/Argentina/Buenos_Aires')::date
  )
  on conflict (user_id, exercise_id, logged_on) do update
    set weight_kg = excluded.weight_kg,
        routine_exercise_id = excluded.routine_exercise_id,
        updated_at = now();

  return new;
end;
$$;

revoke execute on function public.log_weight_change() from public, anon, authenticated;

create trigger routine_exercises_log_weight
after insert or update of weight_kg on public.routine_exercises
for each row execute function public.log_weight_change();

-- El último peso de días anteriores, por ejercicio ("La vez anterior: 35 kg").
create or replace function public.previous_weights(p_exercise_ids uuid[])
returns table (exercise_id uuid, weight_kg numeric, logged_on date)
language sql
stable
security invoker
set search_path = ''
as $$
  select distinct on (w.exercise_id) w.exercise_id, w.weight_kg, w.logged_on
  from public.weight_logs w
  where w.exercise_id = any (p_exercise_ids)
    and w.user_id = (select auth.uid())
    and w.logged_on < (now() at time zone 'America/Argentina/Buenos_Aires')::date
  order by w.exercise_id, w.logged_on desc
$$;

-- ── Permisos ────────────────────────────────────────────────────────────────
alter table public.weight_logs enable row level security;

revoke all on public.weight_logs from anon;
revoke insert, update, delete on public.weight_logs from authenticated;

create policy "Cada persona ve su historial"
on public.weight_logs for select to authenticated
using (user_id = (select auth.uid()));

revoke execute on function public.previous_weights(uuid[]) from public, anon;
grant execute on function public.previous_weights(uuid[]) to authenticated;
