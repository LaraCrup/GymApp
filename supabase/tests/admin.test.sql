begin;
select plan(4);

set local role authenticated;

set local request.jwt.claims = '{"role":"authenticated","app_metadata":{}}';
select is(public.is_admin(), false, 'un usuario común no es admin');

set local request.jwt.claims = '{"role":"authenticated","app_metadata":{"is_admin":false}}';
select is(public.is_admin(), false, 'is_admin=false no es admin');

set local request.jwt.claims = '{"role":"authenticated","app_metadata":{"is_admin":true}}';
select is(public.is_admin(), true, 'is_admin=true es admin');

-- Marcarse admin desde el cliente (user_metadata) no sirve.
set local request.jwt.claims = '{"role":"authenticated","user_metadata":{"is_admin":true},"app_metadata":{}}';
select is(public.is_admin(), false, 'user_metadata.is_admin no cuenta');

select * from finish();
rollback;
