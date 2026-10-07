-- Restore the school membership contract when the original schema migration was
-- only partially applied.
create extension if not exists pgcrypto;

create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text unique,
  address text,
  city text,
  country text default 'France',
  email text,
  phone text,
  logo_url text,
  status text not null default 'active',
  require_justification boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.school_memberships (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  school_id uuid not null references public.schools(id) on delete cascade,
  membership_type text not null,
  status text not null default 'pending',
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

create index if not exists idx_school_memberships_user
  on public.school_memberships(user_id);
create index if not exists idx_school_memberships_school_status
  on public.school_memberships(school_id, status);

alter table public.schools enable row level security;
alter table public.school_memberships enable row level security;

drop policy if exists "Schools are viewable by anyone" on public.schools;
create policy "Schools are viewable by anyone"
on public.schools for select to anon, authenticated using (true);

insert into public.schools (id, name, code, city, address, country)
values
  ('00000000-0000-0000-0000-000000000001', 'Lycée Victor Hugo', 'LVH-75003', 'Paris', '27 Rue de Sévigné', 'France'),
  ('00000000-0000-0000-0000-000000000002', 'Collège Jules Ferry', 'CJF-69002', 'Lyon', '14 Rue de la Charité', 'France'),
  ('00000000-0000-0000-0000-000000000003', 'Lycée Saint-Exupéry', 'LSE-31000', 'Toulouse', '8 Boulevard de Strasbourg', 'France')
on conflict (id) do nothing;

drop policy if exists "Memberships viewable by owner, school admin or super admin"
  on public.school_memberships;
create policy "Memberships viewable by owner, school admin or super admin"
on public.school_memberships
for select to authenticated
using (
  user_id = auth.uid()
  or exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('school_admin', 'super_admin')
  )
);

-- Allow a newly authenticated user to create only their own non-privileged profile.
-- Administrative roles must still be assigned server-side.
drop policy if exists "Users can insert own student or teacher profile" on public.profiles;
create policy "Users can insert own student or teacher profile"
on public.profiles
for insert to authenticated
with check (
  id = auth.uid()
  and role in ('student', 'teacher')
);

-- Keep student self-registration limited to the approved membership shape.
drop policy if exists "Users can insert own valid membership" on public.school_memberships;
create policy "Users can insert own valid membership"
on public.school_memberships
for insert to authenticated
with check (
  user_id = auth.uid()
  and (
    (membership_type = 'student' and status = 'approved')
    or
    (membership_type = 'teacher' and status = 'pending')
  )
);

notify pgrst, 'reload schema';
