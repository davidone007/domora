# HU12 – Ver propuestas recibidas

## Historia de Usuario
**Como** cliente  
**Quiero** ver todas las propuestas de mis servicios publicados  
**Para** comparar y elegir al aseador  

## Criterios de Aceptación
- [ ] Lista de propuestas para un servicio específico.
- [ ] Cada propuesta muestra: nombre del aseador, precio, tiempo estimado y mensaje.
- [ ] Las propuestas se pueden visualizar ordenadas (por defecto por fecha o precio).
- [ ] El cliente puede ver el perfil del aseador desde la propuesta.
- [ ] Se muestra el estado de cada propuesta: `pending`, `accepted`, `rejected`.
- [ ] UI consistente con Domora (DM Sans, Colores institucionales).

## Checklist de Desarrollo

### 1. Dominio (Pure Dart)
- [x] Entidad `ProposalWithProvider` (lib/features/proposals/domain/entities/proposal_with_provider.dart) que combine datos de `Proposal` y del perfil del proveedor.
- [x] Actualizar `ProposalRepository` con `getProposalsByServiceId` (lib/features/proposals/domain/repo/proposal_repository.dart).
- [x] Caso de uso `GetProposalsByServiceUseCase` (lib/features/proposals/domain/usecases/get_proposals_by_service_usecase.dart).

### 2. Datos (Supabase)
- [x] Modelo `ProposalWithProviderModel` (lib/features/proposals/data/models/proposal_with_provider_model.dart).
- [x] Actualizar `ProposalRemoteDataSource` con consulta relacional (quotes + users + provider_profiles).
- [x] Implementar en `ProposalRepositoryImpl` el mapeo a la nueva entidad.

### 3. Presentación (BLoC + UI)
- [x] `ServiceProposalsBloc` (lib/features/proposals/ui/bloc/service_proposals_bloc.dart) para manejar estados de carga y ordenamiento.
- [x] Pantalla `ServiceProposalsScreen` (lib/features/proposals/ui/screens/service_proposals_screen.dart).
- [x] Widget `ProposalCard` (lib/features/proposals/ui/widgets/proposal_card.dart) con diseño de tarjeta limpia.
- [x] Implementar lógica de ordenamiento por precio/fecha en el BLoC o UI.

### 4. Integración
- [x] Registro de ruta en `app_router.dart` (`/service-proposals/:serviceId`).
- [x] Navegación desde `ServiceDetailScreen` (botón "Ver propuestas").
- [x] Validación con `flutter analyze`.


---

## Guía de Pruebas (UI)
1. **Acceso:** Desde "Mis Solicitudes" (Home Cliente -> Solicitudes), seleccionar un servicio que ya tenga propuestas (se ve el contador en la tarjeta).
2. **Navegación:** En el detalle del servicio, pulsar el botón inferior "Ver propuestas".
3. **Visualización:** Verificar que aparezca la lista de proveedores con:
    - Foto y Nombre.
    - Precio destacado en verde.
    - Tiempo estimado (si existe).
    - Mensaje de la propuesta.
4. **Interacción:** Al tocar el nombre o foto, debe (en el futuro) llevar al perfil (HU13). Por ahora puede mostrar un Snackbar o navegar si HU13 ya existe.
5. **Estado:** Verificar que se vea el badge de "Pendiente" o el estado correspondiente.
