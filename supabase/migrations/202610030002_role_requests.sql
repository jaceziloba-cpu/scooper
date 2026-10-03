create type public.role_request_status as enum ('pending', 'approved', 'rejected');

create table public.role_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  requested_role public.app_role not null check (requested_role <> 'owner'),
  status public.role_request_status not null default 'pending',
  review_note text,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create unique index role_requests_one_pending_per_user_idx
  on public.role_requests(user_id)
  where status = 'pending';

create index role_requests_user_created_idx
  on public.role_requests(user_id, created_at desc);

alter table public.role_requests enable row level security;

create policy role_requests_select_own on public.role_requests
for select to authenticated using (user_id = auth.uid());

create policy role_requests_insert_own on public.role_requests
for insert to authenticated
with check (user_id = auth.uid() and status = 'pending' and requested_role <> 'owner');
