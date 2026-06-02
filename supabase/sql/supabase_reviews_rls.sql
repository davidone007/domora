-- ============================================================================
-- DOMORA - RLS POLICIES FOR REVIEWS (HU17)
-- Run this in the Supabase SQL Editor.
-- ============================================================================

alter table public.reviews enable row level security;

-- Permite que cualquier usuario autenticado vea las reseñas (para perfiles públicos)
drop policy if exists "users_select_reviews" on public.reviews;
create policy "users_select_reviews" 
  on public.reviews
  for select 
  to authenticated 
  using (true);

-- Permite que un cliente inserte una reseña SOLO si el booking le pertenece
drop policy if exists "clients_insert_reviews" on public.reviews;
create policy "clients_insert_reviews" 
  on public.reviews
  for insert 
  to authenticated 
  with check (
    exists (
      select 1 from public.bookings
      where id = booking_id and client_id = auth.uid()
    )
  );

-- Permisos de acceso
grant all on table public.reviews to service_role;
grant all on table public.reviews to authenticated;
