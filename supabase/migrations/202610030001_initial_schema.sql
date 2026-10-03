create extension if not exists pgcrypto;

create type public.app_role as enum ('owner', 'admin', 'teacher', 'parent', 'student');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.establishments (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 160),
  owner_id uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.establishment_members (
  establishment_id uuid not null references public.establishments(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.app_role not null,
  created_at timestamptz not null default now(),
  primary key (establishment_id, user_id)
);

create table public.schedules (
  id uuid primary key default gen_random_uuid(),
  establishment_id uuid not null references public.establishments(id) on delete cascade,
  title text not null,
  weekday smallint not null check (weekday between 1 and 7),
  starts_at time not null,
  ends_at time not null,
  room text,
  teacher_id uuid references auth.users(id) on delete set null,
  class_name text,
  updated_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  body text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index establishment_members_user_id_idx on public.establishment_members(user_id);
create index schedules_establishment_weekday_idx on public.schedules(establishment_id, weekday);
create index notifications_user_created_idx on public.notifications(user_id, created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();
create trigger establishments_set_updated_at before update on public.establishments
for each row execute function public.set_updated_at();
create trigger schedules_set_updated_at before update on public.schedules
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.email, ''),
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_establishment_member(target_establishment uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.establishment_members
    where establishment_id = target_establishment and user_id = auth.uid()
  );
$$;

create or replace function public.has_establishment_role(target_establishment uuid, allowed_roles public.app_role[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.establishment_members
    where establishment_id = target_establishment
      and user_id = auth.uid()
      and role = any(allowed_roles)
  );
$$;

alter table public.profiles enable row level security;
alter table public.establishments enable row level security;
alter table public.establishment_members enable row level security;
alter table public.schedules enable row level security;
alter table public.notifications enable row level security;

create policy profiles_select_own on public.profiles
for select to authenticated using (id = auth.uid());
create policy profiles_update_own on public.profiles
for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

create policy establishments_select_member on public.establishments
for select to authenticated using (public.is_establishment_member(id));
create policy establishments_insert_owner on public.establishments
for insert to authenticated with check (owner_id = auth.uid());
create policy establishments_update_admin on public.establishments
for update to authenticated using (public.has_establishment_role(id, array['owner', 'admin']::public.app_role[]))
with check (public.has_establishment_role(id, array['owner', 'admin']::public.app_role[]));
create policy establishments_delete_owner on public.establishments
for delete to authenticated using (owner_id = auth.uid());

create policy members_select_member on public.establishment_members
for select to authenticated using (public.is_establishment_member(establishment_id));
create policy members_insert_owner on public.establishment_members
for insert to authenticated with check (
  user_id = auth.uid()
  and role = 'owner'
  and exists (select 1 from public.establishments e where e.id = establishment_id and e.owner_id = auth.uid())
);
create policy members_manage_admin on public.establishment_members
for update to authenticated using (public.has_establishment_role(establishment_id, array['owner', 'admin']::public.app_role[]))
with check (public.has_establishment_role(establishment_id, array['owner', 'admin']::public.app_role[]));
create policy members_delete_admin on public.establishment_members
for delete to authenticated using (public.has_establishment_role(establishment_id, array['owner', 'admin']::public.app_role[]));

create policy schedules_select_member on public.schedules
for select to authenticated using (public.is_establishment_member(establishment_id));
create policy schedules_insert_staff on public.schedules
for insert to authenticated with check (public.has_establishment_role(establishment_id, array['owner', 'admin', 'teacher']::public.app_role[]));
create policy schedules_update_staff on public.schedules
for update to authenticated using (public.has_establishment_role(establishment_id, array['owner', 'admin', 'teacher']::public.app_role[]))
with check (public.has_establishment_role(establishment_id, array['owner', 'admin', 'teacher']::public.app_role[]));
create policy schedules_delete_admin on public.schedules
for delete to authenticated using (public.has_establishment_role(establishment_id, array['owner', 'admin']::public.app_role[]));

create policy notifications_select_own on public.notifications
for select to authenticated using (user_id = auth.uid());
create policy notifications_update_own on public.notifications
for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
