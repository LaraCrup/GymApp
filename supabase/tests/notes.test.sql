begin;
select plan(5);

insert into auth.users (id, email) values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ana@ejemplo.test');

set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';

insert into public.routines (id, name) values ('10000000-0000-0000-0000-000000000001', 'Día 1');

-- Un ejercicio arranca sin nota.
insert into public.routine_exercises (id, routine_id, exercise_id, sets, reps, weight_kg)
select '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', id, 3, 30, 20
from public.exercises where name = 'Dominadas';
select is(
  (select notes from public.routine_exercises where id = '30000000-0000-0000-0000-000000000001'),
  null, 'sin nota al agregar'
);

update public.routine_exercises
set notes = 'Son 30 metros por serie, no 30 repeticiones.'
where id = '30000000-0000-0000-0000-000000000001';
select is(
  (select notes from public.routine_exercises where id = '30000000-0000-0000-0000-000000000001'),
  'Son 30 metros por serie, no 30 repeticiones.', 'se puede guardar una nota'
);

-- Sacarla es volver a vacío: es lo que manda la app cuando se borra el texto.
update public.routine_exercises set notes = null where id = '30000000-0000-0000-0000-000000000001';
select is(
  (select notes from public.routine_exercises where id = '30000000-0000-0000-0000-000000000001'),
  null, 'se puede sacar la nota'
);

-- Una nota en blanco es lo mismo que no tenerla: se guarda null, no ''.
select throws_ok(
  $$ update public.routine_exercises set notes = '   ' where id = '30000000-0000-0000-0000-000000000001' $$,
  '23514', null, 'una nota en blanco no vale'
);
select throws_ok(
  format(
    $$ update public.routine_exercises set notes = %L where id = '30000000-0000-0000-0000-000000000001' $$,
    repeat('a', 201)
  ),
  '23514', null, 'una nota de más de 200 caracteres no vale'
);

select * from finish();
rollback;
