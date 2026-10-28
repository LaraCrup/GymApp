-- Más ejercicios para el catálogo: potencia, unilateral y agarre (fuerza para correr + dominadas).
-- Mismo criterio que el catálogo inicial: cada video salió de una búsqueda real en YouTube
-- (en español, corto, de técnica) y se verificó con el oEmbed público: el video existe y se
-- puede ver embebido. Los títulos se revisaron a mano.
-- `on conflict do nothing`: si alguien ya creó uno con el mismo nombre, se respeta el existente.
insert into public.exercises (name, aliases, muscle_group_id, youtube_id, created_by) values
  -- Potencia / pliometría
  ('Saltos al cajón', '{"Salto al cajón","Box jump"}', 'cuadriceps', 'XTkFsA-y290', null),
    -- «Como realizar correctamente los Box Jump o saltos al cajón» · Elesta CrossFit Illescas
  ('Saltos laterales a una pierna', '{"Salto lateral a una pierna","Lateral bound"}', 'cuadriceps', 'epDCWb0TfCg', null),
    -- «Saltos laterales a una pierna: Mejora la fuerza y estabilidad de tus pies en trail running» · Entrenamiento Secreto
  ('Swing con kettlebell', '{"Swing ruso","Kettlebell swing","Pesa rusa"}', 'gluteos', '8gGn_4bJgFs', null),
    -- «Kettlebell Swing Ruso y Americano (crossfit) - Técnica Correcta» · Dairo Davila

  -- Piernas y glúteo
  ('Peso muerto con trap bar', '{"Peso muerto con barra hexagonal","Trap bar deadlift"}', 'gluteos', 'ngwEa50dG00', null),
    -- «PESO MUERTO con barra HEXAGONAL: técnica SEGURA y potente» · Vitar Club
  ('Peso muerto rumano a una pierna', '{"Rumano a una pierna","Single leg RDL"}', 'femorales', '-2h7UPouOqc', null),
    -- «PESO MUERTO RUMANO a una PIERNA con MANCUERNAS (sin apoyo, en BANCO y CON APOYO)» · Healthy Fitness

  -- Tirón
  ('Dominadas con lastre', '{"Dominadas lastradas","Dominadas con peso","Weighted pull ups"}', 'espalda', 'YmPIrEhp2wU', null),
    -- «Dominadas lastradas con PowerExplosive» · Ejercicios en Casa
  ('Dominadas supinas', '{"Dominadas agarre supino","Chin ups"}', 'espalda', 'rfMaANCbzx8', null),
    -- «Cómo Hacer Dominadas Supinas Correctamente» · Your House Fitness
  ('Remo invertido en Smith', '{"Remo invertido","Inverted row"}', 'espalda', '1o6s7jl1TJM', null),
    -- «REMO INVERTIDO en la Jaula SMITH» · Toni Font
  ('Jalón con brazos rectos en polea', '{"Jalón con brazos rectos","Straight arm pulldown"}', 'espalda', 'HADmGUMN-Mw', null),
    -- «Jalón con brazos rectos» · Daniela Galvez Duarte
  ('Paseo del granjero', '{"Caminata de granjero","Farmer walk"}', 'espalda', '69hTPgHwA08', null),
    -- «CAMINATA DE GRANJERO (FARMER'S WALK): técnica correcta paso a paso» · Vitar Club

  -- Hombro
  ('Press landmine a un brazo', '{"Press landmine","Press en punta","Landmine press"}', 'hombros', 'pZUUZsgHswo', null),
    -- «Cómo hacer Press Landmine o Press en Punta: Técnica, Errores Comunes, Consejos y Variantes» · ReevolveFit
  ('Elevaciones en Y en banco inclinado', '{"Elevaciones en Y","Y raise"}', 'hombros', 'KSsY6zGJuzA', null),
    -- «Elevaciones en "Y" con mancuernas TUTORIAL» · DrVíctorLópez

  -- Core
  ('Plancha lateral con elevación de pierna', '{"Side plank leg raise"}', 'abdominales', 'PoDlY3ZQr4Y', null),
    -- «Plancha lateral con elevación de pierna» · Paula
  -- En producción ya existe (cargado desde la app); va igual para que la base local lo tenga.
  ('Hollow hold', '{"Hollow body hold"}', 'abdominales', 'Gkh7ZF_lcGw', null)
    -- «Hollow Body Hold» · The Active Life
on conflict do nothing;
