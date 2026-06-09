# HU18 – Recibir notificaciones

## Historia de Usuario
**Como** usuario (Cliente o Proveedor)  
**Quiero** recibir notificaciones  
**Para** estar informado sobre el estado de mis servicios y propuestas en tiempo real.

## Criterios de Aceptación
- [x] Integración de **Firebase Cloud Messaging (FCM)** para recibir alertas push.
- [x] Configuración nativa de Android utilizando estrictamente **Kotlin DSL (`.gradle.kts`)**.
- [x] Las notificaciones se persisten en la tabla `notifications` de Supabase (ya existente en el esquema).
- [x] El usuario puede ver una lista de sus notificaciones en la app.
- [x] Opción de marcar notificaciones como leídas.
- [x] El icono de la campana en el dashboard muestra un badge con el conteo de no leídas.
- [x] UI consistente con Domora (DM Sans, Colores institucionales) y accesible desde el Dashboard.

## Checklist de Desarrollo

### 1. Configuración Nativa (Android - Kotlin DSL)
- [x] **Google Services JSON:** Mover `google-services.json` desde la raíz a `android/app/`.
- [x] **Root `android/settings.gradle.kts`:** Actualizar plugin a versión `4.4.4`.
- [x] **App `android/app/build.gradle.kts`:** 
    - Asegurar aplicación de plugin `com.google.gms.google-services`.
    - Añadir dependencias de Firebase Messaging y BoM `34.14.0`.

### 2. Infraestructura (Supabase)
- [x] Asegurar políticas RLS para la tabla `notifications` (usuarios solo ven lo propio).
- [x] Configurar registro de tokens FCM en una columna `fcm_token` en la tabla `users` (o tabla dedicada).

### 3. Dominio (Pure Dart)
- [x] Entidad `AppNotification` (lib/features/notifications/domain/entities/app_notification.dart).
- [x] Interfaz `NotificationRepository`.
- [x] Casos de uso: `GetNotificationsUseCase`, `MarkNotificationAsReadUseCase`, `RegisterFcmTokenUseCase`.

### 4. Datos (Supabase + FCM)
- [x] Modelo `NotificationModel`.
- [x] `NotificationRemoteDataSource` (Supabase + Firebase Messaging).
- [x] Implementación de `NotificationRepositoryImpl`.

### 5. Presentación (BLoC + UI)
- [x] `NotificationBloc`: Gestiona la lista de notificaciones, el contador de no leídas y la recepción en primer plano.
- [x] Pantalla `NotificationsScreen`: Lista de alertas con iconos dinámicos según el tipo.
- [x] Actualizar `DashboardHeader`: Vincular la campana a la nueva pantalla y pasar el estado del badge.

### 6. Integración
- [x] Registro de ruta `/notifications` en `app_router.dart`.
- [x] Inicialización de Firebase en `main.dart`.
- [x] Validación con `flutter analyze`.

---

## Guía de Pruebas (UI)
1. **Acceso:** Iniciar sesión y pulsar el icono de la campana en el Dashboard.
2. **Visualización:** Verificar que se cargue la lista de mensajes (si existen) con su fecha relativa.
3. **Acción:** Tocar una notificación no leída; debería cambiar visualmente su estado a "leída" y el contador de la campana debería disminuir.
4. **Push Real:** Enviar un mensaje de prueba desde la consola de Firebase y verificar la llegada del aviso.
5. **Real-time In-app:** Insertar una fila manualmente en la tabla `notifications` de Supabase y observar el cambio inmediato en la app (si se usa Supabase Realtime).
