# Mis Rutinas

App web (PWA) para anotar rutinas de gimnasio, pesos y progreso. Privada: solo entra gente invitada.

Stack: Nuxt 4 (SPA) + TypeScript · Supabase (Postgres + Auth) · Tailwind CSS v4.

> README en construcción: se completa etapa por etapa (catálogo, rutinas, pesos, PWA y deploy).

## Requisitos

- Node 22+ y npm
- Docker (en Mac: [OrbStack](https://orbstack.dev)) — para correr Supabase en local
- [Supabase CLI](https://supabase.com/docs/guides/cli) 2.118+

## Levantar en local

```bash
npm install --legacy-peer-deps   # npm 10.9.2 tiene un bug con Nuxt 4 sin este flag
supabase start                   # levanta Postgres, Auth, Studio y Mailpit; aplica las migraciones
cp .env.example .env             # completar con API_URL y PUBLISHABLE_KEY que imprime `supabase start`
npm run dev                      # http://localhost:3000
```

Servicios locales:

| Qué | URL |
|---|---|
| App | http://localhost:3000 |
| Supabase Studio (base, usuarios) | http://127.0.0.1:54323 |
| Mailpit (los mails que "manda" la app) | http://127.0.0.1:54324 |

## Variables de entorno

| Variable | Qué es |
|---|---|
| `SUPABASE_URL` | URL del proyecto Supabase |
| `SUPABASE_KEY` | Clave **publishable** (antes "anon"). Es pública: los permisos los pone RLS |

Nunca va en el cliente la clave secreta / `service_role`. La app no la necesita.

## Usuarios

**Invitar a alguien:** Supabase Studio → Authentication → Users → *Invite user* → escribir el email.
Le llega un mail «Te invitaron a Mis Rutinas»; toca *Activar mi cuenta* y elige su contraseña.
El registro público está desactivado (`[auth] enable_signup = false` en `supabase/config.toml`).

**Marcar a alguien como admin del catálogo** (SQL editor de Studio). Tiene que volver a entrar para que se aplique:

```sql
update auth.users
set raw_app_meta_data = raw_app_meta_data || '{"is_admin": true}'
where email = 'tu-email@ejemplo.com';
```

## Catálogo de ejercicios

- Compartido entre todas las personas. Cualquiera puede **crear** ejercicios; solo el admin puede **editarlos y borrarlos** (RLS en la base).
- Carga inicial: 67 ejercicios con alias y grupo muscular (`supabase/migrations/*_catalog_seed.sql`), **sin videos**.
- **Agregar un video:** entrar como admin → Ejercicios → tocar el ejercicio → *Editar* → pegar el link de YouTube (sirven los de *Compartir*, `watch?v=`, `youtu.be` y `shorts`). Se guarda solo el ID del video y se muestra con `youtube-nocookie.com`, recién cuando se toca *Ver video*.
- Búsqueda (`search_exercises`): por nombre o alias, sin importar tildes ni mayúsculas, tolera errores de tipeo.
- Antes de crear uno nuevo se muestran los parecidos (`similar_exercises`) para no duplicar.

## Rutinas

- Cada persona ve y edita **solo sus rutinas** (RLS en `routines` y `routine_exercises`).
- Cada ejercicio de una rutina guarda series, repeticiones y peso actual.
- Orden editable con flechas (función `reorder_routine_exercises`, en una sola transacción).
- «Agrupar por músculo» se recuerda en cada celular.
- No se puede borrar del catálogo un ejercicio que está en alguna rutina.

## Base de datos

- Todo cambio va como migración en `supabase/migrations/` (`supabase migration new <nombre>`), nunca a mano en el dashboard.
- `supabase db reset` — recrea la base local desde cero con migraciones + seed.
- `npm run db:types` — regenera `app/types/database.types.ts` desde la base local.

## Tests

```bash
npm test            # unitarios (Vitest) de app/utils
npm run db:test     # tests de la base (pgTAP): permisos, funciones, RLS — correr después de `supabase db reset`
npm run typecheck
```
