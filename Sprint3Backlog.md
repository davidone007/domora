# Domora - Sprint Backlog 3

## Integrantes

* Andrés Felipe Cabezas Guerrero
* Nicolás Cuéllar Molina
* Davide Flamini Cazarán
* Miguel Angel Martínez Vidal
* Daron Andrés Mercado García
* Samuel Jose Rengifo Morales

---

# Objetivo del Sprint 3

Cerrar el ciclo transaccional del marketplace implementando la aceptación de propuestas, gestión de pagos, historial de servicios, calificaciones y un sistema de notificaciones para mejorar la comunicación y confianza en la plataforma.

---

# Resumen del Sprint Backlog 3

| EPIC                   | Historias         | Tareas estimadas |
| ---------------------- | ----------------- | ---------------- |
| Pagos y Reservas       | HU14, HU15        | 8                |
| Historial y Feedback   | HU16, HU17        | 6                |
| Notificaciones         | HU18              | 3                |
| **Total**              | **5 HUs**         | **17 tareas**    |

---

# EPIC: Pagos y Reservas

---

# HU14 – Aceptar propuesta

## Historia de usuario

**Como** cliente
**Quiero** aceptar una propuesta
**Para** confirmar el servicio

## Criterios de aceptación

* El cliente puede seleccionar una propuesta específica de la lista de recibidas.
* Al aceptar, se crea automáticamente un registro en la tabla `bookings`.
* El estado de la propuesta aceptada cambia a `accepted`.
* El estado del servicio cambia de `open` a `in_progress`.
* Las demás propuestas del mismo servicio cambian automáticamente a `rejected`.

## Tareas

### Task 1
* **Summary:** Crear tabla `bookings` en Supabase
* **Description:** Definir campos: `id`, `quote_id`, `service_id`, `client_id`, `provider_id`, `status`, `final_price`, `created_at`

### Task 2
* **Summary:** Crear endpoint/lógica para aceptar propuesta
* **Description:** Implementar transacción en base de datos que cree el booking y actualice estados de quotes y services

### Task 3
* **Summary:** Implementar lógica de estados en la UI
* **Description:** Reflejar el cambio de estado en el detalle del servicio y la lista de propuestas

---

# HU15 – Realizar pago

## Historia de usuario

**Como** cliente
**Quiero** pagar el servicio
**Para** confirmar la contratación

## Criterios de aceptación

* El cliente puede elegir entre método de pago efectivo o tarjeta (Mock).
* Se registra el pago en una tabla de `payments` asociada al booking.
* Se muestra una pantalla de confirmación de pago exitoso.

## Tareas

### Task 1
* **Summary:** Crear tabla `payments` en Supabase
* **Description:** Campos: `id`, `booking_id`, `amount`, `payment_method`, `status`, `transaction_id`

### Task 2
* **Summary:** Crear UI de selección de método de pago
* **Description:** Pantalla para elegir entre efectivo o tarjeta con ingreso de datos (Mock)

### Task 3
* **Summary:** Lógica de procesamiento de pago
* **Description:** Simular pasarela de pago y persistir el resultado en la DB

### Task 4
* **Summary:** Pantalla de éxito
* **Description:** UI de confirmación tras el pago exitoso

---

# EPIC: Historial y feedback

---

# HU16 – Ver historial

## Historia de usuario

**Como** usuario
**Quiero** ver servicios anteriores
**Para** revisar trabajos realizados o contratados

## Criterios de aceptación

* Lista de servicios cuyo estado sea `completed`.
* Muestra información básica: título del servicio, fecha, proveedor/cliente y precio final.
* Ordenados por fecha de finalización.

## Tareas

### Task 1
* **Summary:** Crear endpoint de historial
* **Description:** Query a la tabla `bookings` filtrando por estado `completed` y el ID del usuario

### Task 2
* **Summary:** Implementar pantalla de historial
* **Description:** UI con lista de tarjetas de servicios pasados

### Task 3
* **Summary:** Detalle del historial
* **Description:** Vista simplificada de los detalles de un servicio ya terminado

---

# HU17 – Calificar servicio

## Historia de usuario

**Como** cliente
**Quiero** dejar feedback
**Para** evaluar al aseador y ayudar a otros usuarios

## Criterios de aceptación

* El cliente puede asignar un rating (1 a 5 estrellas).
* El cliente puede escribir un comentario opcional.
* La calificación se guarda en la tabla `reviews` vinculada al booking.

## Tareas

### Task 1
* **Summary:** Crear tabla `reviews` en Supabase
* **Description:** Campos: `id`, `booking_id`, `rating`, `comment`, `created_at`

### Task 2
* **Summary:** Implementar UI de calificación
* **Description:** Formulario con selector de estrellas y campo de texto para el comentario

### Task 3
* **Summary:** Endpoint de envío de feedback
* **Description:** Guardar la reseña y actualizar el promedio del proveedor (opcional/automático)

---

# EPIC: Notificaciones

---

# HU18 – Recibir notificaciones

## Historia de usuario

**Como** usuario
**Quiero** recibir notificaciones
**Para** estar informado sobre el estado de mis servicios y propuestas

## Criterios de aceptación

* Las notificaciones se persisten en la base de datos.
* El usuario puede ver una lista de sus notificaciones en la app.
* Opción de marcar notificaciones como leídas.

## Tareas

### Task 1
* **Summary:** Crear tabla `notifications` en Supabase
* **Description:** Campos: `id`, `user_id`, `title`, `message`, `is_read`, `created_at`

### Task 2
* **Summary:** Implementar centro de notificaciones en la UI
* **Description:** Pantalla o sección con la lista de alertas recibidas

### Task 3
* **Summary:** Lógica de marcado como leído
* **Description:** Actualizar el campo `is_read` al abrir o seleccionar la notificación

---

# Resumen de tareas por HU

| HU        | Descripción                   | Tareas        |
| --------- | ----------------------------- | ------------- |
| HU14      | Aceptar propuesta             | 3             |
| HU15      | Realizar pago                 | 4             |
| HU16      | Ver historial                 | 3             |
| HU17      | Calificar servicio            | 3             |
| HU18      | Recibir notificaciones        | 3             |
| **Total** | **5 HUs**                     | **16 tareas** |

---

# Entregable mínimo viable post-Sprint 3

## Al finalizar el Sprint 3, el usuario podrá:

| Rol       | Capacidad                                                              |
| --------- | ---------------------------------------------------------------------- |
| Cliente   | Aceptar una cotización y formalizar el contrato del servicio           |
| Cliente   | Pagar el servicio mediante métodos electrónicos (Simulado/Mock)        |
| Ambos     | Consultar el historial de servicios realizados y contratados           |
| Cliente   | Calificar la experiencia con el aseador mediante estrellas y texto     |
| Ambos     | Recibir alertas sobre cambios en el estado de sus servicios            |

---

*Documento de planificación para el Sprint 3 — Domora.*
