-- Catálogo inicial. Va como migración (no en seed.sql) porque tiene que existir también en producción.
-- Sin videos: se cargan a mano desde la app. created_by queda null (= carga inicial).
-- `on conflict do nothing`: si alguien ya creó uno con el mismo nombre, se respeta el existente.
insert into public.exercises (name, aliases, muscle_group_id, created_by) values
  -- Pecho
  ('Press de banca plano con barra', '{"Press plano","Banco plano","Bench press"}', 'pecho', null),
  ('Press de banca con mancuernas', '{"Press plano con mancuernas","Dumbbell bench press"}', 'pecho', null),
  ('Press inclinado con barra', '{"Banco inclinado","Incline bench press"}', 'pecho', null),
  ('Press inclinado con mancuernas', '{"Press inclinado","Incline dumbbell press"}', 'pecho', null),
  ('Aperturas con mancuernas', '{"Aperturas","Aperturas planas","Dumbbell fly"}', 'pecho', null),
  ('Cruce de poleas', '{"Cruces en polea","Crossover","Cable crossover"}', 'pecho', null),
  ('Peck deck', '{"Mariposa","Contractora","Máquina de aperturas","Pec deck"}', 'pecho', null),
  ('Press de pecho en máquina', '{"Press en máquina","Chest press"}', 'pecho', null),
  ('Fondos en paralelas', '{"Fondos","Dips"}', 'pecho', null),
  ('Flexiones de brazos', '{"Lagartijas","Flexiones","Push ups"}', 'pecho', null),

  -- Espalda
  ('Dominadas', '{"Barra fija","Pull ups"}', 'espalda', null),
  ('Jalón al pecho', '{"Polea al pecho","Jalón frontal","Tirón al pecho","Lat pulldown"}', 'espalda', null),
  ('Remo con barra', '{"Remo inclinado","Remo con barra libre","Bent over row"}', 'espalda', null),
  ('Remo con mancuerna', '{"Remo a una mano","Serrucho","One arm dumbbell row"}', 'espalda', null),
  ('Remo en polea baja', '{"Remo sentado","Remo en polea","Seated cable row"}', 'espalda', null),
  ('Remo en máquina', '{"Remo sentado en máquina","Machine row"}', 'espalda', null),
  ('Peso muerto', '{"Peso muerto convencional","Deadlift"}', 'espalda', null),
  ('Pullover con mancuerna', '{"Pullover"}', 'espalda', null),
  ('Hiperextensiones', '{"Extensiones lumbares","Banco romano","Back extension"}', 'espalda', null),

  -- Hombros
  ('Press militar con barra', '{"Press militar","Press de hombros con barra","Overhead press"}', 'hombros', null),
  ('Press de hombros con mancuernas', '{"Press sentado con mancuernas","Dumbbell shoulder press"}', 'hombros', null),
  ('Vuelos laterales', '{"Elevaciones laterales","Laterales","Lateral raise"}', 'hombros', null),
  ('Vuelos frontales', '{"Elevaciones frontales","Frontales","Front raise"}', 'hombros', null),
  ('Vuelos posteriores', '{"Pájaros","Elevaciones posteriores","Deltoides posterior","Rear delt fly"}', 'hombros', null),
  ('Remo al mentón', '{"Remo al cuello","Upright row"}', 'hombros', null),
  ('Face pull', '{"Tirón a la cara","Face pulls"}', 'hombros', null),

  -- Bíceps
  ('Curl de bíceps con barra', '{"Curl con barra","Barbell curl"}', 'biceps', null),
  ('Curl de bíceps con mancuernas', '{"Curl alternado","Curl con mancuernas","Dumbbell curl"}', 'biceps', null),
  ('Curl martillo', '{"Martillo","Hammer curl"}', 'biceps', null),
  ('Curl en banco Scott', '{"Banco Scott","Curl predicador","Preacher curl"}', 'biceps', null),
  ('Curl de bíceps en polea', '{"Curl en polea","Cable curl"}', 'biceps', null),
  ('Curl concentrado', '{"Concentrado","Concentration curl"}', 'biceps', null),

  -- Tríceps
  ('Extensión de tríceps en polea', '{"Tríceps en polea","Jalón de tríceps","Pushdown"}', 'triceps', null),
  ('Press francés', '{"Rompecráneos","Extensión de tríceps acostado","Skull crusher"}', 'triceps', null),
  ('Extensión de tríceps sobre la cabeza', '{"Tríceps copa","Copa","Tríceps nuca","Overhead triceps extension"}', 'triceps', null),
  ('Patada de tríceps', '{"Patada","Tríceps kickback"}', 'triceps', null),
  ('Fondos en banco', '{"Fondos entre bancos","Bench dips"}', 'triceps', null),
  ('Press de banca agarre cerrado', '{"Press cerrado","Close grip bench press"}', 'triceps', null),

  -- Cuádriceps
  ('Sentadilla con barra', '{"Sentadilla","Sentadilla trasera","Squat"}', 'cuadriceps', null),
  ('Prensa de piernas', '{"Prensa","Prensa 45","Leg press"}', 'cuadriceps', null),
  ('Sillón de cuádriceps', '{"Extensiones de cuádriceps","Sillón extensor","Leg extension"}', 'cuadriceps', null),
  ('Estocadas', '{"Zancadas","Estocadas con mancuernas","Lunges"}', 'cuadriceps', null),
  ('Sentadilla búlgara', '{"Búlgaras","Bulgarian split squat"}', 'cuadriceps', null),
  ('Sentadilla goblet', '{"Sentadilla copa","Goblet squat"}', 'cuadriceps', null),
  ('Sentadilla hack', '{"Hack","Hack squat"}', 'cuadriceps', null),

  -- Femorales
  ('Camilla de femorales', '{"Curl femoral acostado","Femorales acostado","Isquiotibiales","Leg curl"}', 'femorales', null),
  ('Curl femoral sentado', '{"Silla de femorales","Seated leg curl"}', 'femorales', null),
  ('Peso muerto rumano', '{"Rumano","Romanian deadlift"}', 'femorales', null),
  ('Buenos días', '{"Good morning"}', 'femorales', null),

  -- Glúteos
  ('Hip thrust', '{"Empuje de cadera","Puente de glúteos con barra"}', 'gluteos', null),
  ('Puente de glúteos', '{"Elevación de cadera","Glute bridge"}', 'gluteos', null),
  ('Patada de glúteos en polea', '{"Patada de glúteo","Glute kickback"}', 'gluteos', null),
  ('Abductores en máquina', '{"Abductora","Máquina de abductores","Hip abduction"}', 'gluteos', null),

  -- Gemelos
  ('Elevación de talones de pie', '{"Gemelos parado","Pantorrillas de pie","Standing calf raise"}', 'gemelos', null),
  ('Elevación de talones sentado', '{"Gemelos sentado","Seated calf raise"}', 'gemelos', null),
  ('Gemelos en prensa', '{"Pantorrillas en prensa","Calf press"}', 'gemelos', null),

  -- Abdominales
  ('Crunch abdominal', '{"Abdominales","Abdominales cortos","Encogimientos","Crunch"}', 'abdominales', null),
  ('Plancha', '{"Plancha abdominal","Plank"}', 'abdominales', null),
  ('Elevación de piernas', '{"Elevaciones de piernas colgado","Leg raise"}', 'abdominales', null),
  ('Rueda abdominal', '{"Rueda","Ab wheel"}', 'abdominales', null),
  ('Bicicleta abdominal', '{"Bicycle crunch"}', 'abdominales', null),
  ('Giros rusos', '{"Twist ruso","Russian twist"}', 'abdominales', null),

  -- Cardio
  ('Cinta', '{"Caminadora","Correr en cinta","Treadmill"}', 'cardio', null),
  ('Bicicleta fija', '{"Bici fija","Bicicleta estática","Spinning"}', 'cardio', null),
  ('Elíptico', '{"Elíptica","Elliptical"}', 'cardio', null),
  ('Remo ergómetro', '{"Remoergómetro","Rowing"}', 'cardio', null),
  ('Saltar la soga', '{"Soga","Salto a la cuerda","Jump rope"}', 'cardio', null)
on conflict do nothing;
