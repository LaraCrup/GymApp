begin;
select plan(26);

-- Dos usuarios de prueba: una persona común y el admin.
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'comun@ejemplo.test'),
  ('22222222-2222-2222-2222-222222222222', 'admin@ejemplo.test');

-- ── Normalización y seed ───────────────────────────────────────────────────
select is(public.normalize_text('Bíceps ÁÉÍÓÚ Ñandú'), 'biceps aeiou nandu', 'normaliza tildes y mayúsculas');
select ok((select count(*) from public.exercises) >= 50, 'el seed trae al menos 50 ejercicios');
select is(
  (select count(*)::int from public.muscle_groups g where not exists (select 1 from public.exercises e where e.muscle_group_id = g.id)),
  0, 'todos los grupos musculares tienen ejercicios'
);
select is((select count(*)::int from public.exercises where youtube_id is not null), 0, 'el seed no trae videos inventados');

-- ── Como persona común ───────────────────────────────────────────────────────
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated","app_metadata":{}}';

select ok((select count(*) from public.exercises) >= 50, 'una persona logueada ve el catálogo');
select is((select count(*)::int from public.muscle_groups), 11, 'y los 11 grupos musculares');

-- Búsqueda
select is((select name from public.search_exercises('remo inclinado') limit 1), 'Remo con barra', 'encuentra por alias');
select is((select name from public.search_exercises('Bent Over') limit 1), 'Remo con barra', 'encuentra por alias en inglés, sin importar mayúsculas');
select ok(exists (select 1 from public.search_exercises('biceps') where name = 'Curl de bíceps con barra'), 'encuentra sin tildes');
select ok(exists (select 1 from public.search_exercises('remo barra') where name = 'Remo con barra'), 'encuentra con palabras salteadas');
select ok(exists (select 1 from public.search_exercises('sentadiya') where name = 'Sentadilla con barra'), 'tolera errores de tipeo');
select is((select name from public.search_exercises('prensa') limit 1), 'Prensa de piernas', 'lo que empieza igual aparece primero');
select is(
  (select count(*)::int from public.search_exercises('', 'gemelos') where muscle_group_id <> 'gemelos'),
  0, 'el filtro por grupo muscular solo trae ese grupo'
);
select is(
  (select count(*) from public.search_exercises('')),
  (select count(*) from public.exercises), 'sin texto trae todo el catálogo, sin tope'
);
select is((select count(*)::int from public.search_exercises('xyzqwerty')), 0, 'algo que no existe no trae nada');

-- Parecidos (para evitar duplicados)
select ok(exists (select 1 from public.similar_exercises('Remo inclinado con barra') where name = 'Remo con barra'), 'avisa de un ejercicio parecido por nombre');
select ok(exists (select 1 from public.similar_exercises('Algo nuevo', '{"Serrucho"}') where name = 'Remo con mancuerna'), 'avisa de un parecido por alias');

-- Crear
insert into public.exercises (name, aliases, muscle_group_id)
values ('  Press   Arnold ', '{" Arnold press ","arnold PRESS","","Press Arnold"}', 'hombros');
select is((select name from public.exercises where name = 'Press Arnold'), 'Press Arnold', 'limpia espacios del nombre');
select is((select aliases from public.exercises where name = 'Press Arnold'), '{"Arnold press"}'::text[], 'limpia alias vacíos, repetidos e iguales al nombre');
select is(
  (select created_by from public.exercises where name = 'Press Arnold'),
  '11111111-1111-1111-1111-111111111111'::uuid, 'queda a nombre de quien lo creó'
);
select throws_ok(
  $$ insert into public.exercises (name, muscle_group_id) values ('REMO con barra', 'espalda') $$,
  '23505', null, 'no deja duplicar un nombre (mayúsculas y tildes aparte)'
);
select throws_ok(
  $$ insert into public.exercises (name, muscle_group_id, created_by) values ('Otro', 'espalda', '22222222-2222-2222-2222-222222222222') $$,
  '42501', null, 'no deja crear a nombre de otra persona'
);
select throws_ok(
  $$ insert into public.exercises (name, muscle_group_id, youtube_id) values ('Con video malo', 'espalda', 'https://youtu.be/x') $$,
  '23514', null, 'solo acepta IDs de YouTube válidos'
);

-- Una persona común no edita ni borra (RLS: 0 filas afectadas)
update public.exercises set name = 'Hackeado' where name = 'Remo con barra';
delete from public.exercises where name = 'Plancha';
select is(
  (select count(*)::int from public.exercises where name in ('Remo con barra', 'Plancha')),
  2, 'una persona común no puede editar ni borrar'
);

-- ── Como admin ───────────────────────────────────────────────────────────────
set local request.jwt.claims = '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated","app_metadata":{"is_admin":true}}';
update public.exercises set youtube_id = 'dQw4w9WgXcQ' where name = 'Remo con barra';
select is((select youtube_id from public.exercises where name = 'Remo con barra'), 'dQw4w9WgXcQ', 'el admin puede editar');
delete from public.exercises where name = 'Press Arnold';
select is((select count(*)::int from public.exercises where name = 'Press Arnold'), 0, 'el admin puede borrar');

select * from finish();
rollback;
