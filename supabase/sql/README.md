# Scripts SQL de Domora

Scripts para ejecutar manualmente en el **SQL Editor de Supabase**. Están ordenados por sprint/HU. Para una base de datos nueva, ejecútalos en este orden.

> Las **migraciones versionadas** del flujo de push (HU18) viven aparte en
> [`../migrations/`](../migrations) y las gestiona el Supabase CLI
> (`supabase db push`). La Edge Function está en [`../functions/`](../functions).

| Orden | Archivo | Propósito |
|-------|---------|-----------|
| 1 | `supabase_schema.sql` | Esquema base del Sprint 1: `roles`, `users`, `user_roles`, `client_profiles`, `provider_profiles`, `addresses`, RLS, bucket `avatars` y trigger `handle_new_user()`. |
| 2 | `supabase_schema_sprint2.sql` | Tablas del marketplace (Sprint 2 y 3): `services`, `cleaning_details`, `service_images`, `quotes`, `bookings`. |
| 3 | `supabase_rpc_hu14.sql` | RPC `accept_quote` (HU14): crea el `booking`, marca la propuesta `accepted`, el servicio `in_progress` y rechaza las demás propuestas, de forma transaccional. |
| 4 | `supabase_payments_hu15.sql` | Tabla `payments` (HU15) y su RLS. |
| 5 | `supabase_rpc_hu16.sql` | RPC `complete_booking` (HU16): marca el servicio/booking como `completed`. |
| 6 | `supabase_reviews_rls.sql` | Tabla `reviews` y políticas RLS (HU17). |
| 7 | `supabase_notifications_hu18.sql` | Tabla `notifications` y su RLS (HU18). |
| 8 | `supabase_notifications_automation.sql` | Triggers que insertan notificaciones automáticamente (nuevo servicio, propuesta recibida/aceptada, etc.) (HU18). |

## Diagnóstico

- `supabase_notifications_diagnostic.sql` — consultas de solo lectura para verificar que el pipeline de notificaciones/push está bien configurado (tokens FCM registrados, triggers activos, etc.).
