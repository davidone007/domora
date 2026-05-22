# HU14 – Aceptar propuesta

## Historia de Usuario
**Como** cliente  
**Quiero** aceptar una propuesta  
**Para** confirmar el servicio  

## Criterios de Aceptación
- [ ] El cliente puede seleccionar una propuesta específica desde la lista de propuestas recibidas (HU12).
- [ ] Solo el creador del servicio (Cliente) puede realizar esta acción.
- [ ] Al pulsar "Aceptar", se solicita una confirmación explícita al usuario.
- [ ] **Acción Atómica (Transacción via RPC):**
    - Se crea un registro en la tabla `bookings` con los datos de la propuesta y estado `pending`.
    - La propuesta seleccionada en `quotes` cambia su estado a `accepted`.
    - Todas las demás propuestas del mismo servicio en `quotes` cambian su estado a `rejected`.
    - El servicio en `services` cambia su estado a `in_progress`.
- [ ] Feedback visual claro (Loading y Success/Error) y actualización inmediata de la UI.
- [ ] UI consistente con los colores y tipografía de Domora.

## Checklist de Desarrollo

### 1. Infraestructura (Supabase)
- [x] **Función RPC (Postgres):** Crear la función `accept_quote` para manejar la lógica atómica. (Instrucción SQL proporcionada en el plan).

### 2. Dominio (Pure Dart)
- [x] Entidad `Booking` (lib/features/proposals/domain/entities/booking.dart).
- [x] Actualizar `ProposalRepository` con `acceptProposal(Proposal proposal)`.
- [x] Caso de uso `AcceptProposalUseCase` (lib/features/proposals/domain/usecases/accept_proposal_usecase.dart).

### 3. Datos (Supabase)
- [x] Modelo `BookingModel` (si es necesario para mapeo posterior).
- [x] Actualizar `ProposalRemoteDataSource` para llamar a la función RPC `accept_quote`.
- [x] Implementar el nuevo método en `ProposalRepositoryImpl`.

### 4. Presentación (BLoC + UI)
- [x] Actualizar `ServiceProposalsBloc`:
    - Evento `AcceptProposalRequestedEvent`.
    - Estado de carga y éxito específico para la aceptación.
- [x] Actualizar `ProposalCard`:
    - Botón "Aceptar Propuesta" (visible solo si la propuesta es `pending` y el usuario es el cliente dueño).
- [x] Implementar diálogo de confirmación en `ServiceProposalsScreen`.

### 5. Integración
- [x] Registrar el caso de uso en `app_router.dart`.
- [x] Validación con `flutter analyze`.

---

## Guía de Pruebas (UI)
1. **Acceso:** Entrar como Cliente y ver las propuestas de uno de sus servicios.
2. **Selección:** Elegir una propuesta y presionar "Aceptar Propuesta".
3. **Confirmación:** Confirmar en el diálogo emergente.
4. **Validación:** 
   - La lista debe actualizarse: la propuesta aceptada debe decir "Aceptada" y las demás "Rechazada".
   - El botón de aceptar debe desaparecer.
   - Al volver al detalle del servicio, el estado debe ser "En progreso".
5. **Persistencia:** Recargar la pantalla y verificar que los estados se mantienen.
