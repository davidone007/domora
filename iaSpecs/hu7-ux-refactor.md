# Plan de Mejora UX: HU7 – Flujo Multi-paso para Publicación de Limpieza

## 📋 Objetivo
Transformar el formulario único de publicación en un flujo guiado de 5 pasos para mejorar la experiencia del usuario (UX), manteniendo la consistencia visual con la marca Domora (Verde #4FBF67, Blanco y Negro).

## 🚶 Flujo del Proceso
1.  **Paso 1: Detalles del Lugar e Insumos** (Contadores de habitaciones/baños + Switch de insumos).
2.  **Paso 2: Información General** (Título y descripción detallada).
3.  **Paso 3: Programación** (Calendario interactivo y selección de hora).
4.  **Paso 4: Ubicación** (Mapa con estilo blanco minimalista + dirección manual).
5.  **Paso 5: Confirmación** (Pantalla final de éxito "Orden Publicada").

---

## 🛠️ Checklist de Desarrollo

### 1. Gestión de Estado (BLoC)
- [x] Refactorizar `ServicePublishBloc` para manejar el estado del borrador (`draft`) y la navegación entre pasos.
- [x] Asegurar que el estado sea inmutable y use `Equatable`.

### 2. Interfaz de Usuario (UI) - Estructura Principal
- [x] Crear `PublishServiceFlowScreen`: Contenedor principal con `AppBar` personalizada y barra de progreso.
- [x] Implementar la barra de progreso superior en color Verde Domora.
- [x] Usar `PageView` con física controlada para las transiciones.

### 3. Implementación de Vistas por Paso
- [x] **Paso 1 (Lugar):** Reutilizar y estilizar `ServiceCounterInput`, añadir lógica de insumos.
- [x] **Paso 2 (Información):** Uso de `CustomTextField` con el estilo de la marca.
- [x] **Paso 3 (Fecha/Hora):** Integrar selectores con estética limpia sobre fondo blanco.
- [x] **Paso 4 (Mapa):** 
    - [x] Actualizar `MapAddressPicker` para usar tiles de CartoDB Light (`https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png`).
    - [x] Marcador en Verde Domora o Rojo de acento.
- [x] **Paso 5 (Éxito):** Pantalla blanca con check circular verde grande y botón "Volver al Inicio".

### 4. Estilo y Consistencia (AppTheme)
- [x] Usar `AppTheme.primary` (#4FBF67) para botones y progreso.
- [x] Fondos en `AppTheme.background` (Blanco).
- [x] Textos en `AppTheme.textPrimary` (Negro iOS).
- [x] Botones de navegación ("Siguiente" primario, "Atrás" secundario u outlined).

### 5. Integración y Limpieza
- [x] Actualizar ruta en `app_router.dart`.
- [x] Eliminar `PublishServiceScreen` antiguo si ya no se requiere.
- [x] Verificar con `flutter analyze`.

---

## 🎨 Especificaciones Técnicas
- **Mapa:** OpenStreetMap con estilo blanco minimalista (sin API Keys).
- **Transiciones:** Desplazamiento lateral suave entre pasos.
- **Validación:** Validar el paso actual antes de permitir el "Siguiente".
