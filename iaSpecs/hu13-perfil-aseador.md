# HU13 – Ver perfil de aseador

## Historia de Usuario
**Como** cliente  
**Quiero** ver el perfil completo del aseador  
**Para** evaluar su experiencia y confiabilidad antes de contratarlo  

## Criterios de Aceptación
- [ ] El cliente puede acceder al perfil desde una propuesta previa.
- [ ] El perfil muestra: Nombre y foto de perfil, años de experiencia, tarifa por hora y biografía.
- [ ] Calificación promedio (placeholder si no hay datos) y número de servicios completados (opcional).
- [ ] UI consistente con Domora (DM Sans, colores institucionales).

## Checklist de Desarrollo

### 1. Dominio (Pure Dart)
- [x] Actualizar `ProfileRepository` con `getProviderProfileById(String userId)` (lib/features/profile/domain/repo/profile_repository.dart).
- [x] Crear el caso de uso `GetProviderProfileUseCase` (lib/features/profile/domain/usecases/get_provider_profile_usecase.dart).

### 2. Datos (Supabase)
- [x] Implementar `getProviderProfileById` en `ProfileRepositoryImpl`.
    - Debe orquestar llamadas a `getUser`, `getRole` y `getProviderProfile` en el data source.
- [x] Reutilizar `ProfileMappers` para convertir los mapas a entidades.

### 3. Presentación (BLoC + UI)
- [x] `ProviderPublicProfileBloc` (lib/features/profile/ui/bloc/provider_public_profile_bloc.dart) para cargar el perfil por ID.
- [x] Pantalla `ProviderPublicProfileScreen` (lib/features/profile/ui/screens/provider_public_profile_screen.dart).
- [x] Diseño de UI:
    - Header con fondo suave y avatar centrado.
    - Nombre prominente y badge de rol.
    - Fila de estadísticas (Precio/h, Experiencia, Rating).
    - Sección de Biografía con scroll si es larga.
    - Botón para volver atrás.

### 4. Integración
- [x] Registro de ruta en `app_router.dart` (`/provider-profile/:userId`).
- [x] Navegación desde `ProposalCard` en `ServiceProposalsScreen`.
- [x] Validación con `flutter analyze`.

---

## Guía de Pruebas (UI)
1. **Acceso:** Ir a la lista de propuestas de cualquier servicio (HU12).
2. **Navegación:** Tocar la tarjeta de un proveedor (nombre o avatar).
3. **Carga:** Verificar que aparezca el indicador de carga mientras se obtienen los datos de Supabase.
4. **Visualización:** Confirmar que los datos mostrados (nombre, bio, experiencia, tarifa) coinciden con el proveedor seleccionado.
5. **Consistencia:** Verificar que el diseño use la tipografía DM Sans y los colores primarios de Domora (#4FBF67).
