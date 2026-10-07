-- Keep the live profile table compatible with the Flutter authentication flow.
alter table if exists public.profiles
  add column if not exists first_name text,
  add column if not exists last_name text,
  add column if not exists date_of_birth text,
  add column if not exists phone text,
  add column if not exists role text;

update public.profiles
set role = 'student'
where role is null;

alter table if exists public.profiles
  alter column role set default 'student';

notify pgrst, 'reload schema';
