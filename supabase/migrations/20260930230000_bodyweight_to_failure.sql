-- Ejercicios sin peso (peso corporal) y sin número fijo de repeticiones (al fallo).
-- Vacío (null) tiene un significado propio, distinto de 0:
--   reps = null      → al fallo
--   weight_kg = null → peso corporal
-- Los checks existentes (reps 1–100, peso 0–999) siguen valiendo cuando hay número.
alter table public.routine_exercises
  alter column reps drop not null,
  alter column weight_kg drop not null;

comment on column public.routine_exercises.reps is 'Repeticiones por serie. null = al fallo.';
comment on column public.routine_exercises.weight_kg is 'Peso en kg. null = peso corporal.';

-- El historial solo guarda pesos reales: peso corporal (null) no entra, igual que 0.
create or replace function public.log_weight_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Peso 0 al agregar = "todavía no lo cargué"; null = peso corporal. Ninguno ensucia el gráfico.
  if new.weight_kg is null or new.weight_kg <= 0 then
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
