-- ============================================================================
-- DOMORA - SPRINT 2 & 3 SCHEMA
-- Additional tables for marketplace flow
-- Focused ONLY on data model (no RLS/security)
-- Compatible with existing Sprint 1 schema
-- ============================================================================

create extension if not exists "uuid-ossp";

-- ============================================================================
-- PERMISSIONS
-- ============================================================================

create table if not exists public.permissions (
  id          uuid primary key default uuid_generate_v4(),
  name        varchar(100) not null unique,
  resource    varchar(100) not null,
  action      varchar(50) not null,
  description varchar(255),
  created_at  timestamptz not null default now()
);

-- ============================================================================
-- ROLE_PERMISSIONS
-- ============================================================================

create table if not exists public.role_permissions (
  id            uuid primary key default uuid_generate_v4(),
  role_id       uuid not null references public.roles(id) on delete cascade,
  permission_id uuid not null references public.permissions(id) on delete cascade,
  created_at    timestamptz not null default now(),

  unique(role_id, permission_id)
);

create index if not exists idx_role_permissions_role_id
  on public.role_permissions(role_id);

create index if not exists idx_role_permissions_permission_id
  on public.role_permissions(permission_id);

-- ============================================================================
-- VERIFICATIONS
-- ============================================================================

create table if not exists public.verifications (
  id                     uuid primary key default uuid_generate_v4(),
  user_id                uuid not null unique references public.users(id) on delete cascade,
  identity_document_url  varchar(500),
  selfie_url             varchar(500),

  status                 varchar(50) not null default 'pending',

  verified_by            uuid references public.users(id) on delete set null,
  verified_at            timestamptz,

  rejection_reason       text,

  expires_at             timestamptz,

  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

create index if not exists idx_verifications_user_id
  on public.verifications(user_id);

create index if not exists idx_verifications_status
  on public.verifications(status);

-- ============================================================================
-- SERVICES
-- ============================================================================

create table if not exists public.services (
  id                     uuid primary key default uuid_generate_v4(),

  client_id              uuid not null
                          references public.users(id)
                          on delete cascade,

  address_id             uuid
                          references public.addresses(id)
                          on delete set null,

  category               varchar(100) not null,

  title                  varchar(255) not null,

  description            text,

  status                 varchar(50) not null default 'open',

  preferred_date         date,

  preferred_time_start   time,

  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

create index if not exists idx_services_client_id
  on public.services(client_id);

create index if not exists idx_services_address_id
  on public.services(address_id);

create index if not exists idx_services_status
  on public.services(status);

create index if not exists idx_services_category
  on public.services(category);

-- ============================================================================
-- SERVICE_IMAGES
-- ============================================================================

create table if not exists public.service_images (
  id            uuid primary key default uuid_generate_v4(),

  service_id    uuid not null
                 references public.services(id)
                 on delete cascade,

  image_url     varchar(500) not null,

  is_primary    boolean not null default false,

  caption       varchar(255),

  order_index   int not null default 0,

  created_at    timestamptz not null default now()
);

create index if not exists idx_service_images_service_id
  on public.service_images(service_id);

-- ============================================================================
-- CLEANING_DETAILS
-- ============================================================================

create table if not exists public.cleaning_details (
  id                   uuid primary key default uuid_generate_v4(),

  service_id           uuid not null unique
                       references public.services(id)
                       on delete cascade,

  bathrooms            int not null default 0,

  kitchens             int not null default 0,

  bedrooms             int not null default 0,

  living_rooms         int not null default 0,

  includes_balcony     boolean not null default false,

  has_own_supplies     boolean not null default false,

  supplies_notes       text,

  created_at           timestamptz not null default now()
);

create index if not exists idx_cleaning_details_service_id
  on public.cleaning_details(service_id);

-- ============================================================================
-- QUOTES
-- ============================================================================

create table if not exists public.quotes (
  id                     uuid primary key default uuid_generate_v4(),

  service_id             uuid not null
                         references public.services(id)
                         on delete cascade,

  provider_id            uuid not null
                         references public.users(id)
                         on delete cascade,

  price                  decimal(10,2) not null,

  estimated_hours        decimal(5,2),

  estimated_start_date   date,

  message                text,

  status                 varchar(50) not null default 'pending',

  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),

  unique(service_id, provider_id)
);

create index if not exists idx_quotes_service_id
  on public.quotes(service_id);

create index if not exists idx_quotes_provider_id
  on public.quotes(provider_id);

create index if not exists idx_quotes_status
  on public.quotes(status);

-- ============================================================================
-- BOOKINGS
-- ============================================================================

create table if not exists public.bookings (
  id                    uuid primary key default uuid_generate_v4(),

  quote_id              uuid not null unique
                         references public.quotes(id)
                         on delete cascade,

  service_id            uuid not null
                         references public.services(id)
                         on delete cascade,

  client_id             uuid not null
                         references public.users(id)
                         on delete cascade,

  provider_id           uuid not null
                         references public.users(id)
                         on delete cascade,

  status                varchar(50) not null default 'pending',

  final_price           decimal(10,2) not null,

  payment_method        varchar(50),

  payment_status        varchar(50) default 'pending',

  tip_amount            decimal(10,2) default 0,

  started_at            timestamptz,

  completed_at          timestamptz,

  cancelled_at          timestamptz,

  cancellation_reason   text,

  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create index if not exists idx_bookings_quote_id
  on public.bookings(quote_id);

create index if not exists idx_bookings_service_id
  on public.bookings(service_id);

create index if not exists idx_bookings_client_id
  on public.bookings(client_id);

create index if not exists idx_bookings_provider_id
  on public.bookings(provider_id);

create index if not exists idx_bookings_status
  on public.bookings(status);

-- ============================================================================
-- REVIEWS
-- ============================================================================

create table if not exists public.reviews (
  id                      uuid primary key default uuid_generate_v4(),

  booking_id              uuid not null unique
                          references public.bookings(id)
                          on delete cascade,

  rating                  int not null check (rating between 1 and 5),

  comment                 text,

  punctuality_rating      int check (punctuality_rating between 1 and 5),

  quality_rating          int check (quality_rating between 1 and 5),

  communication_rating    int check (communication_rating between 1 and 5),

  created_at              timestamptz not null default now()
);

create index if not exists idx_reviews_booking_id
  on public.reviews(booking_id);

-- ============================================================================
-- REVIEW_IMAGES
-- ============================================================================

create table if not exists public.review_images (
  id            uuid primary key default uuid_generate_v4(),

  review_id     uuid not null
                 references public.reviews(id)
                 on delete cascade,

  image_url     varchar(500) not null,

  created_at    timestamptz not null default now()
);

create index if not exists idx_review_images_review_id
  on public.review_images(review_id);

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

create table if not exists public.notifications (
  id                   uuid primary key default uuid_generate_v4(),

  user_id              uuid not null
                       references public.users(id)
                       on delete cascade,

  type                 varchar(100) not null,

  title                varchar(255) not null,

  message              text not null,

  related_service_id   uuid
                       references public.services(id)
                       on delete set null,

  related_quote_id     uuid
                       references public.quotes(id)
                       on delete set null,

  related_booking_id   uuid
                       references public.bookings(id)
                       on delete set null,

  is_read              boolean not null default false,

  created_at           timestamptz not null default now()
);

create index if not exists idx_notifications_user_id
  on public.notifications(user_id);

create index if not exists idx_notifications_is_read
  on public.notifications(is_read);

-- ============================================================================
-- FAVORITE_PROVIDERS
-- ============================================================================

create table if not exists public.favorite_providers (
  id             uuid primary key default uuid_generate_v4(),

  client_id      uuid not null
                 references public.users(id)
                 on delete cascade,

  provider_id    uuid not null
                 references public.users(id)
                 on delete cascade,

  created_at     timestamptz not null default now(),

  unique(client_id, provider_id)
);

create index if not exists idx_favorite_providers_client_id
  on public.favorite_providers(client_id);

create index if not exists idx_favorite_providers_provider_id
  on public.favorite_providers(provider_id);

-- ============================================================================
-- PORTFOLIO_ITEMS
-- ============================================================================

create table if not exists public.portfolio_items (
  id                    uuid primary key default uuid_generate_v4(),

  provider_id           uuid not null
                        references public.users(id)
                        on delete cascade,

  title                 varchar(255) not null,

  description           text,

  category              varchar(100),

  client_name           varchar(255),

  client_testimonial    text,

  is_featured           boolean not null default false,

  display_order         int not null default 0,

  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create index if not exists idx_portfolio_items_provider_id
  on public.portfolio_items(provider_id);

-- ============================================================================
-- PORTFOLIO_IMAGES
-- ============================================================================

create table if not exists public.portfolio_images (
  id                   uuid primary key default uuid_generate_v4(),

  portfolio_item_id    uuid not null
                       references public.portfolio_items(id)
                       on delete cascade,

  image_type           varchar(50),

  image_url            varchar(500) not null,

  created_at           timestamptz not null default now()
);

create index if not exists idx_portfolio_images_portfolio_item_id
  on public.portfolio_images(portfolio_item_id);
