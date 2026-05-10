# HU8 – Subir imágenes del servicio

## Historia de Usuario
**Como** cliente  
**Quiero** agregar fotos del área a limpiar  
**Para mostrar** mejor el trabajo requerido  

## Criterios de Aceptación
- [x] El cliente puede subir una o varias imágenes.
- [x] Las imágenes se asocian al servicio en la tabla `service_images`.
- [x] Se puede marcar una imagen como principal (`is_primary`).
- [x] Las imágenes se guardan en Supabase Storage (bucket `service-images`).
- [x] Se muestran miniaturas de las imágenes en el formulario de publicación.

## Checklist de Desarrollo

### 1. Infraestructura (Supabase)
- [x] SQL para crear bucket `service-images`
- [x] SQL para políticas de acceso público en el bucket

### 2. Dominio (Pure Dart)
- [x] Entidad `ServiceImage` (lib/features/services/domain/entities/service_image.dart)
- [x] Actualizar `ServiceRepository` con método `publishCleaningService` (incluye imágenes)
- [x] Caso de uso integrado en `PublishCleaningServiceUseCase`

### 3. Datos (Supabase)
- [x] Modelo `ServiceImageModel` (lib/features/services/data/models/service_image_model.dart)
- [x] Implementar subida a Storage en `ServiceRemoteDataSource`
- [x] Implementar inserción en tabla `service_images` en `ServiceRemoteDataSource`
- [x] Actualizar `ServiceRepositoryImpl`

### 4. Presentación (BLoC + UI)
- [x] Actualizar `ServicePublishBloc` para manejar lista de `AvatarFile` y selección de principal
- [x] Widget `MultiImagePicker` (lib/features/services/ui/widgets/multi_image_picker.dart)
- [x] Widget `ImageThumbnailGrid` (lib/features/services/ui/widgets/image_thumbnail_grid.dart)
- [x] Integrar el paso de imágenes en el **Paso 2 (Información General)** de `lib/features/services/ui/screens/steps/step2_general_info.dart`

---

## Esquema de Datos Relacionado

### SQL para Bucket (Referencia)
```sql
-- Ejecutar en el SQL Editor de Supabase
INSERT INTO storage.buckets (id, name, public)
VALUES ('service-images', 'service-images', true)
ON CONFLICT (id) DO NOTHING;

-- Política permisiva para pruebas (HU8 requirement)
CREATE POLICY "Permitir todo en service-images"
ON storage.objects FOR ALL
USING ( bucket_id = 'service-images' );
```

### Tabla `service_images`
- `id`: uuid (PK)
- `service_id`: uuid (FK -> services)
- `image_url`: text
- `is_primary`: boolean
- `order_index`: int
- `created_at`: timestamptz
