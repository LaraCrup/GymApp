begin;
select plan(14);

insert into auth.users (id, email) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ana@ejemplo.test'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'beto@ejemplo.test');

-- ── Ana ordena sus rutinas en grupos ────────────────────────────────────────
set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';

insert into public.routine_groups (id, name) values
  ('30000000-0000-0000-0000-000000000001', 'Gimnasio'),
  ('30000000-0000-0000-0000-000000000002', 'Casa');

select is(
  (select user_id from public.routine_groups where name = 'Gimnasio'),
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
  'el grupo queda a nombre de quien lo crea'
);
select is(
  (select array_agg(name order by position) from public.routine_groups),
  '{Gimnasio,Casa}'::text[],
  'cada grupo nuevo va al final'
);

insert into public.routines (id, name, group_id) values
  ('10000000-0000-0000-0000-000000000001', 'Día 1 - Piernas', '30000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000002', 'Movilidad', null);

select is(
  (select group_id from public.routines where name = 'Día 1 - Piernas'),
  '30000000-0000-0000-0000-000000000001'::uuid,
  'la rutina queda en el grupo que se le puso'
);
select throws_ok(
  $$ insert into public.routine_groups (name) values ('   ') $$,
  '23514', null, 'no acepta un grupo sin nombre'
);

-- Reordenar
select lives_ok(
  $$ select public.reorder_routine_groups(
       (select array_agg(id order by position desc) from public.routine_groups)) $$,
  'reordenar funciona'
);
select is(
  (select array_agg(name order by position) from public.routine_groups),
  '{Casa,Gimnasio}'::text[],
  'el orden nuevo queda guardado'
);
select throws_ok(
  $$ select public.reorder_routine_groups(
       (select array_agg(id) from (select id from public.routine_groups limit 1) g)) $$,
  '22023', null, 'reordenar con una lista incompleta falla sin tocar nada'
);

-- ── Beto no puede ver ni tocar los grupos de Ana ────────────────────────────
set local request.jwt.claims = '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated","app_metadata":{}}';

select is((select count(*)::int from public.routine_groups), 0, 'Beto no ve los grupos de Ana');

update public.routine_groups set name = 'Hackeado';
delete from public.routine_groups;
select public.reorder_routine_groups('{}');

select throws_ok(
  $$ insert into public.routine_groups (name, user_id) values ('Trucho', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') $$,
  '42501', null, 'Beto no puede crear grupos a nombre de Ana'
);

-- Con una rutina propia, tampoco puede meterla en un grupo de Ana.
insert into public.routines (id, name) values ('20000000-0000-0000-0000-000000000002', 'Rutina de Beto');
select throws_ok(
  $$ update public.routines set group_id = '30000000-0000-0000-0000-000000000001' $$,
  '42501', null, 'Beto no puede mover su rutina a un grupo de Ana'
);
select throws_ok(
  $$ insert into public.routines (name, group_id)
     values ('Otra de Beto', '30000000-0000-0000-0000-000000000001') $$,
  '42501', null, 'ni crear una rutina dentro de un grupo de Ana'
);

-- ── De vuelta como Ana: todo intacto ────────────────────────────────────────
set local request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{}}';
select is(
  (select array_agg(name order by position) from public.routine_groups),
  '{Casa,Gimnasio}'::text[],
  'lo que intentó Beto no cambió nada'
);

-- ── Borrar un grupo no borra sus rutinas: quedan sin grupo ──────────────────
delete from public.routine_groups where id = '30000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.routines), 2, 'borrar un grupo no borra sus rutinas');
select is(
  (select group_id from public.routines where name = 'Día 1 - Piernas'),
  null, 'sus rutinas quedan sin grupo'
);

select * from finish();
rollback;
