# HU9.1 – Vista de servicios por rol (Cliente/Proveedor)

## Historia de Usuario
**Como** usuario (cliente o proveedor)  
**Quiero** ver una lista de servicios relevante a mi rol en la pestaña de Solicitudes  
**Para** gestionar mis pedidos (cliente) o encontrar oportunidades de trabajo (proveedor)  

## Criterios de Aceptación
- [ ] El **Cliente** visualiza únicamente los servicios que ha publicado él mismo.
- [ ] El **Proveedor** visualiza todos los servicios publicados por cualquier cliente que estén en estado `open`.
- [ ] Los servicios se muestran ordenados del más reciente al más antiguo.
- [ ] La UI adapta los textos según el rol:
    - Cliente: Título "Mis Solicitudes", mensaje vacío "Aún no has publicado solicitudes".
    - Proveedor: Título "Servicios Disponibles", mensaje vacío "No hay servicios disponibles en este momento".
- [ ] El filtrado por estado (Chips) funciona para ambos roles sobre su respectiva lista de servicios.

## Checklist de Desarrollo

### 1. Dominio (Pure Dart)
- [ ] Actualizar `ServiceRepository` con el método `getAllAvailableServices()`.
- [ ] Crear el caso de uso `GetAllServicesUseCase` (lib/features/services/domain/usecases/get_all_services_usecase.dart).

### 2. Datos (Supabase)
- [ ] Implementar `getAllAvailableServices()` en `ServiceRemoteDataSource`:
    - Consulta a la tabla `services` sin filtro de `client_id`.
    - Incluir conteo de propuestas (`quotes(count)`).
    - Ordenar por `created_at` DESC.
- [ ] Implementar el nuevo método en `ServiceRepositoryImpl`.

### 3. Presentación (BLoC + UI)
- [ ] Actualizar `MyServicesBloc`:
    - Inyectar `GetAllServicesUseCase`.
    - Modificar `FetchMyServicesEvent` para recibir el rol del usuario.
    - Implementar lógica condicional: si es proveedor, usar `GetAllServicesUseCase`; si es cliente, usar `GetMyServicesUseCase`.
    - Almacenar el rol en el `MyServicesState`.
- [ ] Refactorizar `MyServicesScreen`:
    - Obtener el rol del usuario actual.
    - Adaptar el título del `AppBar` y los mensajes de "Empty State" según el rol.
    - Asegurar que el `RefreshIndicator` llame al evento de carga con el rol correcto.

### 4. Integración
- [ ] Actualizar `app_router.dart`:
    - Pasar las dependencias necesarias al `MyServicesBloc`.
- [ ] Validación con `flutter analyze`.
