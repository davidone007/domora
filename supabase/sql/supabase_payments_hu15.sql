-- ============================================================================
-- DOMORA - PAYMENTS TABLE FOR HU15
-- Run this in the Supabase SQL Editor.
-- ============================================================================

create table if not exists public.payments (
  id               uuid primary key default uuid_generate_v4(),
  booking_id       uuid not null references public.bookings(id) on delete cascade,
  client_id        uuid not null references public.users(id),
  amount           decimal(10,2) not null,
  payment_method   varchar(50) not null, -- 'cash', 'card'
  status           varchar(50) not null default 'completed',
  transaction_id   varchar(255),
  created_at       timestamptz not null default now()
);

-- RLS para payments
alter table public.payments enable row level security;

drop policy if exists "users_select_own_payments" on public.payments;
create policy "users_select_own_payments" 
  on public.payments 
  for select 
  to authenticated
  using (auth.uid() = client_id);

drop policy if exists "users_insert_own_payments" on public.payments;
create policy "users_insert_own_payments" 
  on public.payments 
  for insert 
  to authenticated
  with check (auth.uid() = client_id);

-- Dar permisos de acceso al rol de servicio
grant all on table public.payments to service_role;
grant all on table public.payments to authenticated;
