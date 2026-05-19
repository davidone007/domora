# HU11 – Enviar propuesta (cotización)

## Historia de Usuario
**Como** aseador (proveedor)  
**Quiero** enviar una propuesta con precio y tiempo estimado  
**Para** trabajar en el servicio y ser seleccionado  

## Criterios de Aceptación
- [ ] El proveedor puede ingresar: precio (obligatorio), tiempo estimado (opcional) y un mensaje opcional.
- [ ] La propuesta se guarda en la tabla `quotes` (referenciada como proposals en la lógica) con estado `pending`.
- [ ] El proveedor no puede enviar más de una propuesta por servicio.
- [ ] Se muestra mensaje de éxito y se redirige al detalle del servicio.
- [ ] UI consistente con Domora (DM Sans, Colores institucionales).

## Checklist de Desarrollo

### 1. Dominio (Pure Dart)
- [x] Entidad `Proposal` (lib/features/proposals/domain/entities/proposal.dart)
- [x] Interfaz `ProposalRepository` (lib/features/proposals/domain/repo/proposal_repository.dart)
- [x] Caso de uso `SendProposalUseCase` (lib/features/proposals/domain/usecases/send_proposal_usecase.dart)
- [x] Caso de uso `CheckUserProposalUseCase`

### 2. Datos (Supabase)
- [x] Modelo `ProposalModel` (lib/features/proposals/data/models/proposal_model.dart)
- [x] `ProposalRemoteDataSource` (lib/features/proposals/data/sources/proposal_remote_data_source.dart)
- [x] `ProposalRepositoryImpl` (lib/features/proposals/data/repo/proposal_repository_impl.dart)

### 3. Presentación (BLoC + UI)
- [x] `ProposalSendBloc` (lib/features/proposals/ui/bloc/proposal_send_bloc.dart)
- [x] Pantalla `SendProposalScreen` (lib/features/proposals/ui/screens/send_proposal_screen.dart)
- [x] Integración en `ServiceDetailScreen`

### 4. Integración
- [x] Registro de ruta en `app_router.dart`
- [x] Navegación y validación de estado previo.
- [x] Validación con `flutter analyze`
