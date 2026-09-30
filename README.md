# Mis Rutinas

App web instalable (PWA) para anotar rutinas de gimnasio, pesos y progreso. Privada: solo entra gente invitada.

- Producción: https://progreso-gimnasio.vercel.app
- Stack: Nuxt 4 (SPA) + TypeScript · Supabase (Postgres + Auth) · Tailwind CSS v4 · `@vite-pwa/nuxt`

## Qué hace

- **Rutinas** propias (crear, renombrar, borrar), con ejercicios ordenables y la opción de agruparlos por músculo.
- **Pesos**: botones −2,5 / −1 / +1 / +2,5 (o escribirlo), guardado automático, «la vez anterior».
- **Historial**: un punto por día y por ejercicio; gráfico y lista en la ficha del ejercicio.
- **Catálogo compartido** con alias («Remo con barra» = «Remo inclinado» = «Bent over row»), búsqueda sin tildes y tolerante a errores, videos de YouTube embebidos (`youtube-nocookie`, carga al tocar).
- **Instalable** en la pantalla de inicio (Android e iPhone) y abre sin conexión.

## Requisitos

- Node 22+ y npm
- Docker (en Mac: [OrbStack](https://orbstack.dev)) para correr Supabase en local
- [Supabase CLI](https://supabase.com/docs/guides/cli) 2.118+

## Levantar en local

```bash
npm install --legacy-peer-deps   # npm 10.9.2 tiene un bug con Nuxt 4 sin este flag
supabase start                   # Postgres, Auth, Studio y Mailpit; aplica migraciones
cp .env.example .env             # completar con API_URL y PUBLISHABLE_KEY que imprime `supabase start`
npm run dev                      # http://localhost:3000
```

| Qué | URL |
|---|---|
| App | http://localhost:3000 |
| Supabase Studio (tablas, usuarios, SQL) | http://127.0.0.1:54323 |
| Mailpit (los mails que "manda" la app en local) | http://127.0.0.1:54324 |

Para entrar en local, creá un usuario en Studio → Authentication → *Add user* (con «Auto Confirm User»), o invitalo y abrí el mail en Mailpit.

## Variables de entorno

| Variable | Qué es |
|---|---|
| `SUPABASE_URL` | URL del proyecto Supabase |
| `SUPABASE_KEY` | Clave **publishable** (antes "anon"). Es pública: los permisos los pone RLS |

La clave secreta / `service_role` **nunca** va en la app ni en Vercel: no se usa.

## Supabase en producción

Proyecto «App Gym» (`lgbohqnlqytszrrwpocz`, São Paulo). Todo cambio de base va como migración versionada; nada se hace a mano en el dashboard.

```bash
supabase login                   # una vez, con la cuenta dueña del proyecto
supabase link                    # elegir el proyecto
supabase db push                 # aplica las migraciones pendientes
```

**Config de Auth** (registro cerrado, mails en español, Site URL, SMTP) está en `supabase/config.toml`; lo propio de producción va en `[remotes.production]`. Para aplicarla:

```bash
SUPABASE_SMTP_USER='cuenta@gmail.com' SUPABASE_SMTP_PASS='xxxx xxxx xxxx xxxx' supabase config push
```

- El SMTP es Gmail con una **contraseña de aplicación** (https://myaccount.google.com/apppasswords; requiere verificación en dos pasos). Sin SMTP propio, el plan gratis no deja usar plantillas propias y solo manda mails a miembros del proyecto.
- Ojo: `[auth.email] enable_signup = false` apaga el login por email entero. El registro se cierra con `[auth] enable_signup = false`.

## Usuarios

- **Invitar**: dashboard → Authentication → Users → *Invite user*. Llega «Te invitaron a Mis Rutinas» → *Activar mi cuenta* → elige contraseña (`/clave`). El link se activa con un toque, así los antivirus del mail no lo gastan.
- **Olvidó la contraseña**: «Me olvidé la contraseña» en la app (mail con link a `/clave`).
- **Admin del catálogo** (edita y borra ejercicios, carga videos). En el SQL Editor, y después volver a entrar:
  ```sql
  update auth.users
  set raw_app_meta_data = raw_app_meta_data || '{"is_admin": true}'
  where email = 'tu-email@ejemplo.com';
  ```

## Deploy (Vercel)

- Vercel deploya solo cada push a `main`. Variables en Settings → Environment Variables: `SUPABASE_URL` y `SUPABASE_KEY` del proyecto de producción.
- **Orden**: si un cambio trae migraciones, primero `supabase db push` y después push a `main`. Al revés, la app nueva busca tablas que todavía no existen.
- La PWA se actualiza sola: al abrir la app después de un deploy se carga la versión nueva.

## Base de datos

| Tabla | Qué guarda | Quién ve / edita |
|---|---|---|
| `muscle_groups` | 11 grupos fijos | todos leen |
| `exercises` | catálogo con alias y `youtube_id` | todos leen y crean; solo admin edita y borra |
| `routines` | rutinas | cada persona las suyas |
| `routine_exercises` | ejercicio en rutina: orden, series, reps, peso | cada persona los suyos |
| `weight_logs` | historial: un punto por día por persona y ejercicio | cada persona lee el suyo; lo escribe un trigger |

- Funciones: `search_exercises`, `similar_exercises`, `reorder_routine_exercises`, `previous_weights`, `is_admin`.
- No se puede borrar del catálogo un ejercicio que alguien usa en una rutina o tiene en su historial.
- `supabase db reset` recrea la base local (migraciones + catálogo inicial de 67 ejercicios con video de YouTube verificado).
- `npm run db:types` regenera `app/types/database.types.ts`.

## Tests

```bash
npm test            # unitarios (Vitest): links de YouTube, pesos, fechas, guardado automático, errores
npm run db:test     # pgTAP: permisos (RLS), búsqueda, historial — correr después de `supabase db reset`
npm run typecheck
```

## Estructura

```
app/
  pages/          entrar, clave, recuperar, cuenta, index (rutinas), rutinas/[id], ejercicios/…
  components/     piezas chicas y reutilizables (AppButton, AppSheet, WeightControl, WeightChart…)
  composables/    datos (useRoutines, useCatalog, useWeightHistory) y comportamiento (useAutoSave, useConfirm…)
  utils/          funciones puras con tests (youtube, numbers, dates, friendlyError…)
supabase/
  migrations/     esquema, permisos y catálogo inicial
  tests/          pgTAP
  templates/      mails de invitación y recuperación
```

## Notas

- TypeScript fijado en 5.x: `vue-tsc` todavía no soporta TypeScript 7.
- Tipografía: base 16px, títulos hasta 20px; áreas táctiles de 48px como mínimo.
