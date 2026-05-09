# HU7 – Publicar servicio de limpieza

## Historia de Usuario
**Como** cliente  
**Quiero** publicar una solicitud de servicio de limpieza  
**Para que** los aseadores puedan ver mi necesidad y cotizar  

## Criterios de Aceptación
- [ ] El cliente puede seleccionar el tipo de servicio (limpieza).
- [ ] Especificar cantidad de baños, cocinas, habitaciones (habitaciones/salas).
- [ ] Agregar una descripción detallada del trabajo.
- [ ] Seleccionar una fecha y hora preferida.
- [ ] Ubicar la dirección en un mapa o ingresarla manualmente.
- [ ] La dirección se guarda en la tabla `addresses` y se asocia al servicio.
- [ ] El servicio se guarda en la tabla `services` con estado `open`.
- [ ] Los detalles específicos de limpieza se guardan en `cleaning_details`.
- [ ] Mensaje de éxito y redirección a la lista de servicios.

## Checklist de Desarrollo

### 1. Dominio (Pure Dart)
- [ ] Entidad `ServiceAddress` (lib/features/services/domain/entities/service_address.dart)
- [ ] Entidad `CleaningServiceDetail` (lib/features/services/domain/entities/cleaning_service_detail.dart)
- [ ] Entidad `CleaningServiceRequest` (lib/features/services/domain/entities/cleaning_service_request.dart)
- [ ] Interfaz `ServiceRepository` (lib/features/services/domain/repo/service_repository.dart)
- [ ] Caso de uso `PublishCleaningServiceUseCase` (lib/features/services/domain/usecases/publish_cleaning_service_usecase.dart)

### 2. Datos (Supabase)
- [ ] Modelos de datos (lib/features/services/data/models/)
- [ ] `ServiceRemoteDataSource` (lib/features/services/data/sources/service_remote_data_source.dart)
- [ ] `ServiceRepositoryImpl` (lib/features/services/data/repo/service_repository_impl.dart)

### 3. Presentación (BLoC + UI)
- [ ] `ServicePublishBloc` (lib/features/services/ui/bloc/service_publish_bloc.dart)
- [ ] Pantalla `PublishServiceScreen` (lib/features/services/ui/screens/publish_service_screen.dart)
- [ ] Widgets de formulario (Counters, Pickers)
- [ ] Integración de Mapas (OpenStreetMap vía `flutter_map`) y Dirección

### 4. Integración
- [ ] Registro de rutas en `app_router.dart`
- [ ] Navegación desde Home Cliente
- [ ] Validación con `flutter analyze`

---

## Esquema de Datos Relacionado (Sprint 2)

- **Tabla `services`**: Almacena `category`, `title`, `description`, `preferred_date`, `preferred_time_start`.
- **Tabla `cleaning_details`**: Almacena `bathrooms`, `kitchens`, `bedrooms`, `living_rooms`, `includes_balcony`, `has_own_supplies`.
- **Tabla `addresses`**: Almacena la ubicación asociada al servicio.
