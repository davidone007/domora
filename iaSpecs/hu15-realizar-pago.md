# HU15 – Realizar pago

## Historia de Usuario
**Como** cliente  
**Quiero** pagar el servicio  
**Para** confirmar la contratación  

## Criterios de Aceptación
- [x] El cliente puede seleccionar un método de pago (Efectivo o Tarjeta - Mock).
- [x] Se registra la transacción en la tabla `payments`.
- [x] El estado de pago en el `booking` asociado se actualiza a `paid`.
- [x] Se muestra una pantalla de éxito tras completar el proceso.
- [x] Solo el cliente que realizó la reserva puede realizar el pago.
- [x] UI consistente con los colores y tipografía de Domora.

## Checklist de Desarrollo

### 1. Infraestructura (Supabase)
- [x] **Tabla `payments`:** Crear la tabla para registrar las transacciones. (Instrucción SQL proporcionada en el archivo `supabase_payments_hu15.sql`).

### 2. Dominio (Pure Dart)
- [x] Entidad `Payment` (lib/features/proposals/domain/entities/payment.dart).
- [x] Interfaz `PaymentRepository` con el método `processPayment(Payment payment)`.
- [x] Caso de uso `ProcessPaymentUseCase` (lib/features/proposals/domain/usecases/process_payment_usecase.dart).

### 3. Datos (Supabase)
- [x] Modelo `PaymentModel`.
- [x] `PaymentRemoteDataSource` para insertar en `payments` y actualizar `bookings.payment_status`.
- [x] Implementación de `PaymentRepositoryImpl`.

### 4. Presentación (BLoC + UI)
- [x] Crear `PaymentBloc`:
    - Evento `ProcessPaymentRequestedEvent`.
    - Estados: `initial`, `loading`, `success`, `error`.
- [x] Pantalla `PaymentSelectionScreen`:
    - Resumen del servicio y precio.
    - Opciones visuales para "Efectivo" y "Tarjeta de Crédito".
    - Formulario mock para tarjeta (Número, Fecha, CVV).
- [x] Pantalla `PaymentSuccessScreen`:
    - Animación de éxito (Check verde).
    - Botón para volver a "Mis Solicitudes".

### 5. Integración
- [x] Navegación: Después de aceptar una propuesta (HU14), redirigir a `PaymentSelectionScreen`.
- [x] Registro de dependencias en `app_router.dart`.
- [x] Validación con `flutter analyze`.

---

## Guía de Pruebas (UI)
1. **Acceso:** Aceptar una propuesta en la pantalla de propuestas. La app debe navegar automáticamente a la selección de pago.
2. **Selección:** Elegir "Tarjeta de Crédito".
3. **Formulario:** Ingresar datos ficticios y presionar "Pagar".
4. **Validación UI:**
    - Verificar overlay de carga.
    - Verificar transición a la pantalla de éxito.
5. **Verificación DB:**
    - Comprobar que en la tabla `payments` existe el nuevo registro con el monto correcto.
    - Comprobar que en la tabla `bookings`, el campo `payment_status` de la reserva es `paid`.
