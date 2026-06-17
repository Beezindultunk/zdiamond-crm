
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
