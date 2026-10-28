-- Carga de la rutina «NOVIEMBRE - FEBRERO» (3 días) para una persona concreta.
-- Son datos personales, no esquema: va como migración solo porque es la única vía a producción.
-- Se busca por email y, si ese usuario no existe (base local recién reseteada), no hace nada.
-- Si el grupo ya existe, tampoco: así `supabase db reset` no duplica nada.
do $$
declare
  v_user uuid;
  v_group uuid;
  v_lunes uuid;
  v_miercoles uuid;
  v_viernes uuid;
begin
  select id into v_user from auth.users where email = 'laracrupni@gmail.com';

  if v_user is null then
    raise notice 'Sin usuario laracrupni@gmail.com: no se carga la rutina NOVIEMBRE - FEBRERO';
    return;
  end if;

  if exists (
    select 1 from public.routine_groups
    where user_id = v_user and name = 'NOVIEMBRE - FEBRERO'
  ) then
    raise notice 'El grupo NOVIEMBRE - FEBRERO ya existe: no se carga de nuevo';
    return;
  end if;

  -- position 0 = al final de la lista; lo resuelve el trigger.
  insert into public.routine_groups (user_id, name, position)
  values (v_user, 'NOVIEMBRE - FEBRERO', 0)
  returning id into v_group;

  -- La app lista las rutinas por created_at, y dentro de una transacción now() no cambia:
  -- sin separarlas a mano, lunes/miércoles/viernes saldrían en cualquier orden.
  insert into public.routines (user_id, name, group_id, created_at, updated_at)
  values (v_user, 'LUNES: fuerza de piernas + dominada pesada', v_group,
          now() - interval '2 seconds', now() - interval '2 seconds')
  returning id into v_lunes;

  insert into public.routines (user_id, name, group_id, created_at, updated_at)
  values (v_user, 'MIÉRCOLES: tirón + hombro + core', v_group,
          now() - interval '1 second', now() - interval '1 second')
  returning id into v_miercoles;

  insert into public.routines (user_id, name, group_id, created_at, updated_at)
  values (v_user, 'VIERNES: potencia a una pierna + glúteo + dominada supina', v_group,
          now(), now())
  returning id into v_viernes;

  -- Los ejercicios se buscan por nombre en el catálogo (normalizado, como la búsqueda de la app).
  -- weight_kg null = peso corporal · 0 = todavía sin cargar · seconds con número = por tiempo.
  -- La nota guarda lo que no entra en esos campos (metros, pendiente, ritmo, «por lado»).
  insert into public.routine_exercises (routine_id, exercise_id, user_id, position, sets, reps, weight_kg, seconds, notes)
  select d.routine_id, e.id, v_user, d.position, d.sets, d.reps, d.weight_kg, d.seconds, d.notes
  from (values
    -- LUNES
    -- Los null de la primera fila llevan tipo: es de donde Postgres lo deduce para toda la lista.
    (v_lunes, 1, 'Saltos al cajón', 3, 4, null::numeric, null::smallint, null::text),
    (v_lunes, 2, 'Peso muerto con trap bar', 4, 5, 45, null, null),
    (v_lunes, 3, 'Dominadas con lastre', 4, 3, 0, null, null),
    (v_lunes, 4, 'Sentadilla búlgara', 3, 6, 15, null, null),
    (v_lunes, 5, 'Remo con mancuerna', 3, 10, 14, null, null),
    (v_lunes, 6, 'Elevación de talones sentado', 3, 12, 0, null, 'Pesada.'),
    (v_lunes, 7, 'Plancha lateral con elevación de pierna', 3, 8, null, null, '8 por lado.'),
    -- MIÉRCOLES
    (v_miercoles, 1, 'Dominadas', 5, 4, null, null, 'Sin llegar al fallo.'),
    (v_miercoles, 2, 'Press landmine a un brazo', 3, 8, 10, null, null),
    (v_miercoles, 3, 'Remo invertido en Smith', 3, 10, null, null, 'Cuanto más baja esté la barra, más difícil.'),
    (v_miercoles, 4, 'Jalón con brazos rectos en polea', 3, 12, 10, null, '10-15 kg.'),
    (v_miercoles, 5, 'Elevaciones en Y en banco inclinado', 3, 12, 2, null, '2-3 kg.'),
    (v_miercoles, 6, 'Hollow hold', 3, null, null, 25, null),
    (v_miercoles, 7, 'Cinta', 1, null, null, 720,
      '12 min de caminata · inclinación 10-12% · 5-5,5 km/h · pulso entre 118 y 138 ppm. '
      || 'Si te cansa las piernas: los mismos 12 min en bici fija, suave y con el mismo pulso.'),
    -- VIERNES
    (v_viernes, 1, 'Saltos laterales a una pierna', 3, 5, null, null, '5 por lado.'),
    (v_viernes, 2, 'Hip thrust', 4, 6, 90, null, null),
    (v_viernes, 3, 'Peso muerto rumano a una pierna', 3, 8, 12, null, null),
    (v_viernes, 4, 'Dominadas supinas', 3, 5, null, null, null),
    -- En el catálogo el curl femoral acostado se llama «Camilla de femorales».
    (v_viernes, 5, 'Camilla de femorales', 3, 8, 0, null, 'Bajando en 3 segundos.'),
    -- La app no tiene distancia: los 30 son metros, y la nota lo aclara.
    (v_viernes, 6, 'Paseo del granjero', 3, 30, 20, null, 'Son 30 metros por serie, no 30 repeticiones. 20 kg por mano.'),
    (v_viernes, 7, 'Swing con kettlebell', 6, 15, 16, null, 'Una serie por minuto.')
  ) as d (routine_id, position, name, sets, reps, weight_kg, seconds, notes)
  join public.exercises e on public.normalize_text(e.name) = public.normalize_text(d.name);

  -- Si algún nombre no estaba en el catálogo, el join lo saltea sin avisar: mejor fallar acá.
  if (select count(*) from public.routine_exercises where routine_id in (v_lunes, v_miercoles, v_viernes)) <> 21 then
    raise exception 'Faltan ejercicios del catálogo: se esperaban 21 y entraron %',
      (select count(*) from public.routine_exercises where routine_id in (v_lunes, v_miercoles, v_viernes));
  end if;
end $$;
