# HU17 – Calificar servicio

## Historia de Usuario
**Como** cliente  
**Quiero** dejar feedback sobre el servicio recibido  
**Para** evaluar al aseador y ayudar a otros usuarios con mi experiencia.

## Criterios de Aceptación
- [ ] El cliente puede calificar servicios con estado `completed` (HU16).
- [ ] La calificación consiste en un rating (1-5 estrellas) y un comentario opcional.
- [ ] Solo el cliente que realizó la reserva puede dejar la calificación.
- [ ] No se puede calificar el mismo servicio más de una vez.
- [ ] Una vez enviada, el botón "Calificar" desaparece de la tarjeta de actividad.
- [ ] UI consistente con Domora y feedback visual de éxito.

## Checklist de Desarrollo

### 1. Infraestructura (Supabase)
- [x] **Políticas RLS:** Añadir seguridad a la tabla `reviews`. (SQL proporcionado en `supabase_reviews_rls.sql`).

### 2. Dominio (Pure Dart)
- [x] Entidad `Review` (lib/features/proposals/domain/entities/review.dart).
- [x] Interfaz `ReviewRepository` con `sendReview(Review review)` y `getReviewByBookingId(String bookingId)`.
- [x] Caso de uso `SendReviewUseCase`.
- [x] Caso de uso `CheckBookingReviewUseCase`.

### 3. Datos (Supabase)
- [x] Modelo `ReviewModel`.
- [x] `ReviewRemoteDataSource` para operaciones CRUD en Supabase.
- [x] Implementación de `ReviewRepositoryImpl`.

### 4. Presentación (BLoC + UI)
- [x] `ReviewBloc`: Maneja el estado de envío y verificación de calificación previa.
- [x] Pantalla `RatingScreen`: Selector de 5 estrellas interactivo y campo de comentarios.
- [x] Actualizar `BookingActivityScreen`: Añadir botón "Calificar" condicional.

### 5. Integración
- [x] Registro de ruta en `app_router.dart` (`/rate-service/:bookingId`).
- [x] Validación con `flutter analyze`.

---

## Guía de Pruebas (UI)
1. **Acceso:** Ir a "Actividad" y seleccionar un servicio completado.
2. **Navegación:** Pulsar "Calificar" para abrir la nueva pantalla.
3. **Acción:** Seleccionar un rating, escribir un comentario y enviar.
4. **Validación:** Confirmar el mensaje de éxito y la desaparición del botón en la lista.
