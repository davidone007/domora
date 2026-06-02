# HU18 – Plan de Implementación: Notificaciones Completas

## Diagnóstico Final

| Capa | Estado | Detalle |
|---|---|---|
| Android Gradle + `google-services.json` | ✅ Hecho | |
| `firebase_options.dart` + `main.dart` | ✅ Hecho | Corregido esta sesión |
| `FcmService.initialize()` post-login/splash | ✅ Hecho | |
| `NotificationBloc` + stream en tiempo real | ✅ Hecho | |
| `NotificationsScreen` + badge en campana | ✅ Hecho | |
| Código de Edge Function | ✅ Hecho | Sin desplegar |
| Columna `users.fcm_token` | ❌ Falta | Token nunca se persiste → no hay push |
| **Triggers de notificación (BD)** | ❌ Falta | **CRÍTICO: nada escribe en `notifications`** |
| Edge Function desplegada | ❌ Falta | Requiere CLI |
| Secretos Firebase en Supabase | ❌ Falta | Requiere CLI |
| Webhook de base de datos | ❌ Falta | Requiere Dashboard |

**Causa raíz:** La tabla `notifications` nunca recibe filas. Sin ellas, el stream en tiempo real no dispara, el badge nunca se actualiza y el webhook nunca llama a la Edge Function para enviar el push.

---

## Checklist de Desarrollo

### Fase 1 – Código (hecho automáticamente)

- [x] `main.dart`: `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
- [x] `main.dart`: importar `firebase_options.dart`
- [x] `notification_remote_data_source.dart`: limpiar `try/catch` silencioso en `updateFcmToken`
- [x] `supabase/migrations/20260601000000_add_fcm_token_to_users.sql`: columna `fcm_token TEXT` en `users`
- [x] `supabase/migrations/20260601000001_notification_triggers.sql`: 4 triggers de BD

  Los triggers cubren:
  - `AFTER INSERT ON quotes` → notifica al **cliente** (`proposal_received`)
  - `AFTER UPDATE ON quotes WHERE status = 'accepted'` → notifica al **proveedor** (`service_accepted`)
  - `AFTER INSERT ON payments` → notifica al **proveedor** (`payment_confirmed`)
  - `AFTER UPDATE ON bookings WHERE status = 'completed'` → notifica al **cliente** (`service_completed`)

---

### Fase 2 – Base de Datos (tú debes hacer esto)

> Ir a **Supabase Dashboard → SQL Editor** y ejecutar en orden:

- [ ] **Paso 2.1** – Ejecutar el contenido de `supabase/migrations/20260601000000_add_fcm_token_to_users.sql`
  ```sql
  ALTER TABLE public.users ADD COLUMN IF NOT EXISTS fcm_token TEXT;
  ```

- [ ] **Paso 2.2** – Ejecutar el contenido de `supabase/migrations/20260601000001_notification_triggers.sql`
  (copiar y pegar el archivo completo en el SQL Editor)

- [ ] **Paso 2.3** – Verificar RLS en `notifications` (ya debe estar): confirmar que existe una policy que permite `SELECT/INSERT` solo para el propio `user_id`. Si no existe, ejecutar:
  ```sql
  ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
  
  CREATE POLICY "users_own_notifications" ON notifications
    FOR ALL USING (auth.uid() = user_id);
  ```

---

### Fase 3 – Edge Function (tú debes hacer esto)

- [ ] **Paso 3.1** – Instalar Supabase CLI (si no está):
  ```
  npm install -g supabase
  ```

- [ ] **Paso 3.2** – Vincular el proyecto (reemplaza `<ref>` con el ID de tu proyecto, visible en la URL del Dashboard: `app.supabase.com/project/<ref>`):
  ```
  supabase link --project-ref <ref>
  ```

- [ ] **Paso 3.3** – Configurar secretos de Firebase:
  ```powershell
  supabase secrets set FIREBASE_PROJECT_ID=domora-9b1a8
  $sa = (Get-Content "domora-9b1a8-firebase-adminsdk-fbsvc-1ba8a18b19.json" -Raw) -replace "`r`n","" -replace "`n",""
  supabase secrets set "FIREBASE_SERVICE_ACCOUNT=$sa"
  ```

- [ ] **Paso 3.4** – Desplegar la Edge Function:
  ```
  supabase functions deploy send-push-notification
  ```

---

### Fase 4 – Webhook de Base de Datos (tú debes hacer esto)

> Ir a **Supabase Dashboard → Database → Webhooks → Create a new hook**

- [ ] **Paso 4.1** – Configurar el webhook:
  - **Name:** `on_notification_insert`
  - **Table:** `notifications`
  - **Events:** `INSERT`
  - **Type:** Supabase Edge Functions
  - **Edge Function:** `send-push-notification`
  - **HTTP Headers:** `Authorization: Bearer <tu SUPABASE_SERVICE_ROLE_KEY>`
    (la encuentras en **Project Settings → API → service_role key**)

---

### Fase 5 – Verificación

- [ ] **Paso 5.1** – Reinstalar la app en el emulador (para que el token FCM se solicite de nuevo):
  ```
  flutter run
  ```

- [ ] **Paso 5.2** – Iniciar sesión con el usuario **cliente** y el usuario **proveedor**. Verificar en el SQL Editor que ambos tienen token:
  ```sql
  SELECT id, email, fcm_token FROM users;
  ```
  Ambas filas deben tener `fcm_token` no nulo.

- [ ] **Paso 5.3** – Prueba in-app (realtime): Insertar manualmente en el SQL Editor:
  ```sql
  INSERT INTO notifications(user_id, type, title, message)
  VALUES ('<user_id_del_cliente>', 'proposal_received', 'Prueba', 'Mensaje de prueba');
  ```
  La campana en el dashboard del cliente debe actualizarse en segundos sin recargar.

- [ ] **Paso 5.4** – Prueba push (OS banner): Con la app del **proveedor en background**, el **cliente acepta una propuesta**. Debe aparecer una notificación del sistema en el dispositivo del proveedor.

- [ ] **Paso 5.5** – Verificar logs de la Edge Function si algo falla:
  ```
  supabase functions logs send-push-notification
  ```

---

## Flujo Completo (end-to-end)

```
[Proveedor envía propuesta]
        ↓
INSERT quotes
        ↓
Trigger fn_notify_proposal_received
        ↓
INSERT notifications (user_id = cliente)
        ↓
Webhook Supabase → Edge Function send-push-notification
        ↓
Edge Function lee users.fcm_token del cliente
        ↓
POST FCM HTTP v1 API
        ↓
OS banner en el teléfono del cliente 📱

[Simultáneamente]
Supabase Realtime stream → NotificationBloc → badge actualizado en campana
```

---

## Alcance (fuera de esta iteración)

- iOS: requiere APNs key en Firebase Console + `GoogleService-Info.plist` + push capability en `Info.plist`.
- Notificaciones locales con `flutter_local_notifications`: **no requerido** — la arquitectura actual maneja correctamente las notificaciones en foreground vía el stream en tiempo real.
