# Refactor: Datos Reales para Perfil de Aseador (HU13)

## 📋 Objetivo
Eliminar los datos "quemados" (hardcoded) en la pantalla de perfil público del aseador y reemplazar los placeholders de "Servicios Completados" y "Calificaciones" con consultas reales a la base de datos de Supabase, utilizando el esquema del Sprint 2.

## 🛠️ Checklist de Desarrollo

### 1. Dominio (Pure Dart)
- [x] Crear entidad `ProviderStats` (lib/features/profile/domain/entities/provider_stats.dart):
    - `double averageRating`
    - `int completedServicesCount`
    - `int totalReviewsCount`
- [x] Actualizar `FullProfile` para incluir un campo opcional `ProviderStats? stats`.
- [x] Actualizar `ProfileRepository` con `getProviderStats(String providerId)`.

### 2. Datos (Supabase)
- [x] Implementar `getProviderStats` en `ProfileRemoteDataSource`:
    - Consulta 1: Contar filas en `bookings` donde `provider_id = id` y `status = 'completed'`.
    - Consulta 2: Obtener el promedio de `rating` y conteo de la tabla `reviews` filtrando por los `booking_id` que pertenecen al proveedor.
- [x] Integrar en `ProfileRepositoryImpl` para que `getProviderProfileById` también dispare la carga de estadísticas.

### 3. Presentación (BLoC + UI)
- [x] Actualizar `ProviderPublicProfileBloc`:
    - Asegurar que al cargar el perfil se obtengan también las estadísticas.
    - Manejar el estado de éxito con el objeto `FullProfile` enriquecido.
- [x] Refactorizar `ProviderPublicProfileScreen`:
    - Reemplazar el "4.8" estático en la tarjeta de stats con `stats.averageRating`.
    - Reemplazar el placeholder de "15 servicios" con `stats.completedServicesCount`.
    - Reemplazar el placeholder de "12 reseñas" con `stats.totalReviewsCount`.
    - Mostrar "Sin calificaciones" si el conteo es cero.

### 4. Validación
- [x] Verificar consistencia con `flutter analyze`.
- [x] Probar con un proveedor que tenga bookings y reviews reales en Supabase.

---

## 🔍 Consultas Técnicas (Referencia SQL)
Para obtener los datos, se realizarán operaciones equivalentes a:

```sql
-- Conteo de servicios completados
SELECT count(*) FROM bookings 
WHERE provider_id = 'ID_PROVEEDOR' AND status = 'completed';

-- Promedio de calificación y total de reseñas
SELECT AVG(rating), COUNT(*) FROM reviews 
JOIN bookings ON reviews.booking_id = bookings.id 
WHERE bookings.provider_id = 'ID_PROVEEDOR';
```
