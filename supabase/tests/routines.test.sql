begin;
select plan(21);

insert into auth.users (id, email) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ana@ejemplo.test'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'beto@ejemplo.test');

-- ── Ana arma su rutina ──────────────────────────────────────────────────────
set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';

insert into public.routines (id, name) values ('10000000-0000-0000-0000-000000000001', 'Día 1 - Piernas');
select is((select user_id from public.routines), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'la rutina queda a nombre de quien la crea');

insert into public.routine_exercises (routine_id, exercise_id)
select '10000000-0000-0000-0000-000000000001', id from public.exercises where name = 'Sentadilla con barra';
insert into public.routine_exercises (routine_id, exercise_id, sets, reps, weight_kg)
select '10000000-0000-0000-0000-000000000001', id, 4, 12, 37.5 from public.exercises where name = 'Prensa de piernas';
insert into public.routine_exercises (routine_id, exercise_id)
select '10000000-0000-0000-0000-000000000001', id from public.exercises where name = 'Camilla de femorales';

select is(
  (select array_agg(e.name order by re.position) from public.routine_exercises re join public.exercises e on e.id = re.exercise_id),
  '{"Sentadilla con barra","Prensa de piernas","Camilla de femorales"}'::text[],
  'cada ejercicio nuevo va al final'
);
select is(
  (select row(sets, reps, weight_kg)::text from public.routine_exercises re join public.exercises e on e.id = re.exercise_id where e.name = 'Sentadilla con barra'),
  '(3,10,0.00)', 'valores por defecto: 3 series × 10 reps, 0 kg'
);
select is(
  (select weight_kg from public.routine_exercises re join public.exercises e on e.id = re.exercise_id where e.name = 'Prensa de piernas'),
  37.50::numeric, 'guarda pesos con decimales (37,5 kg)'
);
select throws_ok(
  $$ insert into public.routine_exercises (routine_id, exercise_id)
     select '10000000-0000-0000-0000-000000000001', id from public.exercises where name = 'Prensa de piernas' $$,
  '23505', null, 'no deja repetir el mismo ejercicio en una rutina'
);
select throws_ok(
  $$ update public.routine_exercises set weight_kg = -5 $$,
  '23514', null, 'no acepta pesos negativos'
);
select throws_ok(
  $$ update public.routine_exercises set sets = 0 $$,
  '23514', null, 'no acepta 0 series'
);

-- Reordenar
select lives_ok(
  $$ select public.reorder_routine_exercises('10000000-0000-0000-0000-000000000001', (
       select array_agg(re.id order by re.position desc) from public.routine_exercises re)) $$,
  'reordenar funciona'
);
select is(
  (select array_agg(e.name order by re.position) from public.routine_exercises re join public.exercises e on e.id = re.exercise_id),
  '{"Camilla de femorales","Prensa de piernas","Sentadilla con barra"}'::text[],
  'el orden nuevo queda guardado'
);
select throws_ok(
  $$ select public.reorder_routine_exercises('10000000-0000-0000-0000-000000000001', (
       select array_agg(re.id) from (select id from public.routine_exercises limit 2) re)) $$,
  '22023', null, 'reordenar con una lista incompleta falla sin tocar nada'
);

-- ── Beto no puede ver ni tocar nada de Ana ──────────────────────────────────
set local request.jwt.claims = '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated","app_metadata":{}}';

select is((select count(*)::int from public.routines), 0, 'Beto no ve las rutinas de Ana');
select is((select count(*)::int from public.routine_exercises), 0, 'ni sus ejercicios');

update public.routines set name = 'Hackeada';
delete from public.routines;
update public.routine_exercises set weight_kg = 999;
delete from public.routine_exercises;
select public.reorder_routine_exercises('10000000-0000-0000-0000-000000000001', '{}');

select throws_ok(
  $$ insert into public.routine_exercises (routine_id, exercise_id)
     select '10000000-0000-0000-0000-000000000001', id from public.exercises where name = 'Plancha' $$,
  '42501', null, 'Beto no puede meter ejercicios en la rutina de Ana'
);
select throws_ok(
  $$ insert into public.routines (name, user_id) values ('Trucha', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') $$,
  '42501', null, 'Beto no puede crear rutinas a nombre de Ana'
);

-- Beto con su propia rutina tampoco puede mover un ejercicio suyo a la rutina de Ana.
insert into public.routines (id, name) values ('20000000-0000-0000-0000-000000000002', 'Rutina de Beto');
insert into public.routine_exercises (routine_id, exercise_id)
select '20000000-0000-0000-0000-000000000002', id from public.exercises where name = 'Plancha';
select throws_ok(
  $$ update public.routine_exercises set routine_id = '10000000-0000-0000-0000-000000000001' $$,
  '42501', null, 'Beto no puede mover un ejercicio suyo a una rutina de Ana'
);

-- ── De vuelta como Ana: todo intacto ────────────────────────────────────────
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';
select is((select name from public.routines), 'Día 1 - Piernas', 'lo que intentó Beto no cambió nada');
select is((select count(*)::int from public.routine_exercises), 3, 'Ana sigue teniendo sus 3 ejercicios');
select is((select max(weight_kg) from public.routine_exercises), 37.50::numeric, 'y sus pesos');

-- ── Catálogo: el admin no puede borrar un ejercicio que alguien usa ──────────
set local request.jwt.claims = '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated","app_metadata":{"is_admin":true}}';
select throws_ok(
  $$ delete from public.exercises where name = 'Prensa de piernas' $$,
  '23503', null, 'no se borra del catálogo un ejercicio que está en una rutina'
);

-- ── Borrar la rutina se lleva sus ejercicios ────────────────────────────────
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';
delete from public.routines where id = '10000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.routines), 0, 'Ana borra su rutina');
reset role;
select is(
  (select count(*)::int from public.routine_exercises where routine_id = '10000000-0000-0000-0000-000000000001'),
  0, 'y se borran sus ejercicios'
);

select * from finish();
rollback;
