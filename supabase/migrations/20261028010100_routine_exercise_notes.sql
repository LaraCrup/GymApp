-- Nota libre en el ejercicio de una rutina: lo que no entra en series, reps, tiempo ni peso.
-- Por ejemplo «30 m por serie», «inclinación 10-12%, 5-5,5 km/h», «bajando en 3 segundos»,
-- «una serie por minuto» o «8 por lado». No es el por qué del ejercicio: son datos de la serie.
-- null = sin nota. El check pide texto de verdad: la app manda null cuando el campo queda vacío.
alter table public.routine_exercises
  add column notes text check (char_length(btrim(notes)) between 1 and 200);

comment on column public.routine_exercises.notes is 'Nota libre (medidas, ritmo, aclaraciones). null = sin nota.';
