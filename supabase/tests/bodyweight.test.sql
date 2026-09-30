begin;
select plan(6);

insert into auth.users (id, email) values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ana@ejemplo.test');

set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';

insert into public.routines (id, name) values ('10000000-0000-0000-0000-000000000001', 'Día 1');

-- Dominadas al fallo y con peso corporal: reps y peso vacíos.
insert into public.routine_exercises (id, routine_id, exercise_id, sets, reps, weight_kg)
select '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', id, 4, null, null
from public.exercises where name = 'Dominadas';
select is(
  (select row(sets, reps, weight_kg)::text from public.routine_exercises where id = '30000000-0000-0000-0000-000000000001'),
  '(4,,)', 'se puede guardar al fallo y con peso corporal'
);
select is((select count(*)::int from public.weight_logs), 0, 'peso corporal no entra al historial');

-- Pasar a usar peso lo registra; volver a peso corporal no borra ni agrega nada.
update public.routine_exercises set weight_kg = 10 where id = '30000000-0000-0000-0000-000000000001';
select is((select weight_kg from public.weight_logs), 10.00::numeric, 'agregarle peso lo registra');
update public.routine_exercises set weight_kg = null where id = '30000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.weight_logs), 1, 'volver a peso corporal conserva el historial');

-- Con número, los límites siguen valiendo.
select throws_ok(
  $$ update public.routine_exercises set reps = 0 where id = '30000000-0000-0000-0000-000000000001' $$,
  '23514', null, 'reps en 0 no vale (al fallo es vacío)'
);
select throws_ok(
  $$ update public.routine_exercises set weight_kg = -1 where id = '30000000-0000-0000-0000-000000000001' $$,
  '23514', null, 'peso negativo no vale'
);

select * from finish();
rollback;
