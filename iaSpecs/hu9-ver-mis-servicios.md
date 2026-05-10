# HU9 – Ver mis servicios

## Historia de Usuario
**Como** cliente  
**Quiero** ver todos mis servicios publicados  
**Para** gestionarlos y dar seguimiento  

## Criterios de Aceptación
- [ ] Lista de servicios del cliente autenticado.
- [ ] Cada servicio muestra: título, fecha de publicación, estado y cantidad de propuestas.
- [ ] Los servicios se ordenan del más reciente al más antiguo.
- [ ] Se puede hacer tap en un servicio para ver su detalle.
- [ ] Estado visual:
  - `open` (activo)
  - `in_progress` (en proceso)
  - `completed` (completado)
  - `cancelled` (cancelado)

## Checklist de Desarrollo

### 1. Dominio (Pure Dart)
- [x] Entidad `Service` (lib/features/services/domain/entities/service.dart)
- [x] Actualizar `ServiceRepository` con método `getMyServices`
- [x] Caso de uso `GetMyServicesUseCase` (lib/features/services/domain/usecases/get_my_services_usecase.dart)

### 2. Datos (Supabase)
- [x] Actualizar `ServiceRemoteDataSource` para consultar servicios con conteo de propuestas.
- [x] Actualizar `ServiceRepositoryImpl`
- [x] Modelo `ServiceModel` con mapeo de respuesta.

### 3. Presentación (BLoC + UI)
- [x] `MyServicesBloc` (lib/features/services/ui/bloc/my_services_bloc.dart)
- [x] Pantalla `MyServicesScreen` (lib/features/services/ui/screens/my_services_screen.dart)
- [x] Widget `ServiceCard` (lib/features/services/ui/widgets/service_card.dart)
- [x] Filtros por estado (Chips)
- [x] Pull-to-refresh

### 4. Integración
- [x] Registro de ruta en `app_router.dart`
- [x] Navegación desde `MainShell` (Solicitudes)
- [x] Validación con `flutter analyze`
