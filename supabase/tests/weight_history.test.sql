begin;
select plan(14);

insert into auth.users (id, email) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ana@ejemplo.test'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'beto@ejemplo.test');

create temp view today as select (now() at time zone 'America/Argentina/Buenos_Aires')::date as d;
grant select on today to authenticated;

set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';

insert into public.routines (id, name) values
  ('10000000-0000-0000-0000-000000000001', 'Día 1'),
  ('10000000-0000-0000-0000-000000000002', 'Día 2');

-- Agregar con 0 kg no registra nada; con peso sí.
insert into public.routine_exercises (id, routine_id, exercise_id)
select '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', id from public.exercises where name = 'Sentadilla con barra';
select is((select count(*)::int from public.weight_logs), 0, 'agregar con 0 kg no ensucia el historial');

insert into public.routine_exercises (id, routine_id, exercise_id, weight_kg)
select '30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', id, 50 from public.exercises where name = 'Prensa de piernas';
select is((select weight_kg from public.weight_logs), 50.00::numeric, 'agregar con peso lo registra');

-- Varios cambios el mismo día = un solo punto con el último valor.
update public.routine_exercises set weight_kg = 40 where id = '30000000-0000-0000-0000-000000000001';
update public.routine_exercises set weight_kg = 41 where id = '30000000-0000-0000-0000-000000000001';
update public.routine_exercises set weight_kg = 42.5 where id = '30000000-0000-0000-0000-000000000001';
select is(
  (select count(*)::int from public.weight_logs w join public.exercises e on e.id = w.exercise_id where e.name = 'Sentadilla con barra'),
  1, 'varios cambios en el día quedan como un solo punto'
);
select is(
  (select weight_kg from public.weight_logs w join public.exercises e on e.id = w.exercise_id where e.name = 'Sentadilla con barra'),
  42.50::numeric, 'y guarda el último peso del día'
);
select is((select logged_on from public.weight_logs limit 1), (select d from today), 'con la fecha de hoy en Argentina');

-- Cambiar series o reps no toca el historial.
update public.routine_exercises set sets = 5 where id = '30000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.weight_logs), 2, 'cambiar series no agrega registros');

-- El mismo ejercicio en otra rutina comparte la progresión.
insert into public.routine_exercises (routine_id, exercise_id, weight_kg)
select '10000000-0000-0000-0000-000000000002', id, 45 from public.exercises where name = 'Sentadilla con barra';
select is(
  (select count(*)::int from public.weight_logs w join public.exercises e on e.id = w.exercise_id where e.name = 'Sentadilla con barra'),
  1, 'el mismo ejercicio en dos rutinas es una sola progresión'
);

-- No se puede escribir el historial a mano.
select throws_ok(
  $$ insert into public.weight_logs (user_id, exercise_id, weight_kg, logged_on)
     select 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', id, 999, current_date from public.exercises limit 1 $$,
  '42501', null, 'no se puede inventar historial desde la app'
);

-- Días anteriores (se cargan como admin de la base para simular el pasado).
reset role;
insert into public.weight_logs (user_id, exercise_id, weight_kg, logged_on)
select 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', id, v.w, (select d from today) - v.days
from public.exercises, (values (30.0, 14), (35.0, 7)) as v (w, days)
where name = 'Sentadilla con barra';
set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';

select is(
  (select weight_kg from public.previous_weights(array(select id from public.exercises where name = 'Sentadilla con barra'))),
  35.00::numeric, '"la vez anterior" es el último peso antes de hoy'
);
select is(
  (select count(*)::int from public.previous_weights(array(select id from public.exercises where name = 'Prensa de piernas'))),
  0, 'sin días anteriores no hay "vez anterior"'
);

-- Borrar la rutina no borra el historial.
delete from public.routines;
select is((select count(*)::int from public.weight_logs), 4, 'borrar las rutinas conserva el historial');

-- ── Beto no ve el historial de Ana ─────────────────────────────────────────
set local request.jwt.claims = '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated","app_metadata":{"is_admin":true}}';
select is((select count(*)::int from public.weight_logs), 0, 'otra persona no ve el historial');
select is(
  (select count(*)::int from public.previous_weights(array(select id from public.exercises where name = 'Sentadilla con barra'))),
  0, 'ni por la función de "vez anterior"'
);
select throws_ok(
  $$ delete from public.exercises where name = 'Sentadilla con barra' $$,
  '23503', null, 'el admin no puede borrar un ejercicio con historial de alguien'
);

select * from finish();
rollback;
