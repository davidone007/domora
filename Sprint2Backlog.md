# Domora - Sprint Backlog 2

## Integrantes

* Andrés Felipe Cabezas Guerrero
* Nicolás Cuéllar Molina
* Davide Flamini Cazarán
* Miguel Angel Martínez Vidal
* Daron Andrés Mercado García
* Samuel Jose Rengifo Morales

---

# Objetivo del Sprint 2

Implementar el flujo completo de servicios (creación, visualización y propuestas) para que los clientes puedan publicar necesidades y los proveedores puedan responder con cotizaciones.

Este sprint establece el núcleo funcional del marketplace.

---

# Resumen del Sprint Backlog 2

| EPIC       | Historias           | Tareas estimadas |
| ---------- | ------------------- | ---------------- |
| Servicios  | HU7, HU8, HU9, HU10 | 18               |
| Propuestas | HU11, HU12, HU13    | 15               |
| **Total**  | **7 HUs**           | **33 tareas**    |

---

# EPIC: Servicios

---

# HU7 – Publicar servicio de limpieza

## Historia de usuario

**Como** cliente
**Quiero** publicar una solicitud de servicio de limpieza
**Para que** los aseadores puedan ver mi necesidad y cotizar

## Criterios de aceptación

* El cliente puede seleccionar el tipo de servicio (limpieza).
* El cliente puede especificar cantidad de baños, cocinas y habitaciones.
* El cliente puede agregar una descripción detallada del trabajo.
* El cliente puede seleccionar una fecha y hora preferida.
* El cliente puede ubicar la dirección en un mapa o ingresarla manualmente.
* La dirección se guarda en la tabla `addresses` y se asocia al servicio.
* El servicio se guarda en la tabla `services` con estado `open`.
* Se muestra mensaje de éxito y se redirige a la lista de servicios.

## Tareas

### Task 1

* **Summary:** Crear pantalla de publicación de servicio
* **Description:** UI con campos para cantidad de baños, cocinas, habitaciones, descripción, fecha/hora
* **Priority:** High
* **Sprint:** Sprint 2

### Task 2

* **Summary:** Agregar selector de fecha y hora
* **Description:** DatePicker y TimePicker para fecha/hora preferida
* **Priority:** High
* **Sprint:** Sprint 2

### Task 3

* **Summary:** Integrar mapa para selección de dirección
* **Description:** Usar `google_maps_flutter` o `flutter_map` para seleccionar ubicación
* **Priority:** High
* **Sprint:** Sprint 2

### Task 4

* **Summary:** Guardar dirección en addresses y asociar a servicio
* **Description:** Insertar en `addresses`, luego en `services` con `address_id`
* **Priority:** High
* **Sprint:** Sprint 2

### Task 5

* **Summary:** Crear endpoint `POST /services` (backend)
* **Description:** Guardar servicio en Supabase y retornar datos
* **Priority:** High
* **Sprint:** Sprint 2

### Task 6

* **Summary:** Integrar Supabase para guardar servicio
* **Description:** Conectar UI con backend para persistir servicio
* **Priority:** High
* **Sprint:** Sprint 2

### Task 7

* **Summary:** Implementar validaciones del formulario
* **Description:** Validar campos obligatorios y valores numéricos
* **Priority:** Medium
* **Sprint:** Sprint 2

---

# HU8 – Subir imágenes del servicio

## Historia de usuario

**Como** cliente
**Quiero** agregar fotos del área a limpiar
**Para mostrar** mejor el trabajo requerido

## Criterios de aceptación

* El cliente puede subir una o varias imágenes.
* Las imágenes se asocian al servicio en la tabla `service_images`.
* Se puede marcar una imagen como principal.
* Las imágenes se guardan en Supabase Storage (bucket `service-images`).
* Se muestran miniaturas de las imágenes en el formulario.

## Tareas

### Task 1

* **Summary:** Configurar bucket `service-images` en Supabase
* **Description:** Crear bucket y políticas RLS para subida de imágenes
* **Priority:** High
* **Sprint:** Sprint 2

### Task 2

* **Summary:** Implementar selector de múltiples imágenes
* **Description:** Usar `image_picker` para seleccionar varias fotos
* **Priority:** High
* **Sprint:** Sprint 2

### Task 3

* **Summary:** Subir imágenes a Supabase Storage
* **Description:** Subir archivos y obtener URLs públicas
* **Priority:** High
* **Sprint:** Sprint 2

### Task 4

* **Summary:** Guardar URLs en `service_images`
* **Description:** Asociar cada imagen al `service_id` correspondiente
* **Priority:** High
* **Sprint:** Sprint 2

### Task 5

* **Summary:** Mostrar miniaturas en formulario
* **Description:** Grid de imágenes seleccionadas con opción de eliminar
* **Priority:** Medium
* **Sprint:** Sprint 2

---

# HU9 – Ver mis servicios

## Historia de usuario

**Como** cliente
**Quiero** ver todos mis servicios publicados
**Para** gestionarlos y dar seguimiento

## Criterios de aceptación

* Lista de servicios del cliente autenticado.
* Cada servicio muestra: título, fecha de publicación, estado y cantidad de propuestas.
* Los servicios se ordenan del más reciente al más antiguo.
* Se puede hacer tap en un servicio para ver su detalle.
* Estado visual:

  * `open` (activo)
  * `in_progress` (en proceso)
  * `completed` (completado)
  * `cancelled` (cancelado)

## Tareas

### Task 1

* **Summary:** Crear pantalla "Mis Servicios"
* **Description:** UI con lista de servicios del cliente
* **Priority:** High
* **Sprint:** Sprint 2

### Task 2

* **Summary:** Crear endpoint `GET /services/user/{userId}` (backend)
* **Description:** Consultar servicios por `client_id` desde Supabase
* **Priority:** High
* **Sprint:** Sprint 2

### Task 3

* **Summary:** Implementar `ServiceCard` widget
* **Description:** Tarjeta con información resumida del servicio
* **Priority:** Medium
* **Sprint:** Sprint 2

### Task 4

* **Summary:** Agregar filtros por estado
* **Description:** Tabs o chips para filtrar `open/in_progress/completed`
* **Priority:** Medium
* **Sprint:** Sprint 2

### Task 5

* **Summary:** Implementar pull-to-refresh
* **Description:** Actualizar lista de servicios
* **Priority:** Low
* **Sprint:** Sprint 2

---

# HU10 – Ver detalle de servicio

## Historia de usuario

**Como** usuario (cliente o proveedor)
**Quiero** ver el detalle completo de un servicio
**Para** entender la solicitud y decidir si cotizar (proveedor) o gestionar (cliente)

## Criterios de aceptación

El detalle muestra:

* Descripción completa
* Imágenes subidas
* Cantidad de baños, cocinas y habitaciones
* Fecha/hora preferida
* Dirección (con mapa)
* Estado actual

Además:

* El proveedor ve un botón para enviar propuesta.
* El cliente ve el número de propuestas recibidas.

## Tareas

### Task 1

* **Summary:** Crear pantalla de detalle de servicio
* **Description:** UI con toda la información del servicio
* **Priority:** High
* **Sprint:** Sprint 2

### Task 2

* **Summary:** Crear endpoint `GET /services/{id}` (backend)
* **Description:** Consultar servicio con imágenes y dirección
* **Priority:** High
* **Sprint:** Sprint 2

### Task 3

* **Summary:** Mostrar galería de imágenes
* **Description:** Carousel o grid con las fotos del servicio
* **Priority:** High
* **Sprint:** Sprint 2

### Task 4

* **Summary:** Mostrar dirección en mapa
* **Description:** Widget de mapa con marcador en la ubicación
* **Priority:** Medium
* **Sprint:** Sprint 2

### Task 5

* **Summary:** Mostrar botón de propuesta según rol
* **Description:** Proveedor ve botón "Cotizar", cliente no
* **Priority:** Medium
* **Sprint:** Sprint 2

---

# EPIC: Propuestas de aseadores

---

# HU11 – Enviar propuesta (cotización)

## Historia de usuario

**Como** aseador (proveedor)
**Quiero** enviar una propuesta con precio y tiempo estimado
**Para** trabajar en el servicio y ser seleccionado

## Criterios de aceptación

* El proveedor puede ingresar:

  * precio (obligatorio)
  * tiempo estimado (opcional)
* El proveedor puede agregar un mensaje opcional.
* La propuesta se guarda en la tabla `proposals` con estado `pending`.
* El proveedor no puede enviar más de una propuesta por servicio.
* Se muestra mensaje de éxito y se redirige al detalle del servicio.

## Tareas

### Task 1

* **Summary:** Crear pantalla de envío de propuesta
* **Description:** UI con campos precio, tiempo estimado y mensaje
* **Priority:** High
* **Sprint:** Sprint 2

### Task 2

* **Summary:** Crear tabla `proposals` en Supabase
* **Description:** `id`, `service_id`, `provider_id`, `price`, `estimated_hours`, `message`, `status`, `created_at`
* **Priority:** High
* **Sprint:** Sprint 2

### Task 3

* **Summary:** Crear endpoint `POST /proposals` (backend)
* **Description:** Validar que no exista propuesta previa del mismo proveedor
* **Priority:** High
* **Sprint:** Sprint 2

### Task 4

* **Summary:** Integrar envío de propuesta con Supabase
* **Description:** Conectar UI con backend
* **Priority:** High
* **Sprint:** Sprint 2

### Task 5

* **Summary:** Implementar validación de propuesta única
* **Description:** Evitar que un proveedor cotice dos veces el mismo servicio
* **Priority:** Medium
* **Sprint:** Sprint 2

---

# HU12 – Ver propuestas recibidas

## Historia de usuario

**Como** cliente
**Quiero** ver todas las propuestas de mis servicios publicados
**Para** comparar y elegir al aseador

## Criterios de aceptación

* Lista de propuestas para un servicio específico.
* Cada propuesta muestra:

  * nombre del aseador
  * precio
  * tiempo estimado
  * mensaje
* Las propuestas se ordenan por precio (menor a mayor) o fecha.
* El cliente puede ver el perfil del aseador desde la propuesta.
* Se muestra el estado de cada propuesta:

  * `pending`
  * `accepted`
  * `rejected`

## Tareas

### Task 1

* **Summary:** Crear pantalla de lista de propuestas
* **Description:** UI con lista de propuestas para un servicio
* **Priority:** High
* **Sprint:** Sprint 2

### Task 2

* **Summary:** Crear endpoint `GET /proposals/service/{serviceId}` (backend)
* **Description:** Consultar propuestas con datos del proveedor
* **Priority:** High
* **Sprint:** Sprint 2

### Task 3

* **Summary:** Implementar tarjeta de propuesta (`ProposalCard`)
* **Description:** Mostrar precio, tiempo, aseador y mensaje
* **Priority:** Medium
* **Sprint:** Sprint 2

### Task 4

* **Summary:** Agregar ordenamiento por precio
* **Description:** Opción para ordenar propuestas
* **Priority:** Low
* **Sprint:** Sprint 2

---

# HU13 – Ver perfil de aseador

## Historia de usuario

**Como** cliente
**Quiero** ver el perfil completo del aseador
**Para** evaluar su experiencia y confiabilidad antes de contratarlo

## Criterios de aceptación

* El cliente puede acceder al perfil desde una propuesta previa.
* El perfil muestra:

  * Nombre y foto de perfil
  * Años de experiencia
  * Tarifa por hora
  * Biografía
  * Calificación promedio (si existe)
  * Número de servicios completados (opcional)
* Se puede ver el perfil sin necesidad de tener una propuesta activa.

## Tareas

### Task 1

* **Summary:** Crear pantalla de perfil público de aseador
* **Description:** UI con información del proveedor para clientes
* **Priority:** High
* **Sprint:** Sprint 2

### Task 2

* **Summary:** Crear endpoint `GET /provider/profile/{userId}` (backend)
* **Description:** Consultar `provider_profiles` y datos de usuario
* **Priority:** High
* **Sprint:** Sprint 2

### Task 3

* **Summary:** Mostrar calificación promedio
* **Description:** Calcular promedio de reseñas del proveedor
* **Priority:** Medium
* **Sprint:** Sprint 2

### Task 4

* **Summary:** Agregar navegación desde propuesta a perfil
* **Description:** Tap en tarjeta de propuesta abre perfil del aseador
* **Priority:** Medium
* **Sprint:** Sprint 2

---

# Resumen de tareas por HU

| HU        | Descripción                   | Tareas        |
| --------- | ----------------------------- | ------------- |
| HU7       | Publicar servicio de limpieza | 7             |
| HU8       | Subir imágenes del servicio   | 5             |
| HU9       | Ver mis servicios             | 5             |
| HU10      | Ver detalle de servicio       | 5             |
| HU11      | Enviar propuesta              | 5             |
| HU12      | Ver propuestas recibidas      | 4             |
| HU13      | Ver perfil de aseador         | 4             |
| **Total** | **7 HUs**                     | **35 tareas** |

---

# Entregable mínimo viable post-Sprint 2

## Al finalizar el Sprint 2, el usuario podrá:

| Rol       | Capacidad                                                              |
| --------- | ---------------------------------------------------------------------- |
| Cliente   | Publicar servicio con imágenes, dirección y preferencias de fecha/hora |
| Cliente   | Ver lista de sus servicios y detalle completo                          |
| Proveedor | Ver servicios disponibles y enviar propuestas con precio               |
| Cliente   | Ver propuestas de aseadores y sus perfiles                             |

---

# Pendiente para Sprint 3

* HU14 – Aceptar propuesta y crear booking
* HU15 – Realizar pago
* HU16 – Ver historial de servicios
* HU17 – Calificar servicio
* HU18 – Notificaciones
