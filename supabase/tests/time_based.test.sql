begin;
select plan(4);

insert into auth.users (id, email) values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ana@ejemplo.test');

set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';

insert into public.routines (id, name) values ('10000000-0000-0000-0000-000000000001', 'Día 1');

-- Plancha por tiempo: 3 series de 40 segundos, sin reps.
insert into public.routine_exercises (id, routine_id, exercise_id, sets, reps, seconds, weight_kg)
select '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', id, 3, null, 40, null
from public.exercises where name = 'Dominadas';
select is(
  (select row(sets, reps, seconds)::text from public.routine_exercises where id = '30000000-0000-0000-0000-000000000001'),
  '(3,,40)', 'se puede guardar por tiempo'
);

-- Volver a repeticiones: se vacían los segundos.
update public.routine_exercises set seconds = null, reps = 12 where id = '30000000-0000-0000-0000-000000000001';
select is(
  (select row(reps, seconds)::text from public.routine_exercises where id = '30000000-0000-0000-0000-000000000001'),
  '(12,)', 'se puede volver a repeticiones'
);

select throws_ok(
  $$ update public.routine_exercises set seconds = 30 where id = '30000000-0000-0000-0000-000000000001' $$,
  '23514', null, 'reps y segundos a la vez no vale'
);
select throws_ok(
  $$ update public.routine_exercises set reps = null, seconds = 0 where id = '30000000-0000-0000-0000-000000000001' $$,
  '23514', null, '0 segundos no vale'
);

select * from finish();
rollback;
