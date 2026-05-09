# HU7 – Publicar servicio de limpieza

## Historia de Usuario
**Como** cliente  
**Quiero** publicar una solicitud de servicio de limpieza  
**Para que** los aseadores puedan ver mi necesidad y cotizar  

## Criterios de Aceptación
- [x] El cliente puede seleccionar el tipo de servicio (limpieza).
- [x] Especificar cantidad de baños, cocinas, habitaciones (habitaciones/salas).
- [x] Agregar una descripción detallada del trabajo.
- [x] Seleccionar una fecha y hora preferida.
- [x] Ubicar la dirección en un mapa (OpenStreetMap) o ingresarla manualmente.
- [x] La dirección se guarda en la tabla `addresses` y se asocia al servicio.
- [x] El servicio se guarda en la tabla `services` con estado `open`.
- [x] Los detalles específicos de limpieza se guardan en `cleaning_details`.
- [x] Mensaje de éxito y redirección a la lista de servicios.

## Checklist de Desarrollo

### 1. Dominio (Pure Dart)
- [x] Entidad `ServiceAddress` (lib/features/services/domain/entities/service_address.dart)
- [x] Entidad `CleaningServiceDetail` (lib/features/services/domain/entities/cleaning_service_detail.dart)
- [x] Entidad `CleaningServiceRequest` (lib/features/services/domain/entities/cleaning_service_request.dart)
- [x] Interfaz `ServiceRepository` (lib/features/services/domain/repo/service_repository.dart)
- [x] Caso de uso `PublishCleaningServiceUseCase` (lib/features/services/domain/usecases/publish_cleaning_service_usecase.dart)

### 2. Datos (Supabase)
- [x] Modelos de datos (lib/features/services/data/models/)
- [x] `ServiceRemoteDataSource` (lib/features/services/data/sources/service_remote_data_source.dart)
- [x] `ServiceRepositoryImpl` (lib/features/services/data/repo/service_repository_impl.dart)

### 3. Presentación (BLoC + UI)
- [x] `ServicePublishBloc` (lib/features/services/ui/bloc/service_publish_bloc.dart)
- [x] Pantalla `PublishServiceScreen` (lib/features/services/ui/screens/publish_service_screen.dart)
- [x] Widgets de formulario (Counters, Pickers)
- [x] Integración de Mapas (OpenStreetMap vía `flutter_map`) y Dirección

### 4. Integración
- [x] Registro de rutas en `app_router.dart`
- [x] Navegación desde Home Cliente
- [x] Validación con `flutter analyze`

---

## Esquema de Datos Relacionado (Sprint 2)

- **Tabla `services`**: Almacena `category`, `title`, `description`, `preferred_date`, `preferred_time_start`.
- **Tabla `cleaning_details`**: Almacena `bathrooms`, `kitchens`, `bedrooms`, `living_rooms`, `includes_balcony`, `has_own_supplies`.
- **Tabla `addresses`**: Almacena la ubicación asociada al servicio.
