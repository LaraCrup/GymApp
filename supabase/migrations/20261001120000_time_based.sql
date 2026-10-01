-- Ejercicios por tiempo (plancha, bicicleta…): cada serie dura X segundos en vez de X repeticiones.
--   seconds = null   → por repeticiones (reps con número) o al fallo (reps también null)
--   seconds con número → por tiempo; reps queda vacío
alter table public.routine_exercises
  add column seconds smallint check (seconds between 1 and 3600),
  add constraint routine_exercises_reps_or_seconds check (reps is null or seconds is null);

comment on column public.routine_exercises.seconds is 'Segundos por serie (ejercicio por tiempo). null = por repeticiones.';
