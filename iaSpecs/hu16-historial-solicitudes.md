# HU16 – Ver historial en solicitudes

## Historia de Usuario
**Como** usuario (Cliente o Proveedor)  
**Quiero** ver el historial de mis servicios y reservas  
**Para** gestionar los trabajos terminados (Cliente) o cerrar los trabajos en curso (Proveedor).

## Criterios de Aceptación
- [ ] Sustituir la opción "Cupones" en la barra de navegación por una nueva opción (ej. "Actividad" o "Historial").
- [ ] **Para Clientes:**
    - Visualizar una lista de servicios que ya han sido **completados** (`status = 'completed'` en la tabla `bookings`).
    - Ver información básica: nombre del proveedor, precio final y fecha.
- [ ] **Para Proveedores:**
    - Visualizar una lista de servicios que le han sido **reservados** (`status = 'pending'` o `'confirmed'`).
    - El proveedor puede marcar un servicio como **"Finalizado"**.
    - Al finalizar, el estado en `bookings` cambia a `completed` y el estado en `services` también cambia a `completed`.
- [ ] Una vez que el proveedor finaliza el servicio, este desaparece de su lista de pendientes y aparece en el historial del cliente.
- [ ] UI consistente con Domora (DM Sans, Colores institucionales, Tarjetas limpias).

## Checklist de Desarrollo

### 1. Infraestructura (Supabase)
- [x] **Función RPC (Postgres):** Crear la función `complete_booking` para manejar el cierre atómico del servicio. (Instrucción SQL proporcionada en el archivo `supabase_rpc_hu16.sql`).

### 2. Dominio (Pure Dart)
- [x] Actualizar `BookingRepository` con los métodos para obtener reservas por rol y completar servicios.
- [x] Crear los casos de uso: `GetClientBookingHistoryUseCase`, `GetProviderActiveBookingsUseCase` y `CompleteBookingUseCase`.

### 3. Datos (Supabase)
- [x] Modelo `BookingWithService` para agrupar los datos necesarios de la reserva y el servicio asociado.
- [x] Implementar la consulta relacional en `BookingRemoteDataSource` y la lógica de cierre.

### 4. Presentation (BLoC + UI)
- [x] `BookingActivityBloc`: Gestiona la carga de datos según el rol y la ejecución de la acción "Finalizar".
- [x] `BookingActivityScreen`: Nueva pantalla que reemplaza a la de cupones.
- [x] Actualizar `MainShell` y `MainTab` para reflejar el cambio en la navegación.

### 5. Integración
- [x] Registro de rutas y dependencias en `app_router.dart`.

---

## Guía de Pruebas (UI)
1. **Acceso:** Tocar la tercera pestaña del Navbar (donde antes estaba Cupones).
2. **Rol Cliente:** Debería ver sus servicios pasados marcados como completados.
3. **Rol Proveedor:** Debería ver los servicios que tiene asignados (en progreso). Al presionar "Finalizar", la lista debe actualizarse.
