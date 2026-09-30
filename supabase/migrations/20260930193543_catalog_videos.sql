-- Videos de YouTube para el catálogo inicial (pedido explícito, reemplaza la carga a mano).
-- Cada ID salió de una búsqueda real en YouTube (en español, corto, de técnica) y se verificó
-- con el oEmbed público: el video existe y permite verse embebido. Se revisaron los títulos a mano.
-- La imagen de cada ejercicio es la miniatura del video (i.ytimg.com), no hace falta guardarla.
-- Solo completa ejercicios sin video: si el admin ya cargó uno, se respeta.
update public.exercises e
set youtube_id = v.youtube_id
from (values
  -- abdominales
  ('Bicicleta abdominal', 'ibGRT6byKHI'), -- «Crunch Bicicleta, "abdominal intenso" | Protege tu cuello y activa el CORE: Técnica correc» · ReFUERZAtte
  ('Crunch abdominal', 'CwhxepX7aR8'), -- «Cómo hacer abdominales de la manera correcta» · Foroatletismo
  ('Elevación de piernas', 'eEbq5_AIgpo'), -- «Ejercicio de abdominales con elevación de piernas juntas» · Higea Salud
  ('Giros rusos', 'GaS6v-9Rs2k'), -- «Giros Rusos técnica correcta / Galvistrainer» · Galvistrainer
  ('Plancha', 'hAqEhJb9oDs'), -- «Plancha abdominal técnica correcta.» · Coach Bruno Reyes
  ('Rueda abdominal', 'NjOYrPXoLfY'), -- «Análisis biomecánico en 1 MINUTO - Rueda abdominal 🥵 -» · WeFitPlace
  -- biceps
  ('Curl concentrado', 'FrOJpldJWC4'), -- «Curl concentrado con mancuerna: Cómo hacerlo correctamente» · EresFitness
  ('Curl de bíceps con barra', 'vq22h2ovm_I'), -- «TÉCNICA DEL CURL DE BÍCEPS CON BARRA ¿COMO REALIZARLO CORRECTAMENTE?» · Gabriel fitness
  ('Curl de bíceps con mancuernas', 'qERAhN-qpaU'), -- «Haz CRECER tus BRAZOS así | Curl bíceps con mancuernas | GFit Coach» · Guillermo Fernández
  ('Curl de bíceps en polea', 'de_Xc1AKulo'), -- «Bíceps Bayesian. Curl de Bíceps en Polea Baja» · Zonapablo
  ('Curl en banco Scott', 'Ks5KNBSmw6A'), -- «Cómo realizar el ejercicio de Curl de bíceps en banco scott con barra z» · Fit Kamp
  ('Curl martillo', 'yjP-_KkLwys'), -- «BÍCEPS MARTILLO- ¿CÓMO HACERLO CORRECTAMENTE?» · Facu neyra 
  -- cardio
  ('Bicicleta fija', 'uIhuvUCRF9I'), -- «FueradelaMasa - Posición correcta en una bicicleta estática» · FueradelaMasa
  ('Cinta', '3ikTk0MDWJU'), -- «Cómo Usar la Caminadora en el Gimnasio | PROCLUB» · Pro Club Panama
  ('Elíptico', '-vPOM0ULsg0'), -- «Cómo Usar la Bicicleta Elíptica en el Gimnasio | PROCLUB» · Pro Club Panama
  ('Remo ergómetro', 'HDmtfcGXpvA'), -- «TÉCNICA DE REMO» · CrossFit España
  ('Saltar la soga', 'rpS3MQgxdA0'), -- «¿Como Saltar la cuerda? 👉  Aprende desde CERO en 3 minutos» · Adrián Fit
  -- cuadriceps
  ('Estocadas', 'FtNBlVNKrs0'), -- «COMO HACER LUNGES O ZANCADAS PASO A PASO - Tecnicas Gymtopz» · Tecnicas Gymtopz
  ('Prensa de piernas', 'KdT2g0iSdG0'), -- «🟢 Prensa de Piernas Inclinada 45 grados 🦵 | Técnica Correcta» · Vitar Club
  ('Sentadilla búlgara', '7zBnXPL5cck'), -- «COMO HACER SENTADILLAS BULGARAS» · Tecnicas Gymtopz
  ('Sentadilla con barra', 'mwOXK3IeFyM'), -- «CÓMO HACER SENTADILLA CON BARRA LIBRE – TÉCNICA CORRECTA PASO A PASO.» · lyesfit
  ('Sentadilla goblet', 'dB3TCDQFUtQ'), -- «🔵Cómo Hacer Sentadilla Goblet 🏋️‍♂️ | Goblet Squat Técnica Correcta» · Vitar Club
  ('Sentadilla hack', '02x3nqdPPvw'), -- «Sentadilla Hack, técnica, consejos y errores que debes evitar» · MarceTuCoach
  ('Sillón de cuádriceps', 'beGo5UVHNU8'), -- «Cómo Usar el Sillón de Cuádriceps: Guía Práctica» · Profit Tec
  -- espalda
  ('Dominadas', '1s6Bwx6GchI'), -- «💥 Cómo hacer DOMINADAS de forma correcta 💪🏼» · Nachogst
  ('Hiperextensiones', 'TCgjb7voz9k'), -- «Cómo Usar la Silla Romana para Extensión de Espalda en el Gimnasio | PROCLUB» · Pro Club Panama
  ('Jalón al pecho', 'oLQj4fySWQQ'), -- «Jalón al Pecho en Polea Alta. Espalda y Dorsal» · Zonapablo
  ('Peso muerto', '0XL4cZR2Ink'), -- «Cómo hacer el PESO MUERTO con seguridad (EN 5 PASOS)» · Julien LEPRETRE
  ('Pullover con mancuerna', 'NfCTdUmWYx0'), -- «Pullover con mancuerna (Espalda)» · Fran Osés
  ('Remo con barra', 'zmeGZ4I-C8w'), -- «COMO HACER REMO CON BARRA - TÉCNICA CORRECTA» · Gabriel fitness
  ('Remo con mancuerna', 'TXWrtDQ8UgI'), -- «Remo con Mancuerna | Técnica Correcta (!)» · ReFUERZAtte
  ('Remo en máquina', 'rGeBwjJC8nU'), -- «Como Hacer Remo Horizontal Espalda Sentado en Máquina  💪 | Técnica Correcta» · Vitar Club
  ('Remo en polea baja', 'gfc5NDJrVOk'), -- «REMO SENTADO ¡POSICIÓN CORRECTA!» · Entrenamiento Diferencial
  -- femorales
  ('Buenos días', 'MWiTDwnhWtw'), -- «¿Como realizar el ejercicio Good Morning correctamente?» · Pump rd
  ('Camilla de femorales', '9xbBr5Ytl8c'), -- «Cómo Hacer Curl Femoral Tumbado en Máquina 💪 | Técnica Correcta» · Vitar Club
  ('Curl femoral sentado', 'CBCPBnMzsMI'), -- «Curl Femoral Sentado en Máquina 🏋️‍♂️ | Técnica Correcta» · Vitar Club
  ('Peso muerto rumano', 'x7W2BOKWWKs'), -- «PESO MUERTO RUMANO CON MANCUERNAS» · CARLOS Online Coach
  -- gemelos
  ('Elevación de talones de pie', 'yyoubmNCDk4'), -- «Elevación de talones en posición de pie | Accesorio: mancuernas» · Deporte y Salud ITESO
  ('Elevación de talones sentado', 'Hq7ZnmkuZWM'), -- «Seated Calf Raise (Elevación de talones sentado en máquina) // Técnica y Puntos clave» · Grizzly Performance Programming
  ('Gemelos en prensa', '6UcOzvzUfDI'), -- «Técnica de Gemelos en Prensa: Fortalece tus Piernas» · Profit Tec
  -- gluteos
  ('Abductores en máquina', 'jpwUBWQRujk'), -- «ABDUCTORES EN MÁQUINA- Técnica» · Entrena tu Salud
  ('Hip thrust', 'efe-QObKAZU'), -- «¿Cómo Hacer un Empuje de Cadera con Barra? || Técnica Correcta» · Dra. Isabel Junio
  ('Patada de glúteos en polea', 'xEIB_l9haMg'), -- «PATADA DE GLÚTEO EN POLEA - EXPLICACIÓN TÉCNICA » · Sergio Alonso Perez 
  ('Puente de glúteos', 'uuiN9NRFMBo'), -- «¿Cómo hacer Puente de Glúteos? Aquí te explico 💪🏻» · Meli Cardenas
  -- hombros
  ('Face pull', 'BwFDZGcM0Hc'), -- «FACE PULL con Cuerda en Polea Alta: Técnica para HOMBROS 💪» · Vitar Club
  ('Press de hombros con mancuernas', 'GELRUlUSxeI'), -- «Técnica Press de Hombros con Mancuernas» · Dra. Isabel Junio
  ('Press militar con barra', 'xM2FGQuhZAY'), -- «Press Militar con Barra de Pie | PowerExplosive» · HSNstore.com
  ('Remo al mentón', 'zgXxvQ1LQhw'), -- «Remo al Menton con Barra» · Michael Romero
  ('Vuelos frontales', 'vcJm1sFxNco'), -- «Cómo hacer correctamente las Elevaciones frontales» · Saber Entrenar
  ('Vuelos laterales', 'hgLpdwMtEEs'), -- «CÓMO HACER ELEVACIONES LATERALES | HAZLO ASÍ! en 1 minuto» · Jesús López Trainer
  ('Vuelos posteriores', 'YNWiv-RUSPk'), -- «🏋🏼‍♂️Cómo hacer VUELOS POSTERIORES - TÉCNICA CORRECTA🔥» · Troopers 
  -- pecho
  ('Aperturas con mancuernas', 'zVzs8fJD33A'), -- «🔥 Aperturas con Mancuernas – Técnica Correcta Paso a Paso para un Pecho Firme y Estético 💪» · ReFUERZAtte
  ('Cruce de poleas', 'rSb5tAUcLM4'), -- «Como ESTIMULAR el PECHITO en CRUCES de POLEA» · Tomas Mazza Kick
  ('Flexiones de brazos', '5HL5WY0WVJQ'), -- «¿SABES HACER FLEXIONES CORRECTAMENTE?» · Revista Triatlón
  ('Fondos en paralelas', 'hSfqZAyIl8g'), -- «FONDOS EN PARALELAS | Técnica Correcta, Beneficios y Errores Comunes» · Alejo Marino
  ('Peck deck', 'WKfTStqIXrw'), -- «Cómo Hacer Aperturas de Pecho en Máquina Peck Deck 💪 | Técnica Correcta» · Vitar Club
  ('Press de banca con mancuernas', 'jrDDz7x1Dpo'), -- «Press Banca con Mancuernas / Dumbbell Bench Press - HSN Guía Ejercicios» · HSNstore.com
  ('Press de banca plano con barra', 'd3Yhz42T_cw'), -- «Cómo hacer un PRESS DE BANCA PLANO con barra! - Técnica de Ejercicio para PECTORALES - GYM» · CarmenGatesFitness
  ('Press de pecho en máquina', 'd-gwsl5BlMQ'), -- «Press de Pecho en Máquina 💪 | Cómo Hacerlo con Técnica Correcta» · Vitar Club
  ('Press inclinado con barra', '7Bz_S3mwlTg'), -- «Press inclinado con barra» · Priscilla_bc
  ('Press inclinado con mancuernas', 'XbTgnX2vRhw'), -- «Sabias esto? - POSTURA CORRECTA EN PRESS INCLINADO CON MANCUERNAS» · Bilbo Team Jesus Maria Varela
  -- triceps
  ('Extensión de tríceps en polea', 'uZg6VtRhwQY'), -- «Tríceps en Polea con Cuerdas / Tips Claves» · Zonapablo
  ('Extensión de tríceps sobre la cabeza', '3YjnNxHFTIo'), -- «Extensión de tricep sobre cabeza» · Agustin Giudici
  ('Fondos en banco', 'V2PU4HTNZJY'), -- «Fondos en banco: técnica paso a paso» · BuhoSalud
  ('Patada de tríceps', 'i_38xEoC5wA'), -- «Patada de Triceps con mancuerna | TÉCNICA CORRECTA» · JON JAMES CANO
  ('Press de banca agarre cerrado', 'EIlRudvdlIY'), -- «Press de banca agarre cerrado🔥Cómo hacerlo de forma correcta🙌🏽» · MINDIMALFIT
  ('Press francés', 'PTO862T8U7Y') -- «PRESS FRANCES TECNICA CORRECTA» · Entrenamiento Diferencial
) as v (name, youtube_id)
where e.name = v.name
  and e.youtube_id is null;
