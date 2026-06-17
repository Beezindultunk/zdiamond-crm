
-- ZDiamond CRM v13.39 Supabase setup
-- Futtasd a Supabase SQL Editorben.
create table if not exists public.zdiamond_profiles (
  id text primary key,
  team_id text not null,
  owner_id text not null,
  name text,
  role text,
  work_mode text,
  weekly_presentation_target int,
  weekly_invitation_target int,
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

create table if not exists public.zdiamond_contacts (
  id text primary key,
  team_id text not null,
  owner_id text not null,
  name text,
  phone text,
  email text,
  company text,
  status text,
  stage int,
  source text,
  sources jsonb default '[]'::jsonb,
  note text,
  tags jsonb default '[]'::jsonb,
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

create table if not exists public.zdiamond_queue (
  id text primary key,
  team_id text not null,
  owner_id text not null,
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

create table if not exists public.zdiamond_daily (
  id text primary key,
  team_id text not null,
  owner_id text not null,
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

create index if not exists idx_zdiamond_contacts_team_owner on public.zdiamond_contacts(team_id, owner_id);
create index if not exists idx_zdiamond_contacts_email on public.zdiamond_contacts(email);
create index if not exists idx_zdiamond_contacts_phone on public.zdiamond_contacts(phone);
create index if not exists idx_zdiamond_profiles_team on public.zdiamond_profiles(team_id);

alter table public.zdiamond_profiles enable row level security;
alter table public.zdiamond_contacts enable row level security;
alter table public.zdiamond_queue enable row level security;
alter table public.zdiamond_daily enable row level security;

-- MVP teszthez engedékeny policy anon kulccsal.
-- Élesben ezt Supabase Auth user_id alapú policyra kell szűkíteni.
drop policy if exists "zdiamond_mvp_profiles_all" on public.zdiamond_profiles;
drop policy if exists "zdiamond_mvp_contacts_all" on public.zdiamond_contacts;
drop policy if exists "zdiamond_mvp_queue_all" on public.zdiamond_queue;
drop policy if exists "zdiamond_mvp_daily_all" on public.zdiamond_daily;

create policy "zdiamond_mvp_profiles_all" on public.zdiamond_profiles for all using (true) with check (true);
create policy "zdiamond_mvp_contacts_all" on public.zdiamond_contacts for all using (true) with check (true);
create policy "zdiamond_mvp_queue_all" on public.zdiamond_queue for all using (true) with check (true);
create policy "zdiamond_mvp_daily_all" on public.zdiamond_daily for all using (true) with check (true);


-- v13.40 onboarding kiegészítés
create table if not exists public.zdiamond_onboarding (
  id text primary key,
  team_id text not null,
  owner_id text not null,
  completed boolean default false,
  completed_at timestamptz,
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
create index if not exists idx_zdiamond_onboarding_team_owner on public.zdiamond_onboarding(team_id, owner_id);
alter table public.zdiamond_onboarding enable row level security;
drop policy if exists "zdiamond_mvp_onboarding_all" on public.zdiamond_onboarding;
create policy "zdiamond_mvp_onboarding_all" on public.zdiamond_onboarding for all using (true) with check (true);


-- v13.41 immutable import vault metadata
create table if not exists public.zdiamond_import_vault (
  id text primary key,
  team_id text not null,
  owner_id text not null,
  source_name text,
  source_type text,
  source_hash text,
  total_rows int,
  processed_rows int,
  status text,
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
create index if not exists idx_zdiamond_import_vault_team_owner on public.zdiamond_import_vault(team_id, owner_id);
create index if not exists idx_zdiamond_import_vault_hash on public.zdiamond_import_vault(source_hash);
alter table public.zdiamond_import_vault enable row level security;
drop policy if exists "zdiamond_mvp_import_vault_all" on public.zdiamond_import_vault;
create policy "zdiamond_mvp_import_vault_all" on public.zdiamond_import_vault for all using (true) with check (true);


-- v13.46 registration approval requests
create table if not exists public.zdiamond_registration_requests (
  id text primary key,
  team_id text,
  owner_id text,
  name text,
  email text,
  phone text,
  upline text,
  work_mode text,
  status text default 'pending',
  code text,
  created_at timestamptz default now(),
  approved_at timestamptz,
  payload jsonb default '{}'::jsonb
);
create index if not exists idx_zdiamond_registration_requests_status on public.zdiamond_registration_requests(status);
create index if not exists idx_zdiamond_registration_requests_email on public.zdiamond_registration_requests(email);
alter table public.zdiamond_registration_requests enable row level security;
drop policy if exists "zdiamond_mvp_registration_requests_all" on public.zdiamond_registration_requests;
create policy "zdiamond_mvp_registration_requests_all" on public.zdiamond_registration_requests for all using (true) with check (true);


-- v13.47 goal planner
create table if not exists public.zdiamond_goal_plans (
  id text primary key,
  team_id text,
  owner_id text not null,
  period_type text not null,
  period_key text not null,
  partner_name text,
  plan jsonb default '{}'::jsonb,
  updated_at timestamptz default now()
);
create index if not exists idx_zdiamond_goal_plans_owner_period on public.zdiamond_goal_plans(owner_id, period_type, period_key);
alter table public.zdiamond_goal_plans enable row level security;
drop policy if exists "zdiamond_mvp_goal_plans_all" on public.zdiamond_goal_plans;
create policy "zdiamond_mvp_goal_plans_all" on public.zdiamond_goal_plans for all using (true) with check (true);


-- v13.51 product flow events
create table if not exists public.zdiamond_product_flow_events (
  id text primary key,
  team_id text,
  owner_id text not null,
  contact_id text,
  event_type text not null,
  event_date timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
create index if not exists idx_zdiamond_product_flow_events_owner on public.zdiamond_product_flow_events(owner_id);
create index if not exists idx_zdiamond_product_flow_events_contact on public.zdiamond_product_flow_events(contact_id);
alter table public.zdiamond_product_flow_events enable row level security;
drop policy if exists "zdiamond_mvp_product_flow_events_all" on public.zdiamond_product_flow_events;
create policy "zdiamond_mvp_product_flow_events_all" on public.zdiamond_product_flow_events for all using (true) with check (true);


-- v13.52 Supabase Auth / user identity
-- 1) Auth profile mapping
create table if not exists public.zdiamond_user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  auth_user_id uuid unique references auth.users(id) on delete cascade,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  name text,
  email text,
  role text not null default 'user',
  approved boolean default false,
  mentor_owner_id text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

create index if not exists idx_zdiamond_user_profiles_owner on public.zdiamond_user_profiles(owner_id);
create index if not exists idx_zdiamond_user_profiles_team_role on public.zdiamond_user_profiles(team_id, role);

-- 2) Add auth_user_id to existing app tables
alter table if exists public.zdiamond_contacts add column if not exists auth_user_id uuid references auth.users(id) on delete set null;
alter table if exists public.zdiamond_profiles add column if not exists auth_user_id uuid references auth.users(id) on delete set null;
alter table if exists public.zdiamond_queue add column if not exists auth_user_id uuid references auth.users(id) on delete set null;
alter table if exists public.zdiamond_daily add column if not exists auth_user_id uuid references auth.users(id) on delete set null;
alter table if exists public.zdiamond_onboarding add column if not exists auth_user_id uuid references auth.users(id) on delete set null;
alter table if exists public.zdiamond_registration_requests add column if not exists auth_user_id uuid references auth.users(id) on delete set null;
alter table if exists public.zdiamond_goal_plans add column if not exists auth_user_id uuid references auth.users(id) on delete set null;
alter table if exists public.zdiamond_import_vault add column if not exists auth_user_id uuid references auth.users(id) on delete set null;
alter table if exists public.zdiamond_product_flow_events add column if not exists auth_user_id uuid references auth.users(id) on delete set null;

create index if not exists idx_zdiamond_contacts_auth_user on public.zdiamond_contacts(auth_user_id);
create index if not exists idx_zdiamond_profiles_auth_user on public.zdiamond_profiles(auth_user_id);
create index if not exists idx_zdiamond_queue_auth_user on public.zdiamond_queue(auth_user_id);
create index if not exists idx_zdiamond_daily_auth_user on public.zdiamond_daily(auth_user_id);
create index if not exists idx_zdiamond_goals_auth_user on public.zdiamond_goal_plans(auth_user_id);
create index if not exists idx_zdiamond_events_auth_user on public.zdiamond_product_flow_events(auth_user_id);

-- 3) Helper functions for future strict RLS
create or replace function public.zdiamond_is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.zdiamond_user_profiles p
    where p.auth_user_id = auth.uid()
      and p.role in ('admin','owner')
      and coalesce(p.approved,true) = true
  );
$$;

create or replace function public.zdiamond_my_owner_id()
returns text
language sql
security definer
set search_path = public
as $$
  select owner_id from public.zdiamond_user_profiles p
  where p.auth_user_id = auth.uid()
  limit 1;
$$;

-- 4) RLS profile policies
alter table public.zdiamond_user_profiles enable row level security;

drop policy if exists "zdiamond_user_profiles_self_select" on public.zdiamond_user_profiles;
drop policy if exists "zdiamond_user_profiles_self_insert" on public.zdiamond_user_profiles;
drop policy if exists "zdiamond_user_profiles_self_update" on public.zdiamond_user_profiles;
drop policy if exists "zdiamond_user_profiles_admin_all" on public.zdiamond_user_profiles;

create policy "zdiamond_user_profiles_self_select"
on public.zdiamond_user_profiles for select
to authenticated
using (auth_user_id = auth.uid() or public.zdiamond_is_admin());

create policy "zdiamond_user_profiles_self_insert"
on public.zdiamond_user_profiles for insert
to authenticated
with check (auth_user_id = auth.uid() or public.zdiamond_is_admin());

create policy "zdiamond_user_profiles_self_update"
on public.zdiamond_user_profiles for update
to authenticated
using (auth_user_id = auth.uid() or public.zdiamond_is_admin())
with check (auth_user_id = auth.uid() or public.zdiamond_is_admin());

-- 5) Optional strict RLS template:
-- FONTOS: az alábbi drop/create policy részt csak akkor aktiváld, ha minden user Auth-tal lép be.
-- Addig az MVP policyk maradhatnak teszteléshez.
--
-- Példa zdiamond_contacts szigorú policy:
-- drop policy if exists "zdiamond_mvp_contacts_all" on public.zdiamond_contacts;
-- create policy "zdiamond_contacts_own_or_admin_select"
-- on public.zdiamond_contacts for select to authenticated
-- using (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());
-- create policy "zdiamond_contacts_own_or_admin_write"
-- on public.zdiamond_contacts for all to authenticated
-- using (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin())
-- with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());


-- v13.53 STRICT RLS PERMISSION LOCK
-- Futtatás előtt: v13.52 Auth működjön, admin Auth profil legyen mentve.
create or replace function public.zdiamond_my_role() returns text language sql security definer set search_path=public as $$ select coalesce((select p.role from public.zdiamond_user_profiles p where p.auth_user_id=auth.uid() limit 1),'user'); $$;
create or replace function public.zdiamond_my_team_id() returns text language sql security definer set search_path=public as $$ select coalesce((select p.team_id from public.zdiamond_user_profiles p where p.auth_user_id=auth.uid() limit 1),'zdiamond-main'); $$;
create or replace function public.zdiamond_is_mentor() returns boolean language sql security definer set search_path=public as $$ select exists(select 1 from public.zdiamond_user_profiles p where p.auth_user_id=auth.uid() and p.role in ('diamond','mentor','admin','owner') and coalesce(p.approved,true)=true); $$;
create or replace function public.zdiamond_can_access_owner(target_owner text,target_auth uuid default null,target_team text default null) returns boolean language sql security definer set search_path=public as $$ select auth.uid() is not null and (public.zdiamond_is_admin() or target_auth=auth.uid() or target_owner=public.zdiamond_my_owner_id() or (public.zdiamond_is_mentor() and target_team=public.zdiamond_my_team_id())); $$;
-- CONTACTS strict policies
alter table if exists public.zdiamond_contacts enable row level security;
drop policy if exists "zdiamond_mvp_contacts_all" on public.zdiamond_contacts;
drop policy if exists "zdiamond_contacts_own_or_admin_select" on public.zdiamond_contacts;
drop policy if exists "zdiamond_contacts_own_or_admin_insert" on public.zdiamond_contacts;
drop policy if exists "zdiamond_contacts_own_or_admin_update" on public.zdiamond_contacts;
drop policy if exists "zdiamond_contacts_own_or_admin_delete" on public.zdiamond_contacts;
create policy "zdiamond_contacts_own_or_admin_select" on public.zdiamond_contacts for select to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id));
create policy "zdiamond_contacts_own_or_admin_insert" on public.zdiamond_contacts for insert to authenticated with check (public.zdiamond_can_access_owner(owner_id,coalesce(auth_user_id,auth.uid()),team_id));
create policy "zdiamond_contacts_own_or_admin_update" on public.zdiamond_contacts for update to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id)) with check (public.zdiamond_can_access_owner(owner_id,coalesce(auth_user_id,auth.uid()),team_id));
create policy "zdiamond_contacts_own_or_admin_delete" on public.zdiamond_contacts for delete to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id));
-- Generic strict policies for other owner-based tables
alter table if exists public.zdiamond_profiles enable row level security;
drop policy if exists "zdiamond_mvp_profiles_all" on public.zdiamond_profiles;
drop policy if exists "zdiamond_profiles_own_or_admin_all" on public.zdiamond_profiles;
create policy "zdiamond_profiles_own_or_admin_all" on public.zdiamond_profiles for all to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id)) with check (public.zdiamond_can_access_owner(owner_id,coalesce(auth_user_id,auth.uid()),team_id));
alter table if exists public.zdiamond_queue enable row level security;
drop policy if exists "zdiamond_mvp_queue_all" on public.zdiamond_queue;
drop policy if exists "zdiamond_queue_own_or_admin_all" on public.zdiamond_queue;
create policy "zdiamond_queue_own_or_admin_all" on public.zdiamond_queue for all to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id)) with check (public.zdiamond_can_access_owner(owner_id,coalesce(auth_user_id,auth.uid()),team_id));
alter table if exists public.zdiamond_daily enable row level security;
drop policy if exists "zdiamond_mvp_daily_all" on public.zdiamond_daily;
drop policy if exists "zdiamond_daily_own_or_admin_all" on public.zdiamond_daily;
create policy "zdiamond_daily_own_or_admin_all" on public.zdiamond_daily for all to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id)) with check (public.zdiamond_can_access_owner(owner_id,coalesce(auth_user_id,auth.uid()),team_id));
alter table if exists public.zdiamond_onboarding enable row level security;
drop policy if exists "zdiamond_mvp_onboarding_all" on public.zdiamond_onboarding;
drop policy if exists "zdiamond_onboarding_own_or_admin_all" on public.zdiamond_onboarding;
create policy "zdiamond_onboarding_own_or_admin_all" on public.zdiamond_onboarding for all to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id)) with check (public.zdiamond_can_access_owner(owner_id,coalesce(auth_user_id,auth.uid()),team_id));
alter table if exists public.zdiamond_goal_plans enable row level security;
drop policy if exists "zdiamond_mvp_goal_plans_all" on public.zdiamond_goal_plans;
drop policy if exists "zdiamond_goal_plans_own_or_admin_all" on public.zdiamond_goal_plans;
create policy "zdiamond_goal_plans_own_or_admin_all" on public.zdiamond_goal_plans for all to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id)) with check (public.zdiamond_can_access_owner(owner_id,coalesce(auth_user_id,auth.uid()),team_id));
alter table if exists public.zdiamond_import_vault enable row level security;
drop policy if exists "zdiamond_mvp_import_vault_all" on public.zdiamond_import_vault;
drop policy if exists "zdiamond_import_vault_own_or_admin_all" on public.zdiamond_import_vault;
create policy "zdiamond_import_vault_own_or_admin_all" on public.zdiamond_import_vault for all to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id)) with check (public.zdiamond_can_access_owner(owner_id,coalesce(auth_user_id,auth.uid()),team_id));
alter table if exists public.zdiamond_product_flow_events enable row level security;
drop policy if exists "zdiamond_mvp_product_flow_events_all" on public.zdiamond_product_flow_events;
drop policy if exists "zdiamond_product_flow_events_own_or_admin_all" on public.zdiamond_product_flow_events;
create policy "zdiamond_product_flow_events_own_or_admin_all" on public.zdiamond_product_flow_events for all to authenticated using (public.zdiamond_can_access_owner(owner_id,auth_user_id,team_id)) with check (public.zdiamond_can_access_owner(owner_id,coalesce(auth_user_id,auth.uid()),team_id));
-- Registration requests: new applicant can insert; only mentor/admin can read/update
alter table if exists public.zdiamond_registration_requests enable row level security;
drop policy if exists "zdiamond_mvp_registration_requests_all" on public.zdiamond_registration_requests;
drop policy if exists "zdiamond_registration_requests_insert_any" on public.zdiamond_registration_requests;
drop policy if exists "zdiamond_registration_requests_admin_select" on public.zdiamond_registration_requests;
drop policy if exists "zdiamond_registration_requests_admin_update" on public.zdiamond_registration_requests;
create policy "zdiamond_registration_requests_insert_any" on public.zdiamond_registration_requests for insert to anon,authenticated with check (true);
create policy "zdiamond_registration_requests_admin_select" on public.zdiamond_registration_requests for select to authenticated using (public.zdiamond_is_admin() or public.zdiamond_is_mentor());
create policy "zdiamond_registration_requests_admin_update" on public.zdiamond_registration_requests for update to authenticated using (public.zdiamond_is_admin() or public.zdiamond_is_mentor()) with check (public.zdiamond_is_admin() or public.zdiamond_is_mentor());
create or replace view public.zdiamond_rls_status as select auth.uid() as auth_uid,public.zdiamond_my_owner_id() as owner_id,public.zdiamond_my_role() as role,public.zdiamond_my_team_id() as team_id,public.zdiamond_is_admin() as is_admin,public.zdiamond_is_mentor() as is_mentor;


-- v13.54 FINAL ADMIN / MENTOR / USER ROLE PERMISSIONS
-- This is an additive hardening layer on top of v13.53.

-- Normalize role values.
update public.zdiamond_user_profiles
set role = 'mentor'
where role = 'diamond';

update public.zdiamond_user_profiles
set role = 'admin'
where role = 'owner';

alter table public.zdiamond_user_profiles
  add column if not exists role_locked boolean default false,
  add column if not exists approved_by uuid references auth.users(id) on delete set null,
  add column if not exists approved_at timestamptz,
  add column if not exists permissions jsonb default '{}'::jsonb;

-- Role constraint.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'zdiamond_user_profiles_role_check'
  ) then
    alter table public.zdiamond_user_profiles
    add constraint zdiamond_user_profiles_role_check
    check (role in ('user','mentor','admin'));
  end if;
end $$;

-- Final helper functions.
create or replace function public.zdiamond_can_assign_roles()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.zdiamond_user_profiles p
    where p.auth_user_id = auth.uid()
      and p.role = 'admin'
      and coalesce(p.approved,true)=true
  );
$$;

create or replace function public.zdiamond_same_team(target_team text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select target_team = public.zdiamond_my_team_id();
$$;

-- Tighten user profile write policies.
drop policy if exists "zdiamond_user_profiles_self_update" on public.zdiamond_user_profiles;
drop policy if exists "zdiamond_user_profiles_admin_update_roles" on public.zdiamond_user_profiles;

create policy "zdiamond_user_profiles_self_update"
on public.zdiamond_user_profiles for update
to authenticated
using (auth_user_id = auth.uid())
with check (
  auth_user_id = auth.uid()
  and role = (select role from public.zdiamond_user_profiles where auth_user_id=auth.uid() limit 1)
  and owner_id = public.zdiamond_my_owner_id()
);

create policy "zdiamond_user_profiles_admin_update_roles"
on public.zdiamond_user_profiles for update
to authenticated
using (public.zdiamond_can_assign_roles())
with check (public.zdiamond_can_assign_roles());

-- Admin can select all, mentor same team, user self.
drop policy if exists "zdiamond_user_profiles_self_select" on public.zdiamond_user_profiles;
create policy "zdiamond_user_profiles_role_select"
on public.zdiamond_user_profiles for select
to authenticated
using (
  auth_user_id = auth.uid()
  or public.zdiamond_is_admin()
  or (public.zdiamond_is_mentor() and team_id = public.zdiamond_my_team_id())
);

-- Final role audit table.
create table if not exists public.zdiamond_role_audit (
  id text primary key,
  actor_auth_user_id uuid references auth.users(id) on delete set null,
  target_auth_user_id uuid references auth.users(id) on delete set null,
  target_owner_id text,
  old_role text,
  new_role text,
  event_date timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

alter table public.zdiamond_role_audit enable row level security;

drop policy if exists "zdiamond_role_audit_admin_all" on public.zdiamond_role_audit;
create policy "zdiamond_role_audit_admin_all"
on public.zdiamond_role_audit for all
to authenticated
using (public.zdiamond_is_admin())
with check (public.zdiamond_is_admin());

-- Final status view.
create or replace view public.zdiamond_role_permission_status as
select
  auth.uid() as auth_uid,
  public.zdiamond_my_owner_id() as owner_id,
  public.zdiamond_my_team_id() as team_id,
  public.zdiamond_my_role() as role,
  public.zdiamond_is_admin() as is_admin,
  public.zdiamond_is_mentor() as is_mentor,
  public.zdiamond_can_assign_roles() as can_assign_roles;


-- v13.55 REGISTRATION REQUESTS CLOUD FINAL

create table if not exists public.zdiamond_registration_requests (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text,
  auth_user_id uuid references auth.users(id) on delete set null,
  name text not null,
  email text not null,
  phone text,
  role_requested text not null default 'user',
  work_mode text default 'part_time',
  mentor_owner_id text,
  note text,
  status text not null default 'pending',
  invite_code text,
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_owner_id text,
  reviewed_at timestamptz,
  reject_reason text,
  source text default 'crm',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

do $$
begin
  if not exists (select 1 from pg_constraint where conname='zdiamond_registration_requests_status_check') then
    alter table public.zdiamond_registration_requests
      add constraint zdiamond_registration_requests_status_check
      check (status in ('pending','approved','rejected','cancelled'));
  end if;
  if not exists (select 1 from pg_constraint where conname='zdiamond_registration_requests_role_check') then
    alter table public.zdiamond_registration_requests
      add constraint zdiamond_registration_requests_role_check
      check (role_requested in ('user','mentor','diamond','admin'));
  end if;
end $$;

create index if not exists idx_zdiamond_registration_requests_team_status on public.zdiamond_registration_requests(team_id,status);
create index if not exists idx_zdiamond_registration_requests_email on public.zdiamond_registration_requests(email);
create index if not exists idx_zdiamond_registration_requests_auth_user on public.zdiamond_registration_requests(auth_user_id);
create index if not exists idx_zdiamond_registration_requests_created on public.zdiamond_registration_requests(created_at desc);

alter table public.zdiamond_registration_requests enable row level security;

drop policy if exists "zdiamond_mvp_registration_requests_all" on public.zdiamond_registration_requests;
drop policy if exists "zdiamond_registration_requests_insert_any" on public.zdiamond_registration_requests;
drop policy if exists "zdiamond_registration_requests_admin_select" on public.zdiamond_registration_requests;
drop policy if exists "zdiamond_registration_requests_admin_update" on public.zdiamond_registration_requests;
drop policy if exists "zdiamond_registration_requests_submit_public" on public.zdiamond_registration_requests;
drop policy if exists "zdiamond_registration_requests_read_own_or_reviewer" on public.zdiamond_registration_requests;
drop policy if exists "zdiamond_registration_requests_update_reviewer" on public.zdiamond_registration_requests;

-- Anyone can submit a request. This allows the first request before full approval.
create policy "zdiamond_registration_requests_submit_public"
on public.zdiamond_registration_requests for insert
to anon, authenticated
with check (
  status = 'pending'
  and coalesce(team_id,'') <> ''
  and coalesce(email,'') <> ''
  and coalesce(name,'') <> ''
);

-- Applicant can read own request by auth_user_id or email if logged in; mentor/admin can read team.
create policy "zdiamond_registration_requests_read_own_or_reviewer"
on public.zdiamond_registration_requests for select
to authenticated
using (
  auth_user_id = auth.uid()
  or lower(email) = lower(coalesce((select email from auth.users where id=auth.uid()),''))
  or public.zdiamond_is_admin()
  or (public.zdiamond_is_mentor() and team_id = public.zdiamond_my_team_id())
);

-- Only mentor/admin can approve/reject/update.
create policy "zdiamond_registration_requests_update_reviewer"
on public.zdiamond_registration_requests for update
to authenticated
using (
  public.zdiamond_is_admin()
  or (public.zdiamond_is_mentor() and team_id = public.zdiamond_my_team_id())
)
with check (
  public.zdiamond_is_admin()
  or (public.zdiamond_is_mentor() and team_id = public.zdiamond_my_team_id())
);

-- Audit table
create table if not exists public.zdiamond_registration_request_audit (
  id text primary key,
  request_id text references public.zdiamond_registration_requests(id) on delete cascade,
  actor_auth_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  old_status text,
  new_status text,
  event_date timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_registration_request_audit enable row level security;

drop policy if exists "zdiamond_registration_request_audit_reviewer_all" on public.zdiamond_registration_request_audit;
create policy "zdiamond_registration_request_audit_reviewer_all"
on public.zdiamond_registration_request_audit for all
to authenticated
using (public.zdiamond_is_admin() or public.zdiamond_is_mentor())
with check (public.zdiamond_is_admin() or public.zdiamond_is_mentor());

-- Status view for dashboard
create or replace view public.zdiamond_registration_requests_status as
select
  team_id,
  status,
  count(*) as request_count,
  max(created_at) as last_created_at
from public.zdiamond_registration_requests
group by team_id,status;


-- v13.56 GOAL PLANS CLOUD FINAL

create table if not exists public.zdiamond_goal_plans (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  plan_type text not null default 'monthly',
  period_key text not null,
  status text not null default 'active',
  targets jsonb not null default '{}'::jsonb,
  actuals jsonb not null default '{}'::jsonb,
  progress jsonb not null default '{}'::jsonb,
  note text,
  completed_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

do $$
begin
  if not exists (select 1 from pg_constraint where conname='zdiamond_goal_plans_type_check') then
    alter table public.zdiamond_goal_plans
      add constraint zdiamond_goal_plans_type_check
      check (plan_type in ('daily','weekly','monthly','quarterly','yearly','custom'));
  end if;
  if not exists (select 1 from pg_constraint where conname='zdiamond_goal_plans_status_check') then
    alter table public.zdiamond_goal_plans
      add constraint zdiamond_goal_plans_status_check
      check (status in ('draft','active','completed','archived','cancelled'));
  end if;
end $$;

create unique index if not exists idx_zdiamond_goal_plans_owner_period_type
on public.zdiamond_goal_plans(owner_id, period_key, plan_type);

create index if not exists idx_zdiamond_goal_plans_team_period
on public.zdiamond_goal_plans(team_id, period_key, plan_type);

create index if not exists idx_zdiamond_goal_plans_auth_user
on public.zdiamond_goal_plans(auth_user_id);

create index if not exists idx_zdiamond_goal_plans_status
on public.zdiamond_goal_plans(status);

alter table public.zdiamond_goal_plans enable row level security;

drop policy if exists "zdiamond_mvp_goal_plans_all" on public.zdiamond_goal_plans;
drop policy if exists "zdiamond_goal_plans_own_or_admin_all" on public.zdiamond_goal_plans;
drop policy if exists "zdiamond_goal_plans_read_own_or_team" on public.zdiamond_goal_plans;
drop policy if exists "zdiamond_goal_plans_insert_own" on public.zdiamond_goal_plans;
drop policy if exists "zdiamond_goal_plans_update_own_or_mentor" on public.zdiamond_goal_plans;
drop policy if exists "zdiamond_goal_plans_delete_admin" on public.zdiamond_goal_plans;

create policy "zdiamond_goal_plans_read_own_or_team"
on public.zdiamond_goal_plans for select
to authenticated
using (
  public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id)
);

create policy "zdiamond_goal_plans_insert_own"
on public.zdiamond_goal_plans for insert
to authenticated
with check (
  auth_user_id = auth.uid()
  or owner_id = public.zdiamond_my_owner_id()
  or public.zdiamond_is_admin()
);

create policy "zdiamond_goal_plans_update_own_or_mentor"
on public.zdiamond_goal_plans for update
to authenticated
using (
  public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id)
)
with check (
  public.zdiamond_can_access_owner(owner_id, coalesce(auth_user_id,auth.uid()), team_id)
);

create policy "zdiamond_goal_plans_delete_admin"
on public.zdiamond_goal_plans for delete
to authenticated
using (public.zdiamond_is_admin());

-- Goal plan audit table
create table if not exists public.zdiamond_goal_plan_audit (
  id text primary key,
  plan_id text references public.zdiamond_goal_plans(id) on delete cascade,
  actor_auth_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  old_status text,
  new_status text,
  event_date timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_goal_plan_audit enable row level security;

drop policy if exists "zdiamond_goal_plan_audit_read_team" on public.zdiamond_goal_plan_audit;
drop policy if exists "zdiamond_goal_plan_audit_insert_auth" on public.zdiamond_goal_plan_audit;

create policy "zdiamond_goal_plan_audit_read_team"
on public.zdiamond_goal_plan_audit for select
to authenticated
using (public.zdiamond_is_admin() or public.zdiamond_is_mentor());

create policy "zdiamond_goal_plan_audit_insert_auth"
on public.zdiamond_goal_plan_audit for insert
to authenticated
with check (auth.uid() is not null);

-- Summary view
create or replace view public.zdiamond_goal_plans_status as
select
  team_id,
  owner_id,
  plan_type,
  period_key,
  status,
  count(*) as plan_count,
  max(updated_at) as last_updated_at
from public.zdiamond_goal_plans
group by team_id,owner_id,plan_type,period_key,status;


-- v13.57 PRODUCT FLOW EVENTS CLOUD FINAL

create table if not exists public.zdiamond_product_flow_events (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  contact_id text,
  contact_name text,
  event_type text not null,
  event_date timestamptz default now(),
  note text,
  credit_delta numeric default 0,
  commission_delta numeric default 0,
  source text default 'crm',
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

do $$
begin
  if not exists (select 1 from pg_constraint where conname='zdiamond_product_flow_events_type_check') then
    alter table public.zdiamond_product_flow_events
      add constraint zdiamond_product_flow_events_type_check
      check (event_type in (
        'lead_added','approached','appointment','presentation','followup',
        'event_invite','ticket_sold','customer_registered','partner_registered',
        'dictation','cloud_save','manual_note','qa'
      ));
  end if;
end $$;

create index if not exists idx_zdiamond_product_flow_events_team_date
on public.zdiamond_product_flow_events(team_id,event_date desc);

create index if not exists idx_zdiamond_product_flow_events_owner_date
on public.zdiamond_product_flow_events(owner_id,event_date desc);

create index if not exists idx_zdiamond_product_flow_events_auth_user
on public.zdiamond_product_flow_events(auth_user_id);

create index if not exists idx_zdiamond_product_flow_events_contact
on public.zdiamond_product_flow_events(contact_id);

create index if not exists idx_zdiamond_product_flow_events_type
on public.zdiamond_product_flow_events(event_type);

alter table public.zdiamond_product_flow_events enable row level security;

drop policy if exists "zdiamond_mvp_product_flow_events_all" on public.zdiamond_product_flow_events;
drop policy if exists "zdiamond_product_flow_events_own_or_admin_all" on public.zdiamond_product_flow_events;
drop policy if exists "zdiamond_product_flow_events_read_own_or_team" on public.zdiamond_product_flow_events;
drop policy if exists "zdiamond_product_flow_events_insert_own" on public.zdiamond_product_flow_events;
drop policy if exists "zdiamond_product_flow_events_update_admin" on public.zdiamond_product_flow_events;
drop policy if exists "zdiamond_product_flow_events_delete_admin" on public.zdiamond_product_flow_events;

create policy "zdiamond_product_flow_events_read_own_or_team"
on public.zdiamond_product_flow_events for select
to authenticated
using (
  public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id)
);

create policy "zdiamond_product_flow_events_insert_own"
on public.zdiamond_product_flow_events for insert
to authenticated
with check (
  auth_user_id = auth.uid()
  or owner_id = public.zdiamond_my_owner_id()
  or public.zdiamond_is_admin()
);

create policy "zdiamond_product_flow_events_update_admin"
on public.zdiamond_product_flow_events for update
to authenticated
using (public.zdiamond_is_admin())
with check (public.zdiamond_is_admin());

create policy "zdiamond_product_flow_events_delete_admin"
on public.zdiamond_product_flow_events for delete
to authenticated
using (public.zdiamond_is_admin());

-- Event summary view
create or replace view public.zdiamond_product_flow_events_status as
select
  team_id,
  owner_id,
  event_type,
  count(*) as event_count,
  sum(coalesce(credit_delta,0)) as credit_sum,
  sum(coalesce(commission_delta,0)) as commission_sum,
  max(event_date) as last_event_at
from public.zdiamond_product_flow_events
group by team_id,owner_id,event_type;

-- Contact timeline view
create or replace view public.zdiamond_product_flow_contact_timeline as
select
  team_id,
  owner_id,
  contact_id,
  contact_name,
  event_type,
  event_date,
  note,
  credit_delta,
  commission_delta
from public.zdiamond_product_flow_events
order by event_date desc;


-- v13.58 LIVE 50X QA & CONTACT FOLLOW-UP FINAL

-- Contact fields for editor / follow-up / dictation agreement
alter table if exists public.zdiamond_contacts add column if not exists followup_date date;
alter table if exists public.zdiamond_contacts add column if not exists next_action text;
alter table if exists public.zdiamond_contacts add column if not exists last_agreement text;
alter table if exists public.zdiamond_contacts add column if not exists dictation_notes jsonb default '[]'::jsonb;
alter table if exists public.zdiamond_contacts add column if not exists deleted_at timestamptz;
alter table if exists public.zdiamond_contacts add column if not exists last_followup_done_at timestamptz;

create index if not exists idx_zdiamond_contacts_followup_date
on public.zdiamond_contacts(followup_date);

create index if not exists idx_zdiamond_contacts_deleted_at
on public.zdiamond_contacts(deleted_at);

-- Dedicated follow-up task table for future hard scheduling
create table if not exists public.zdiamond_followup_tasks (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  contact_id text,
  contact_name text,
  task_date date not null,
  task_type text default 'followup',
  task_title text not null,
  status text default 'open',
  completed_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

do $$
begin
  if not exists (select 1 from pg_constraint where conname='zdiamond_followup_tasks_status_check') then
    alter table public.zdiamond_followup_tasks
      add constraint zdiamond_followup_tasks_status_check
      check (status in ('open','done','cancelled','snoozed'));
  end if;
end $$;

create index if not exists idx_zdiamond_followup_tasks_owner_date
on public.zdiamond_followup_tasks(owner_id, task_date);

create index if not exists idx_zdiamond_followup_tasks_team_date
on public.zdiamond_followup_tasks(team_id, task_date);

create index if not exists idx_zdiamond_followup_tasks_auth_user
on public.zdiamond_followup_tasks(auth_user_id);

alter table public.zdiamond_followup_tasks enable row level security;

drop policy if exists "zdiamond_followup_tasks_read_own_or_team" on public.zdiamond_followup_tasks;
drop policy if exists "zdiamond_followup_tasks_insert_own" on public.zdiamond_followup_tasks;
drop policy if exists "zdiamond_followup_tasks_update_own_or_mentor" on public.zdiamond_followup_tasks;
drop policy if exists "zdiamond_followup_tasks_delete_admin" on public.zdiamond_followup_tasks;

create policy "zdiamond_followup_tasks_read_own_or_team"
on public.zdiamond_followup_tasks for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));

create policy "zdiamond_followup_tasks_insert_own"
on public.zdiamond_followup_tasks for insert
to authenticated
with check (
  auth_user_id = auth.uid()
  or owner_id = public.zdiamond_my_owner_id()
  or public.zdiamond_is_admin()
);

create policy "zdiamond_followup_tasks_update_own_or_mentor"
on public.zdiamond_followup_tasks for update
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id))
with check (public.zdiamond_can_access_owner(owner_id, coalesce(auth_user_id,auth.uid()), team_id));

create policy "zdiamond_followup_tasks_delete_admin"
on public.zdiamond_followup_tasks for delete
to authenticated
using (public.zdiamond_is_admin());

-- Live QA run audit
create table if not exists public.zdiamond_live_qa_runs (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  run_type text not null default 'live_50x',
  ok_count integer default 0,
  total_count integer default 0,
  result jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

alter table public.zdiamond_live_qa_runs enable row level security;

drop policy if exists "zdiamond_live_qa_runs_read_own_or_team" on public.zdiamond_live_qa_runs;
drop policy if exists "zdiamond_live_qa_runs_insert_own" on public.zdiamond_live_qa_runs;

create policy "zdiamond_live_qa_runs_read_own_or_team"
on public.zdiamond_live_qa_runs for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));

create policy "zdiamond_live_qa_runs_insert_own"
on public.zdiamond_live_qa_runs for insert
to authenticated
with check (
  auth_user_id = auth.uid()
  or owner_id = public.zdiamond_my_owner_id()
  or public.zdiamond_is_admin()
);

create or replace view public.zdiamond_morning_followup_due as
select
  team_id,
  owner_id,
  auth_user_id,
  id as contact_id,
  name as contact_name,
  followup_date,
  next_action,
  last_agreement,
  status
from public.zdiamond_contacts
where deleted_at is null
  and followup_date is not null
  and followup_date <= current_date;


-- v13.59 FINAL LAUNCH READINESS GATE

create table if not exists public.zdiamond_launch_readiness_checks (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  app_version text not null default 'v13.59',
  status text not null default 'not_ready',
  score_percent integer default 0,
  ok_count integer default 0,
  total_count integer default 0,
  blocker_count integer default 0,
  warning_count integer default 0,
  checks jsonb default '[]'::jsonb,
  blockers jsonb default '[]'::jsonb,
  warnings jsonb default '[]'::jsonb,
  approved boolean default false,
  approved_at timestamptz,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

do $$
begin
  if not exists (select 1 from pg_constraint where conname='zdiamond_launch_readiness_status_check') then
    alter table public.zdiamond_launch_readiness_checks
      add constraint zdiamond_launch_readiness_status_check
      check (status in ('ready','partly_ready','not_ready'));
  end if;
end $$;

create index if not exists idx_zdiamond_launch_readiness_team_date
on public.zdiamond_launch_readiness_checks(team_id, created_at desc);

create index if not exists idx_zdiamond_launch_readiness_owner_date
on public.zdiamond_launch_readiness_checks(owner_id, created_at desc);

create index if not exists idx_zdiamond_launch_readiness_auth
on public.zdiamond_launch_readiness_checks(auth_user_id);

alter table public.zdiamond_launch_readiness_checks enable row level security;

drop policy if exists "zdiamond_launch_readiness_read_own_or_team" on public.zdiamond_launch_readiness_checks;
drop policy if exists "zdiamond_launch_readiness_insert_own" on public.zdiamond_launch_readiness_checks;
drop policy if exists "zdiamond_launch_readiness_delete_admin" on public.zdiamond_launch_readiness_checks;

create policy "zdiamond_launch_readiness_read_own_or_team"
on public.zdiamond_launch_readiness_checks for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));

create policy "zdiamond_launch_readiness_insert_own"
on public.zdiamond_launch_readiness_checks for insert
to authenticated
with check (
  auth_user_id = auth.uid()
  or owner_id = public.zdiamond_my_owner_id()
  or public.zdiamond_is_admin()
);

create policy "zdiamond_launch_readiness_delete_admin"
on public.zdiamond_launch_readiness_checks for delete
to authenticated
using (public.zdiamond_is_admin());

create or replace view public.zdiamond_latest_launch_readiness as
select distinct on (team_id, owner_id)
  *
from public.zdiamond_launch_readiness_checks
order by team_id, owner_id, created_at desc;


-- v13.60 CLEAN FINAL MENU & PRODUCT JOURNEY TEST

create table if not exists public.zdiamond_final_menu_qa_runs (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  app_version text not null default 'v13.60',
  run_type text not null default 'final_menu',
  ok_count integer default 0,
  total_count integer default 0,
  clean_mode boolean default true,
  result jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

alter table public.zdiamond_final_menu_qa_runs enable row level security;

drop policy if exists "zdiamond_final_menu_qa_read_own_or_team" on public.zdiamond_final_menu_qa_runs;
drop policy if exists "zdiamond_final_menu_qa_insert_own" on public.zdiamond_final_menu_qa_runs;

create policy "zdiamond_final_menu_qa_read_own_or_team"
on public.zdiamond_final_menu_qa_runs for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));

create policy "zdiamond_final_menu_qa_insert_own"
on public.zdiamond_final_menu_qa_runs for insert
to authenticated
with check (
  auth_user_id = auth.uid()
  or owner_id = public.zdiamond_my_owner_id()
  or public.zdiamond_is_admin()
);

create or replace view public.zdiamond_final_product_journey_summary as
select
  team_id,
  owner_id,
  count(*) filter (where event_type='lead_added') as lead_added,
  count(*) filter (where event_type='approached') as approached,
  count(*) filter (where event_type='appointment') as appointment,
  count(*) filter (where event_type='presentation') as presentation,
  count(*) filter (where event_type='followup') as followup,
  count(*) filter (where event_type='event_invite') as event_invite,
  count(*) filter (where event_type='ticket_sold') as ticket_sold,
  count(*) filter (where event_type='customer_registered') as customers,
  count(*) filter (where event_type='partner_registered') as partners,
  sum(coalesce(credit_delta,0)) as credits,
  sum(coalesce(commission_delta,0)) as commission
from public.zdiamond_product_flow_events
group by team_id,owner_id;


-- v13.61 MOBILE ONE SCREEN DAILY MODE
create table if not exists public.zdiamond_mobile_daily_sessions (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  contact_id text,
  action_type text,
  agreement text,
  next_action text,
  followup_date date,
  dictation_note text,
  done boolean default false,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_mobile_daily_sessions enable row level security;
drop policy if exists "zdiamond_mobile_daily_sessions_read_own_or_team" on public.zdiamond_mobile_daily_sessions;
drop policy if exists "zdiamond_mobile_daily_sessions_insert_own" on public.zdiamond_mobile_daily_sessions;
create policy "zdiamond_mobile_daily_sessions_read_own_or_team"
on public.zdiamond_mobile_daily_sessions for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_mobile_daily_sessions_insert_own"
on public.zdiamond_mobile_daily_sessions for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());
create or replace view public.zdiamond_mobile_daily_due as
select team_id, owner_id, auth_user_id, id as contact_id, name as contact_name, product_status, followup_date, next_action, last_agreement
from public.zdiamond_contacts
where deleted_at is null and (followup_date is null or followup_date <= current_date)
order by followup_date nulls first, updated_at asc;


-- v13.62 USER / ADMIN TECHNICAL PANEL SHIELD
alter table if exists public.zdiamond_user_profiles
  add column if not exists ui_mode text default 'auto',
  add column if not exists hide_technical_panels boolean default true,
  add column if not exists preferred_mobile_daily boolean default true;

do $$
begin
  if not exists (select 1 from pg_constraint where conname='zdiamond_user_profiles_ui_mode_check') then
    alter table public.zdiamond_user_profiles
      add constraint zdiamond_user_profiles_ui_mode_check
      check (ui_mode in ('auto','user','mentor','admin'));
  end if;
end $$;

create table if not exists public.zdiamond_ui_mode_audit (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  old_mode text,
  new_mode text,
  changed_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);

alter table public.zdiamond_ui_mode_audit enable row level security;

drop policy if exists "zdiamond_ui_mode_audit_read_own_or_admin" on public.zdiamond_ui_mode_audit;
drop policy if exists "zdiamond_ui_mode_audit_insert_own" on public.zdiamond_ui_mode_audit;

create policy "zdiamond_ui_mode_audit_read_own_or_admin"
on public.zdiamond_ui_mode_audit for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));

create policy "zdiamond_ui_mode_audit_insert_own"
on public.zdiamond_ui_mode_audit for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());


-- v13.63 REAL MOBILE BOTTOM NAVIGATION & DEVICE INTELLIGENCE
create table if not exists public.zdiamond_device_sessions (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  device_type text,
  browser text,
  width integer,
  height integer,
  touch boolean,
  standalone boolean,
  online boolean,
  user_agent text,
  last_seen_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_device_sessions enable row level security;
drop policy if exists "zdiamond_device_sessions_read_own_or_team" on public.zdiamond_device_sessions;
drop policy if exists "zdiamond_device_sessions_insert_own" on public.zdiamond_device_sessions;
create policy "zdiamond_device_sessions_read_own_or_team"
on public.zdiamond_device_sessions for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_device_sessions_insert_own"
on public.zdiamond_device_sessions for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());
create or replace view public.zdiamond_device_usage_summary as
select team_id, owner_id, device_type, browser, count(*) as session_count, max(last_seen_at) as last_seen_at
from public.zdiamond_device_sessions
group by team_id, owner_id, device_type, browser;


-- v13.64 FIRST 10 MINUTES & OFFLINE RELIABILITY
create table if not exists public.zdiamond_first10_progress (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  progress_percent integer default 0,
  done_steps integer default 0,
  total_steps integer default 10,
  steps jsonb default '[]'::jsonb,
  completed boolean default false,
  completed_at timestamptz,
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_first10_progress enable row level security;
drop policy if exists "zdiamond_first10_read_own_or_team" on public.zdiamond_first10_progress;
drop policy if exists "zdiamond_first10_upsert_own" on public.zdiamond_first10_progress;
create policy "zdiamond_first10_read_own_or_team"
on public.zdiamond_first10_progress for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_first10_upsert_own"
on public.zdiamond_first10_progress for all
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id))
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_offline_sync_log (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  item_kind text,
  item_id text,
  status text default 'queued',
  tries integer default 0,
  error text,
  created_at timestamptz default now(),
  synced_at timestamptz,
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_offline_sync_log enable row level security;
drop policy if exists "zdiamond_offline_sync_read_own_or_team" on public.zdiamond_offline_sync_log;
drop policy if exists "zdiamond_offline_sync_insert_own" on public.zdiamond_offline_sync_log;
create policy "zdiamond_offline_sync_read_own_or_team"
on public.zdiamond_offline_sync_log for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_offline_sync_insert_own"
on public.zdiamond_offline_sync_log for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());


-- v13.65 CONFLICT RESOLVER & MORNING REMINDER FINAL
create table if not exists public.zdiamond_conflict_log (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  contact_id text,
  source text,
  diff_fields jsonb default '[]'::jsonb,
  local_record jsonb default '{}'::jsonb,
  remote_record jsonb default '{}'::jsonb,
  status text default 'open',
  resolution text,
  resolved_at timestamptz,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_conflict_log enable row level security;
drop policy if exists "zdiamond_conflict_log_read_own_or_team" on public.zdiamond_conflict_log;
drop policy if exists "zdiamond_conflict_log_insert_own" on public.zdiamond_conflict_log;
drop policy if exists "zdiamond_conflict_log_update_own_or_mentor" on public.zdiamond_conflict_log;
create policy "zdiamond_conflict_log_read_own_or_team"
on public.zdiamond_conflict_log for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_conflict_log_insert_own"
on public.zdiamond_conflict_log for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());
create policy "zdiamond_conflict_log_update_own_or_mentor"
on public.zdiamond_conflict_log for update
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id))
with check (public.zdiamond_can_access_owner(owner_id, coalesce(auth_user_id,auth.uid()), team_id));

create table if not exists public.zdiamond_morning_reminder_log (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  reminder_date date not null,
  due_count integer default 0,
  first_contact_id text,
  message text,
  shown_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_morning_reminder_log enable row level security;
drop policy if exists "zdiamond_morning_reminder_read_own_or_team" on public.zdiamond_morning_reminder_log;
drop policy if exists "zdiamond_morning_reminder_insert_own" on public.zdiamond_morning_reminder_log;
create policy "zdiamond_morning_reminder_read_own_or_team"
on public.zdiamond_morning_reminder_log for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_morning_reminder_insert_own"
on public.zdiamond_morning_reminder_log for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_open_conflicts as
select * from public.zdiamond_conflict_log where status='open';

create or replace view public.zdiamond_today_morning_tasks as
select
  team_id, owner_id, auth_user_id, id as contact_id, name as contact_name,
  followup_date, next_action, last_agreement
from public.zdiamond_contacts
where deleted_at is null
  and followup_date is not null
  and followup_date <= current_date
order by followup_date asc;


-- v13.66 90 PLUS PRODUCTION EXPERIENCE FINAL
create table if not exists public.zdiamond_experience_scorecard (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  app_version text not null default 'v13.66',
  cloud_data_score integer default 0,
  admin_ux_score integer default 0,
  mobile_user_score integer default 0,
  beginner_score integer default 0,
  average_score integer default 0,
  min_score integer default 0,
  production_ready boolean default false,
  scores jsonb default '[]'::jsonb,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_experience_scorecard enable row level security;
drop policy if exists "zdiamond_experience_scorecard_read_own_or_team" on public.zdiamond_experience_scorecard;
drop policy if exists "zdiamond_experience_scorecard_insert_own" on public.zdiamond_experience_scorecard;
create policy "zdiamond_experience_scorecard_read_own_or_team"
on public.zdiamond_experience_scorecard for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_experience_scorecard_insert_own"
on public.zdiamond_experience_scorecard for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_beginner_script_usage (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  contact_id text,
  product_status text,
  script_text text,
  used_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_beginner_script_usage enable row level security;
drop policy if exists "zdiamond_beginner_script_usage_read_own_or_team" on public.zdiamond_beginner_script_usage;
drop policy if exists "zdiamond_beginner_script_usage_insert_own" on public.zdiamond_beginner_script_usage;
create policy "zdiamond_beginner_script_usage_read_own_or_team"
on public.zdiamond_beginner_script_usage for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_beginner_script_usage_insert_own"
on public.zdiamond_beginner_script_usage for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_mentor_stuck_users as
select
  team_id, owner_id, auth_user_id, id as contact_id, name as contact_name,
  product_status, followup_date, next_action, updated_at
from public.zdiamond_contacts
where deleted_at is null
  and (followup_date is null or updated_at < now() - interval '2 days');


-- v13.67 SAFE START SCRIPTS & MENTOR ALERTS FINAL
create table if not exists public.zdiamond_mentor_alerts (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  alert_type text not null default 'stuck_user',
  severity text default 'warning',
  contact_id text,
  contact_name text,
  message text,
  status text default 'open',
  created_at timestamptz default now(),
  resolved_at timestamptz,
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_mentor_alerts enable row level security;
drop policy if exists "zdiamond_mentor_alerts_read_own_or_team" on public.zdiamond_mentor_alerts;
drop policy if exists "zdiamond_mentor_alerts_insert_own" on public.zdiamond_mentor_alerts;
drop policy if exists "zdiamond_mentor_alerts_update_mentor" on public.zdiamond_mentor_alerts;
create policy "zdiamond_mentor_alerts_read_own_or_team"
on public.zdiamond_mentor_alerts for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_mentor_alerts_insert_own"
on public.zdiamond_mentor_alerts for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());
create policy "zdiamond_mentor_alerts_update_mentor"
on public.zdiamond_mentor_alerts for update
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id))
with check (public.zdiamond_can_access_owner(owner_id, coalesce(auth_user_id,auth.uid()), team_id));

create table if not exists public.zdiamond_safe_start_usage (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  registered_name text,
  contact_id text,
  step_key text,
  script_label text,
  script_text text,
  action_type text,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_safe_start_usage enable row level security;
drop policy if exists "zdiamond_safe_start_usage_read_own_or_team" on public.zdiamond_safe_start_usage;
drop policy if exists "zdiamond_safe_start_usage_insert_own" on public.zdiamond_safe_start_usage;
create policy "zdiamond_safe_start_usage_read_own_or_team"
on public.zdiamond_safe_start_usage for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_safe_start_usage_insert_own"
on public.zdiamond_safe_start_usage for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_open_mentor_alerts as
select * from public.zdiamond_mentor_alerts where status='open' order by created_at desc;


-- v13.68 WEEKLY RHYTHM & BEGINNER SUCCESS FINAL
create table if not exists public.zdiamond_weekly_rhythm_targets (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  week_start date not null,
  week_end date not null,
  approached_target integer default 5,
  appointment_target integer default 2,
  presentation_target integer default 1,
  followup_target integer default 2,
  event_invite_target integer default 1,
  ticket_sold_target integer default 0,
  customer_registered_target integer default 0,
  partner_registered_target integer default 0,
  preset text default 'beginner',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_weekly_rhythm_targets enable row level security;
drop policy if exists "zdiamond_weekly_rhythm_read_own_or_team" on public.zdiamond_weekly_rhythm_targets;
drop policy if exists "zdiamond_weekly_rhythm_upsert_own" on public.zdiamond_weekly_rhythm_targets;
create policy "zdiamond_weekly_rhythm_read_own_or_team"
on public.zdiamond_weekly_rhythm_targets for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_weekly_rhythm_upsert_own"
on public.zdiamond_weekly_rhythm_targets for all
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id))
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_beginner_success_milestones (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  milestone_key text not null,
  milestone_label text,
  message text,
  shown_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_beginner_success_milestones enable row level security;
drop policy if exists "zdiamond_success_read_own_or_team" on public.zdiamond_beginner_success_milestones;
drop policy if exists "zdiamond_success_insert_own" on public.zdiamond_beginner_success_milestones;
create policy "zdiamond_success_read_own_or_team"
on public.zdiamond_beginner_success_milestones for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_success_insert_own"
on public.zdiamond_beginner_success_milestones for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_weekly_rhythm_progress as
select
  e.team_id,
  e.owner_id,
  e.auth_user_id,
  date_trunc('week', e.created_at)::date as week_start,
  e.event_type,
  count(*) as event_count
from public.zdiamond_product_flow_events e
where e.created_at >= date_trunc('week', now())
group by e.team_id, e.owner_id, e.auth_user_id, date_trunc('week', e.created_at)::date, e.event_type;


-- v13.69 NO MISTAKE CONFIDENCE & FULL FUNCTION AUDIT
create table if not exists public.zdiamond_full_function_audit (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  app_version text not null default 'v13.69',
  function_pct integer default 0,
  qa_pct integer default 0,
  safety_pct integer default 0,
  beginner_pct integer default 0,
  mobile_pct integer default 0,
  admin_pct integer default 0,
  cloud_pct integer default 0,
  usability_pct integer default 0,
  overall_pct integer default 0,
  ok_count integer default 0,
  total_count integer default 0,
  audit_json jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);
alter table public.zdiamond_full_function_audit enable row level security;
drop policy if exists "zdiamond_full_audit_read_own_or_team" on public.zdiamond_full_function_audit;
drop policy if exists "zdiamond_full_audit_insert_own" on public.zdiamond_full_function_audit;
create policy "zdiamond_full_audit_read_own_or_team"
on public.zdiamond_full_function_audit for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_full_audit_insert_own"
on public.zdiamond_full_function_audit for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_safety_backups (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  reason text,
  app_version text default 'v13.69',
  backup_json jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);
alter table public.zdiamond_safety_backups enable row level security;
drop policy if exists "zdiamond_safety_backups_read_own_or_team" on public.zdiamond_safety_backups;
drop policy if exists "zdiamond_safety_backups_insert_own" on public.zdiamond_safety_backups;
create policy "zdiamond_safety_backups_read_own_or_team"
on public.zdiamond_safety_backups for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_safety_backups_insert_own"
on public.zdiamond_safety_backups for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_latest_full_audit as
select distinct on (team_id, owner_id)
  *
from public.zdiamond_full_function_audit
order by team_id, owner_id, created_at desc;


-- v13.70 ROLE + DATA OWNERSHIP QA FINAL

create table if not exists public.zdiamond_role_data_qa_runs (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  role_name text,
  score integer default 0,
  ok_count integer default 0,
  total_count integer default 0,
  leak_count integer default 0,
  qa_json jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

alter table public.zdiamond_role_data_qa_runs enable row level security;

drop policy if exists "zdiamond_role_data_qa_runs_read_own_or_team" on public.zdiamond_role_data_qa_runs;
drop policy if exists "zdiamond_role_data_qa_runs_insert_own" on public.zdiamond_role_data_qa_runs;

create policy "zdiamond_role_data_qa_runs_read_own_or_team"
on public.zdiamond_role_data_qa_runs for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));

create policy "zdiamond_role_data_qa_runs_insert_own"
on public.zdiamond_role_data_qa_runs for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

alter table if exists public.zdiamond_contacts
  add column if not exists data_owner_role text default 'user',
  add column if not exists ownership_locked boolean default false,
  add column if not exists last_ownership_check_at timestamptz;

alter table if exists public.zdiamond_product_flow_events
  add column if not exists data_owner_role text default 'user',
  add column if not exists ownership_locked boolean default false,
  add column if not exists last_ownership_check_at timestamptz;

create or replace function public.zdiamond_normalize_contact_ownership()
returns trigger
language plpgsql
security definer
as $$
begin
  if new.team_id is null or new.team_id = '' then
    new.team_id := 'zdiamond-main';
  end if;
  if new.auth_user_id is null then
    new.auth_user_id := auth.uid();
  end if;
  if new.owner_id is null or new.owner_id = '' then
    new.owner_id := coalesce(public.zdiamond_my_owner_id(), auth.uid()::text, 'unknown-owner');
  end if;
  new.last_ownership_check_at := now();
  return new;
end;
$$;

drop trigger if exists trg_zdiamond_contacts_ownership on public.zdiamond_contacts;
create trigger trg_zdiamond_contacts_ownership
before insert or update on public.zdiamond_contacts
for each row execute function public.zdiamond_normalize_contact_ownership();

create or replace view public.zdiamond_contacts_missing_ownership as
select *
from public.zdiamond_contacts
where owner_id is null or owner_id = '' or team_id is null or team_id = '' or auth_user_id is null;

create or replace view public.zdiamond_role_data_ownership_summary as
select
  team_id,
  owner_id,
  count(*) as contact_count,
  count(*) filter (where deleted_at is null) as active_contact_count,
  count(*) filter (where followup_date is null and deleted_at is null) as missing_followup_count,
  count(*) filter (where owner_id is null or owner_id = '' or team_id is null or team_id = '' or auth_user_id is null) as ownership_missing_count,
  max(updated_at) as last_contact_update
from public.zdiamond_contacts
group by team_id, owner_id;


-- v13.71 FULL 90 PERCENT SYSTEM READINESS FINAL
create table if not exists public.zdiamond_system_90_readiness_runs (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  app_version text not null default 'v13.71',
  weighted_score integer default 0,
  average_score integer default 0,
  minimum_score integer default 0,
  below_90_count integer default 0,
  production_ready boolean default false,
  metrics_json jsonb default '[]'::jsonb,
  qa_json jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);
alter table public.zdiamond_system_90_readiness_runs enable row level security;
drop policy if exists "zdiamond_system_90_readiness_read_own_or_team" on public.zdiamond_system_90_readiness_runs;
drop policy if exists "zdiamond_system_90_readiness_insert_own" on public.zdiamond_system_90_readiness_runs;
create policy "zdiamond_system_90_readiness_read_own_or_team"
on public.zdiamond_system_90_readiness_runs for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_system_90_readiness_insert_own"
on public.zdiamond_system_90_readiness_runs for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_latest_system_90_readiness as
select distinct on (team_id, owner_id)
  *
from public.zdiamond_system_90_readiness_runs
order by team_id, owner_id, created_at desc;


-- v13.72 GOOGLE FACEBOOK MEET WORK ENGINE
create table if not exists public.zdiamond_import_batches (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  source text not null,
  total_count integer default 0,
  imported_count integer default 0,
  skipped_count integer default 0,
  updated_count integer default 0,
  status text default 'created',
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_import_batches enable row level security;
drop policy if exists "zdiamond_import_batches_read_own_or_team" on public.zdiamond_import_batches;
drop policy if exists "zdiamond_import_batches_insert_own" on public.zdiamond_import_batches;
create policy "zdiamond_import_batches_read_own_or_team"
on public.zdiamond_import_batches for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_import_batches_insert_own"
on public.zdiamond_import_batches for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_meet_appointments (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  contact_id text,
  contact_email text,
  contact_name text,
  calendar_event_id text,
  meet_link text,
  starts_at timestamptz,
  ends_at timestamptz,
  title text,
  status text default 'scheduled',
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_meet_appointments enable row level security;
drop policy if exists "zdiamond_meet_appointments_read_own_or_team" on public.zdiamond_meet_appointments;
drop policy if exists "zdiamond_meet_appointments_insert_own" on public.zdiamond_meet_appointments;
create policy "zdiamond_meet_appointments_read_own_or_team"
on public.zdiamond_meet_appointments for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_meet_appointments_insert_own"
on public.zdiamond_meet_appointments for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_import_source_summary as
select team_id, owner_id, source, count(*) as batch_count, sum(imported_count) as imported_total, max(created_at) as last_import_at
from public.zdiamond_import_batches
group by team_id, owner_id, source;

create or replace view public.zdiamond_upcoming_meet_appointments as
select *
from public.zdiamond_meet_appointments
where starts_at >= now() - interval '1 hour'
order by starts_at asc;


-- v13.73 GOOGLE SCOPES AUTO CONSENT GUARD
create table if not exists public.zdiamond_google_scope_checks (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  required_scopes jsonb default '[]'::jsonb,
  granted_scopes text,
  missing_scopes jsonb default '[]'::jsonb,
  google_email text,
  ok boolean default false,
  checked_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_google_scope_checks enable row level security;
drop policy if exists "zdiamond_google_scope_checks_read_own_or_team" on public.zdiamond_google_scope_checks;
drop policy if exists "zdiamond_google_scope_checks_insert_own" on public.zdiamond_google_scope_checks;
create policy "zdiamond_google_scope_checks_read_own_or_team"
on public.zdiamond_google_scope_checks for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_google_scope_checks_insert_own"
on public.zdiamond_google_scope_checks for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_latest_google_scope_check as
select distinct on (team_id, owner_id, auth_user_id)
  *
from public.zdiamond_google_scope_checks
order by team_id, owner_id, auth_user_id, checked_at desc;


-- v13.74 PREMIUM MEET INVITE & POST CALL PIPELINE ADMIN
create table if not exists public.zdiamond_post_call_admin (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  contact_id text,
  outcome text,
  post_call_note text,
  next_action text,
  next_followup_date date,
  new_pipeline_status text,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_post_call_admin enable row level security;
drop policy if exists "zdiamond_post_call_admin_read_own_or_team" on public.zdiamond_post_call_admin;
drop policy if exists "zdiamond_post_call_admin_insert_own" on public.zdiamond_post_call_admin;
create policy "zdiamond_post_call_admin_read_own_or_team"
on public.zdiamond_post_call_admin for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_post_call_admin_insert_own"
on public.zdiamond_post_call_admin for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

alter table if exists public.zdiamond_meet_appointments
  add column if not exists invitation_text text,
  add column if not exists reminder_email_minutes integer default 60,
  add column if not exists reminder_popup_minutes integer default 10,
  add column if not exists calendar_html_link text,
  add column if not exists post_call_admin_id text;

create or replace view public.zdiamond_meet_pipeline_followup as
select
  m.team_id,
  m.owner_id,
  m.auth_user_id,
  m.contact_id,
  m.contact_name,
  m.contact_email,
  m.meet_link,
  m.starts_at,
  p.outcome,
  p.new_pipeline_status,
  p.next_action,
  p.next_followup_date,
  p.created_at as post_call_created_at
from public.zdiamond_meet_appointments m
left join public.zdiamond_post_call_admin p on p.contact_id = m.contact_id
order by coalesce(p.created_at, m.created_at) desc;


-- v13.75 SIMPLE MEETING DAY FLOW FINAL
create table if not exists public.zdiamond_meeting_day_admin (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  contact_id text,
  contact_name text,
  outcome text,
  agreement text,
  send_what text,
  send_where text,
  next_action text,
  next_followup_date date,
  new_pipeline_status text,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_meeting_day_admin enable row level security;
drop policy if exists "zdiamond_meeting_day_admin_read_own_or_team" on public.zdiamond_meeting_day_admin;
drop policy if exists "zdiamond_meeting_day_admin_insert_own" on public.zdiamond_meeting_day_admin;
create policy "zdiamond_meeting_day_admin_read_own_or_team"
on public.zdiamond_meeting_day_admin for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_meeting_day_admin_insert_own"
on public.zdiamond_meeting_day_admin for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

alter table if exists public.zdiamond_contacts
  add column if not exists send_what text,
  add column if not exists send_where text,
  add column if not exists last_meeting_admin_at timestamptz;

create or replace view public.zdiamond_today_meeting_work as
select
  m.team_id, m.owner_id, m.auth_user_id, m.contact_id, m.contact_name, m.contact_email,
  m.meet_link, m.starts_at, m.status,
  c.product_status, c.next_action, c.followup_date
from public.zdiamond_meet_appointments m
left join public.zdiamond_contacts c on c.id = m.contact_id
where m.starts_at::date = current_date
order by m.starts_at asc;

create or replace view public.zdiamond_meeting_admin_followups as
select *
from public.zdiamond_meeting_day_admin
where next_followup_date is not null
order by next_followup_date asc;


-- v13.76 AI DAILY WORK CONTROL & AUTO PLANNER
create table if not exists public.zdiamond_ai_work_targets (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  new_contacts_week integer default 15,
  new_contacts_month integer default 60,
  approach_week integer default 25,
  appointment_week integer default 10,
  presentation_week integer default 5,
  followup_week integer default 10,
  event_invite_week integer default 5,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_ai_work_targets enable row level security;
drop policy if exists "zdiamond_ai_work_targets_read_own_or_team" on public.zdiamond_ai_work_targets;
drop policy if exists "zdiamond_ai_work_targets_upsert_own" on public.zdiamond_ai_work_targets;
create policy "zdiamond_ai_work_targets_read_own_or_team"
on public.zdiamond_ai_work_targets for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_ai_work_targets_upsert_own"
on public.zdiamond_ai_work_targets for all
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id))
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_ai_daily_work_plans (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  work_date date not null default current_date,
  daily_new_contacts integer default 0,
  daily_approaches integer default 0,
  daily_appointments integer default 0,
  daily_presentations integer default 0,
  daily_followups integer default 0,
  daily_event_invites integer default 0,
  next_best_action text,
  ai_message text,
  completed_json jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_ai_daily_work_plans enable row level security;
drop policy if exists "zdiamond_ai_daily_work_plans_read_own_or_team" on public.zdiamond_ai_daily_work_plans;
drop policy if exists "zdiamond_ai_daily_work_plans_insert_own" on public.zdiamond_ai_daily_work_plans;
create policy "zdiamond_ai_daily_work_plans_read_own_or_team"
on public.zdiamond_ai_daily_work_plans for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_ai_daily_work_plans_insert_own"
on public.zdiamond_ai_daily_work_plans for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_today_ai_work_summary as
select *
from public.zdiamond_ai_daily_work_plans
where work_date = current_date
order by created_at desc;


-- v13.77 STREAK & DAILY MISSIONS FINAL
create table if not exists public.zdiamond_daily_game_state (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  game_date date not null default current_date,
  streak integer default 0,
  xp integer default 0,
  missions_completed integer default 0,
  missions_total integer default 3,
  day_completed boolean default false,
  missions_json jsonb default '[]'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_daily_game_state enable row level security;
drop policy if exists "zdiamond_daily_game_state_read_own_or_team" on public.zdiamond_daily_game_state;
drop policy if exists "zdiamond_daily_game_state_upsert_own" on public.zdiamond_daily_game_state;
create policy "zdiamond_daily_game_state_read_own_or_team"
on public.zdiamond_daily_game_state for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_daily_game_state_upsert_own"
on public.zdiamond_daily_game_state for all
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id))
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_daily_mission_events (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  mission_id text,
  mission_title text,
  mission_date date not null default current_date,
  target integer default 0,
  done integer default 0,
  xp integer default 0,
  claimed boolean default false,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_daily_mission_events enable row level security;
drop policy if exists "zdiamond_daily_mission_events_read_own_or_team" on public.zdiamond_daily_mission_events;
drop policy if exists "zdiamond_daily_mission_events_insert_own" on public.zdiamond_daily_mission_events;
create policy "zdiamond_daily_mission_events_read_own_or_team"
on public.zdiamond_daily_mission_events for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_daily_mission_events_insert_own"
on public.zdiamond_daily_mission_events for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_today_game_state as
select *
from public.zdiamond_daily_game_state
where game_date = current_date
order by updated_at desc;


-- v13.78 XP POINTS & BUSINESS LEVELS FINAL
create table if not exists public.zdiamond_xp_ledger (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  action_key text,
  label text,
  xp integer default 0,
  note text,
  level integer default 1,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_xp_ledger enable row level security;
drop policy if exists "zdiamond_xp_ledger_read_own_or_team" on public.zdiamond_xp_ledger;
drop policy if exists "zdiamond_xp_ledger_insert_own" on public.zdiamond_xp_ledger;
create policy "zdiamond_xp_ledger_read_own_or_team"
on public.zdiamond_xp_ledger for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_xp_ledger_insert_own"
on public.zdiamond_xp_ledger for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_user_levels (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  total_xp integer default 0,
  current_level integer default 1,
  level_name text default 'Induló',
  last_level_up_at timestamptz,
  updated_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_user_levels enable row level security;
drop policy if exists "zdiamond_user_levels_read_own_or_team" on public.zdiamond_user_levels;
drop policy if exists "zdiamond_user_levels_upsert_own" on public.zdiamond_user_levels;
create policy "zdiamond_user_levels_read_own_or_team"
on public.zdiamond_user_levels for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_user_levels_upsert_own"
on public.zdiamond_user_levels for all
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id))
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_xp_leader_progress as
select
  team_id,
  owner_id,
  auth_user_id,
  sum(xp) as total_xp,
  count(*) as xp_events,
  max(created_at) as last_xp_at
from public.zdiamond_xp_ledger
group by team_id, owner_id, auth_user_id
order by total_xp desc;


-- v13.79 WEEKLY LEAGUES & RETURN MESSAGES FINAL
create table if not exists public.zdiamond_weekly_league_snapshots (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  week_start date not null,
  activity_score integer default 0,
  improvement_score integer default 0,
  result_score integer default 0,
  new_contacts integer default 0,
  approaches integer default 0,
  appointments integer default 0,
  presentations integer default 0,
  followups integer default 0,
  customers integer default 0,
  partners integer default 0,
  xp integer default 0,
  snapshot_json jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);
alter table public.zdiamond_weekly_league_snapshots enable row level security;
drop policy if exists "zdiamond_weekly_league_snapshots_read_own_or_team" on public.zdiamond_weekly_league_snapshots;
drop policy if exists "zdiamond_weekly_league_snapshots_insert_own" on public.zdiamond_weekly_league_snapshots;
create policy "zdiamond_weekly_league_snapshots_read_own_or_team"
on public.zdiamond_weekly_league_snapshots for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_weekly_league_snapshots_insert_own"
on public.zdiamond_weekly_league_snapshots for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_return_messages (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  message_type text not null,
  message_text text,
  shown_at timestamptz default now(),
  clicked boolean default false,
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_return_messages enable row level security;
drop policy if exists "zdiamond_return_messages_read_own_or_team" on public.zdiamond_return_messages;
drop policy if exists "zdiamond_return_messages_insert_own" on public.zdiamond_return_messages;
create policy "zdiamond_return_messages_read_own_or_team"
on public.zdiamond_return_messages for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_return_messages_insert_own"
on public.zdiamond_return_messages for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_weekly_activity_league as
select * from public.zdiamond_weekly_league_snapshots
where week_start = date_trunc('week', current_date)::date
order by activity_score desc;

create or replace view public.zdiamond_weekly_improvement_league as
select * from public.zdiamond_weekly_league_snapshots
where week_start = date_trunc('week', current_date)::date
order by improvement_score desc;

create or replace view public.zdiamond_weekly_result_league as
select * from public.zdiamond_weekly_league_snapshots
where week_start = date_trunc('week', current_date)::date
order by result_score desc;


-- v13.80 BEGINNER BADGES & FINAL USAGE AUDIT
create table if not exists public.zdiamond_beginner_badges (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  badge_id text not null,
  badge_title text,
  points integer default 0,
  earned_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_beginner_badges enable row level security;
drop policy if exists "zdiamond_beginner_badges_read_own_or_team" on public.zdiamond_beginner_badges;
drop policy if exists "zdiamond_beginner_badges_insert_own" on public.zdiamond_beginner_badges;
create policy "zdiamond_beginner_badges_read_own_or_team"
on public.zdiamond_beginner_badges for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_beginner_badges_insert_own"
on public.zdiamond_beginner_badges for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create table if not exists public.zdiamond_final_usage_audit (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  app_version text default 'v13.80',
  total_usage_pct integer default 0,
  simplicity_pct integer default 0,
  return_pct integer default 0,
  scale_100k_pct integer default 0,
  badge_pct integer default 0,
  audit_json jsonb default '{}'::jsonb,
  recommendations_json jsonb default '[]'::jsonb,
  created_at timestamptz default now()
);
alter table public.zdiamond_final_usage_audit enable row level security;
drop policy if exists "zdiamond_final_usage_audit_read_own_or_team" on public.zdiamond_final_usage_audit;
drop policy if exists "zdiamond_final_usage_audit_insert_own" on public.zdiamond_final_usage_audit;
create policy "zdiamond_final_usage_audit_read_own_or_team"
on public.zdiamond_final_usage_audit for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_final_usage_audit_insert_own"
on public.zdiamond_final_usage_audit for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

create or replace view public.zdiamond_latest_final_usage_audit as
select distinct on (team_id, owner_id)
  *
from public.zdiamond_final_usage_audit
order by team_id, owner_id, created_at desc;


-- v13.81 REAL AI BACKEND ASSISTANT FINAL
create table if not exists public.zdiamond_ai_assistant_requests (
  id text primary key,
  team_id text not null default 'zdiamond-main',
  owner_id text not null,
  auth_user_id uuid references auth.users(id) on delete set null,
  intent text,
  user_input text,
  backend_source text,
  ai_response text,
  context_json jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  payload jsonb default '{}'::jsonb
);
alter table public.zdiamond_ai_assistant_requests enable row level security;
drop policy if exists "zdiamond_ai_assistant_requests_read_own_or_team" on public.zdiamond_ai_assistant_requests;
drop policy if exists "zdiamond_ai_assistant_requests_insert_own" on public.zdiamond_ai_assistant_requests;
create policy "zdiamond_ai_assistant_requests_read_own_or_team"
on public.zdiamond_ai_assistant_requests for select
to authenticated
using (public.zdiamond_can_access_owner(owner_id, auth_user_id, team_id));
create policy "zdiamond_ai_assistant_requests_insert_own"
on public.zdiamond_ai_assistant_requests for insert
to authenticated
with check (auth_user_id = auth.uid() or owner_id = public.zdiamond_my_owner_id() or public.zdiamond_is_admin());

alter table if exists public.zdiamond_contacts
  add column if not exists ai_last_suggestion text,
  add column if not exists ai_last_suggestion_at timestamptz;

create or replace view public.zdiamond_latest_ai_assistant_requests as
select distinct on (team_id, owner_id, auth_user_id)
  *
from public.zdiamond_ai_assistant_requests
order by team_id, owner_id, auth_user_id, created_at desc;
