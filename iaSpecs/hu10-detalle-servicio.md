# HU10 – Ver detalle de servicio

## Historia de Usuario
**Como** usuario (cliente o proveedor)  
**Quiero** ver el detalle completo de un servicio  
**Para** entender la solicitud y decidir si cotizar (proveedor) o gestionar (cliente)  

## Criterios de Aceptación
- [ ] El detalle muestra: descripción completa, imágenes, cantidad de baños, cocinas y habitaciones, fecha/hora preferida, dirección (con mapa) y estado actual.
- [ ] El proveedor ve un botón para enviar propuesta.
- [ ] El cliente ve el número de propuestas recibidas.

## Checklist de Desarrollo

### 1. Dominio (Pure Dart)
- [x] Entidad `ServiceDetail` (lib/features/services/domain/entities/service_detail.dart)
- [x] Actualizar `ServiceRepository` con `getServiceById`
- [x] Caso de uso `GetServiceDetailUseCase`

### 2. Datos (Supabase)
- [x] Modelo `ServiceDetailModel` (lib/features/services/data/models/service_detail_model.dart)
- [x] Actualizar `ServiceRemoteDataSource` con consulta relacional.
- [x] Implementar en `ServiceRepositoryImpl`

### 3. Presentación (BLoC + UI)
- [x] `ServiceDetailBloc` (lib/features/services/ui/bloc/service_detail_bloc.dart)
- [x] Pantalla `ServiceDetailScreen` (lib/features/services/ui/screens/service_detail_screen.dart)
- [x] Widgets de carrusel y detalles técnicos.
- [x] Integración de mapa.

### 4. Integración
- [x] Registro de ruta en `app_router.dart`
- [x] Navegación desde `MyServicesScreen`
- [x] Validación con `flutter analyze`
