-- ============================================================================
-- DOMORA - SPRINT 1 SCHEMA
-- Run this script in the Supabase SQL Editor.
-- Covers: USERS, ROLES, USER_ROLES, CLIENT_PROFILES, PROVIDER_PROFILES, ADDRESSES
-- Plus: onboarding flag, RLS policies, Storage bucket for avatars.
-- ============================================================================

-- Required extensions
create extension if not exists "uuid-ossp";

-- ============================================================================
-- ROLES
-- ============================================================================
create table if not exists public.roles (
  id          uuid primary key default uuid_generate_v4(),
  name        varchar(50) not null unique,
  description varchar(255),
  created_at  timestamptz not null default now()
);

insert into public.roles (name, description) values
  ('client',   'Usuario que solicita servicios'),
  ('provider', 'Usuario que ofrece servicios')
on conflict (name) do nothing;

-- ============================================================================
-- USERS  (mirrors auth.users; id MUST equal auth.users.id)
-- ============================================================================
create table if not exists public.users (
  id                    uuid primary key references auth.users(id) on delete cascade,
  email                 varchar(255) not null unique,
  phone                 varchar(20),
  first_name            varchar(100),
  last_name             varchar(100),
  is_active             boolean not null default true,
  onboarding_completed  boolean not null default false,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  last_login            timestamptz
);



-- ============================================================================
-- USER_ROLES
-- ============================================================================
create table if not exists public.user_roles (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references public.users(id) on delete cascade,
  role_id    uuid not null references public.roles(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (user_id, role_id)
);

create index if not exists idx_user_roles_user_id on public.user_roles(user_id);

-- ============================================================================
-- CLIENT_PROFILES
-- ============================================================================
create table if not exists public.client_profiles (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null unique references public.users(id) on delete cascade,
  avatar_url varchar(500),
  bio        varchar(500)
);

-- ============================================================================
-- PROVIDER_PROFILES
-- ============================================================================
create table if not exists public.provider_profiles (
  id               uuid primary key default uuid_generate_v4(),
  user_id          uuid not null unique references public.users(id) on delete cascade,
  years_experience int  default 0,
  hourly_rate      decimal(10,2) default 0,
  is_available     boolean not null default true,
  bio              varchar(1000),
  avatar_url       varchar(500)
);

-- ============================================================================
-- ADDRESSES
-- ============================================================================
create table if not exists public.addresses (
  id             uuid primary key default uuid_generate_v4(),
  user_id        uuid not null references public.users(id) on delete cascade,
  location_name  varchar(100),
  address_line1  varchar(255) not null,
  address_line2  varchar(255),
  city           varchar(100) not null,
  neighborhood   varchar(100),
  latitude       decimal(10,7),
  longitude      decimal(10,7),
  is_primary     boolean not null default false,
  address_type   varchar(50) default 'home',
  created_at     timestamptz not null default now()
);

create index if not exists idx_addresses_user_id on public.addresses(user_id);

-- ============================================================================
-- TRIGGER: auto-create public.users row when auth.users is created
-- ============================================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.users (id, email)
  values (new.id, new.email)
  on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================================
-- TRIGGER: sync email changes from auth.users to public.users
-- ============================================================================
create or replace function public.sync_user_email()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.users
  set email = new.email,
      updated_at = now()
  where id = new.id;
  return new;
end;
$$;

drop trigger if exists on_auth_user_updated on auth.users;
create trigger on_auth_user_updated
  after update on auth.users
  for each row execute function public.sync_user_email();

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
alter table public.users             enable row level security;
alter table public.user_roles        enable row level security;
alter table public.client_profiles   enable row level security;
alter table public.provider_profiles enable row level security;
alter table public.addresses         enable row level security;
alter table public.roles             enable row level security;

-- ROLES: anyone authenticated can read
drop policy if exists "roles_select" on public.roles;
create policy "roles_select" on public.roles
  for select to authenticated using (true);

-- USERS: a user can read/update only their own row
drop policy if exists "users_select_own"  on public.users;
drop policy if exists "users_update_own"  on public.users;
drop policy if exists "users_insert_own"  on public.users;
create policy "users_select_own" on public.users
  for select to authenticated using (auth.uid() = id);
create policy "users_update_own" on public.users
  for update to authenticated using (auth.uid() = id);
create policy "users_insert_own" on public.users
  for insert to authenticated with check (auth.uid() = id);

-- USER_ROLES: a user can read/insert only their own role rows
drop policy if exists "user_roles_select_own" on public.user_roles;
drop policy if exists "user_roles_insert_own" on public.user_roles;
create policy "user_roles_select_own" on public.user_roles
  for select to authenticated using (auth.uid() = user_id);
create policy "user_roles_insert_own" on public.user_roles
  for insert to authenticated with check (auth.uid() = user_id);

-- CLIENT_PROFILES
drop policy if exists "client_profiles_all_own" on public.client_profiles;
create policy "client_profiles_all_own" on public.client_profiles
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- PROVIDER_PROFILES
drop policy if exists "provider_profiles_all_own" on public.provider_profiles;
create policy "provider_profiles_all_own" on public.provider_profiles
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ADDRESSES
drop policy if exists "addresses_all_own" on public.addresses;
create policy "addresses_all_own" on public.addresses
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ============================================================================
-- STORAGE BUCKET for avatars (run once)
-- ============================================================================
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars_public_read" on storage.objects;
drop policy if exists "avatars_user_write" on storage.objects;
drop policy if exists "avatars_user_update" on storage.objects;
drop policy if exists "avatars_user_delete" on storage.objects;
drop policy if exists "avatars_insert_owner_authenticated" on storage.objects;
drop policy if exists "avatars_update_owner" on storage.objects;
drop policy if exists "avatars_delete_owner" on storage.objects;

create policy "avatars_insert_owner_authenticated" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and auth.role() = 'authenticated');

create policy "avatars_update_owner" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and auth.role() = 'authenticated')
  with check (bucket_id = 'avatars' and auth.role() = 'authenticated');

create policy "avatars_delete_owner" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and auth.role() = 'authenticated');
