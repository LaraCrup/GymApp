-- Admin del catálogo compartido.
-- Se marca a mano en auth.users.raw_app_meta_data (ver README). Viaja en el JWT como
-- app_metadata.is_admin y el usuario no lo puede modificar (a diferencia de user_metadata).
create or replace function public.is_admin()
returns boolean
language sql
stable
set search_path = ''
as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'is_admin')::boolean, false)
$$;

comment on function public.is_admin() is 'true si la sesión actual es de un admin (app_metadata.is_admin).';

revoke execute on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;
