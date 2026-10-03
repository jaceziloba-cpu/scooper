-- Migration: 202610030003_complete_scooper_auth_schema.sql
-- Description: Complete schema for SCOOPER public navigation, profiles, schools, school_memberships, roles, and RLS policies.

-- Create extension if not exists
create extension if not exists pgcrypto;

-- 1. Create Enum types if not already existing or use text check constraints for maximum flexibility
do $$
begin
  if not exists (select 1 from pg_type where typname = 'scooper_user_role') then
    create type public.scooper_user_role as enum ('student', 'teacher', 'school_admin', 'super_admin');
  end if;
  if not exists (select 1 from pg_type where typname = 'membership_type_enum') then
    create type public.membership_type_enum as enum ('student', 'teacher', 'school_admin');
  end if;
  if not exists (select 1 from pg_type where typname = 'membership_status_enum') then
    create type public.membership_status_enum as enum ('pending', 'approved', 'rejected', 'suspended');
  end if;
end $$;

-- 2. Create/Update Profiles Table
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  first_name text,
  last_name text,
  date_of_birth text,
  phone text,
  role text not null default 'student' check (role in ('student', 'teacher', 'school_admin', 'super_admin')),
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Ensure columns exist in profiles if profiles already existed
do $$
begin
  if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='first_name') then
    alter table public.profiles add column first_name text;
  end if;
  if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='last_name') then
    alter table public.profiles add column last_name text;
  end if;
  if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='date_of_birth') then
    alter table public.profiles add column date_of_birth text;
  end if;
  if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='phone') then
    alter table public.profiles add column phone text;
  end if;
  if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='role') then
    alter table public.profiles add column role text not null default 'student';
  end if;
end $$;

-- 3. Create Schools Table
create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 200),
  code text unique,
  address text,
  city text,
  country text default 'France',
  email text,
  phone text,
  logo_url text,
  status text not null default 'active' check (status in ('active', 'inactive')),
  require_justification boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Backward compatibility view if needed for establishments
create or replace view public.establishments as select id, name, created_at, updated_at from public.schools;

-- 4. Create School Memberships Table
create table if not exists public.school_memberships (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  school_id uuid not null references public.schools(id) on delete cascade,
  membership_type text not null check (membership_type in ('student', 'teacher', 'school_admin')),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected', 'suspended')),
  class_name text,
  subject text,
  function_title text,
  justification_url text,
  requested_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles(id) on delete set null,
  rejection_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, school_id)
);

-- Indexes for performant filtering
create index if not exists idx_school_memberships_user on public.school_memberships(user_id);
create index if not exists idx_school_memberships_school_status on public.school_memberships(school_id, status);

-- 5. Updated_at Triggers
create or replace function public.set_scooper_updated_at()
returns trigger language plpgsql security invoker set search_path = public as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at before update on public.profiles for each row execute function public.set_scooper_updated_at();

drop trigger if exists set_schools_updated_at on public.schools;
create trigger set_schools_updated_at before update on public.schools for each row execute function public.set_scooper_updated_at();

drop trigger if exists set_school_memberships_updated_at on public.school_memberships;
create trigger set_school_memberships_updated_at before update on public.school_memberships for each row execute function public.set_scooper_updated_at();

-- 6. Trigger to sync handle_new_user into profiles
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_first text;
  v_last text;
  v_role text;
begin
  v_first := coalesce(new.raw_user_meta_data ->> 'first_name', new.raw_user_meta_data ->> 'given_name', split_part(new.raw_user_meta_data ->> 'full_name', ' ', 1));
  v_last := coalesce(new.raw_user_meta_data ->> 'last_name', new.raw_user_meta_data ->> 'family_name', substring(new.raw_user_meta_data ->> 'full_name' from position(' ' in coalesce(new.raw_user_meta_data ->> 'full_name', '')) + 1));
  v_role := coalesce(new.raw_user_meta_data ->> 'role', 'student');
  
  -- Prevent self-assigned super_admin or school_admin on raw_user_meta_data signup
  if v_role not in ('student', 'teacher') then
    v_role := 'student';
  end if;

  insert into public.profiles (id, email, first_name, last_name, role, avatar_url)
  values (
    new.id,
    coalesce(new.email, ''),
    v_first,
    v_last,
    v_role,
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do update set
    email = excluded.email,
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

-- 7. Security: Prevent privilege escalation on profiles.role
create or replace function public.prevent_role_escalation()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_caller_role text;
begin
  select role into v_caller_role from public.profiles where id = auth.uid();
  if OLD.role is distinct from NEW.role then
    if v_caller_role <> 'super_admin' and auth.uid() is not null then
      raise exception 'Modification du rôle non autorisée.';
    end if;
  end if;
  return NEW;
end;
$$;

drop trigger if exists check_role_escalation on public.profiles;
create trigger check_role_escalation before update on public.profiles for each row execute function public.prevent_role_escalation();

-- 8. Row Level Security (RLS)
alter table public.profiles enable row level security;
alter table public.schools enable row level security;
alter table public.school_memberships enable row level security;

-- Profiles RLS Policies
drop policy if exists "Profiles are viewable by owner, school admin, or super admin" on public.profiles;
create policy "Profiles are viewable by owner, school admin, or super admin" on public.profiles
for select to authenticated using (
  id = auth.uid()
  or exists (
    select 1 from public.profiles p where p.id = auth.uid() and p.role = 'super_admin'
  )
  or exists (
    select 1 from public.school_memberships admin_m
    join public.school_memberships target_m on admin_m.school_id = target_m.school_id
    where admin_m.user_id = auth.uid()
      and admin_m.membership_type = 'school_admin'
      and target_m.user_id = profiles.id
  )
);

drop policy if exists "Users can update their own profile details" on public.profiles;
create policy "Users can update their own profile details" on public.profiles
for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Schools RLS Policies
drop policy if exists "Schools are viewable by anyone" on public.schools;
create policy "Schools are viewable by anyone" on public.schools
for select to anon, authenticated using (true);

drop policy if exists "Schools are editable by school_admin or super_admin" on public.schools;
create policy "Schools are editable by school_admin or super_admin" on public.schools
for update to authenticated using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'super_admin')
  or exists (select 1 from public.school_memberships where user_id = auth.uid() and school_id = schools.id and membership_type = 'school_admin' and status = 'approved')
);

drop policy if exists "Schools insertion by super_admin" on public.schools;
create policy "Schools insertion by super_admin" on public.schools
for insert to authenticated with check (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'super_admin')
);

-- School Memberships RLS Policies
drop policy if exists "Memberships viewable by owner, school_admin or super_admin" on public.school_memberships;
create policy "Memberships viewable by owner, school_admin or super_admin" on public.school_memberships
for select to authenticated using (
  user_id = auth.uid()
  or exists (select 1 from public.profiles where id = auth.uid() and role = 'super_admin')
  or exists (
    select 1 from public.school_memberships m
    where m.user_id = auth.uid() and m.school_id = school_memberships.school_id and m.membership_type = 'school_admin' and m.status = 'approved'
  )
);

drop policy if exists "Users can insert own valid membership" on public.school_memberships;
create policy "Users can insert own valid membership" on public.school_memberships
for insert to authenticated with check (
  user_id = auth.uid()
  and (
    (membership_type = 'student' and status = 'approved')
    or
    (membership_type = 'teacher' and status = 'pending')
  )
);

drop policy if exists "School admins or super_admin can update memberships" on public.school_memberships;
create policy "School admins or super_admin can update memberships" on public.school_memberships
for update to authenticated using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'super_admin')
  or exists (
    select 1 from public.school_memberships m
    where m.user_id = auth.uid() and m.school_id = school_memberships.school_id and m.membership_type = 'school_admin' and m.status = 'approved'
  )
);

-- Insert sample seed schools if table empty
insert into public.schools (name, code, city, country, address)
values 
  ('Lycée Victor Hugo', 'LVH-75003', 'Paris', 'France', '27 Rue de Sévigné'),
  ('Collège Jules Ferry', 'CJF-69002', 'Lyon', 'France', '14 Rue de la Charité'),
  ('Lycée Saint-Exupéry', 'LSE-31000', 'Toulouse', 'France', '8 Boulevard de Strasbourg')
on conflict do nothing;
