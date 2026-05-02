# Domora — Marketplace de Servicios Profesionales

Domora es una aplicación móvil construida con Flutter que conecta usuarios con proveedores de servicios profesionales. Diseñada como un marketplace on-demand (modelo tipo Uber), facilita interacciones fluidas entre personas que buscan servicios específicos y expertos dispuestos a brindarlos.

---

## 🚀 Visión general

Domora busca cerrar la brecha entre la demanda y la oferta en la industria de servicios locales. Ya sea mantenimiento del hogar, consultoría profesional o cuidado personal, Domora proporciona una plataforma confiable para reservar y gestionar servicios, con un fuerte enfoque en la **seguridad domiciliaria** mediante verificación de identidad de los proveedores y reputación comunitaria.

---

## ✅ Sprint 1 — Historias de usuario implementadas

| HU  | Descripción | Código clave |
|-----|-------------|--------------|
| —   | Carrusel de bienvenida | `features/welcome` |
| HU1 | Registro de usuario con selección de rol | `features/signup`, `features/auth/domain/usecases/signup_usecase.dart` |
| HU2 | Inicio de sesión con redirección por rol | `features/login`, `features/auth/domain/usecases/login_usecase.dart` |
| HU3 | Onboarding inicial (completar perfil) | `features/onboarding` |
| HU4 | Visualización de perfil (cliente/proveedor) | `features/profile` |

> El **carrusel de bienvenida** es presentacional: aparece a usuarios sin sesión antes del login. No persiste datos en la base de datos.

---

## 👥 Equipo de desarrollo

- Andrés Felipe Cabezas Guerrero
- Nicolás Cuéllar Molina
- Davide Flamini Cazarán
- Miguel Angel Martínez Vidal
- Daron Andrés Mercado García
- Samuel Jose Rengifo Morales

---

## 🎨 Identidad visual

La app utiliza la paleta de marca **verde / blanco / negro** y la tipografía **DM Sans** (vía `google_fonts`). Toda la apariencia se centraliza en `lib/core/theme/app_theme.dart`:

| Token | Valor | Uso |
|-------|-------|-----|
| `primary` | `#4FBF67` | Botones, foco de inputs, acentos |
| `primarySoft` | `#E8F7EC` | Fondos suaves, badges, círculos de iconos |
| `textPrimary` | `#1C1C1E` | Títulos |
| `textSecondary` | `#6E6E73` | Descripciones |
| `surfaceDark` | `#1C1C1E` | Header del dashboard, bottom nav |
| `border` | `#E3E3E8` | Bordes de inputs y cards |
| `error` | `#E5484D` | Mensajes de error |

### Componentes globales reutilizables

| Componente | Ubicación | Propósito |
|------------|-----------|-----------|
| `CustomTextField` | `core/widgets/` | Input con label flotante dentro del borde |
| `CustomButton` | `core/widgets/` | Botón con estado de carga y variantes |
| `RoleSelector` | `core/widgets/` | Selector visual Cliente/Proveedor |
| `AvatarPicker` | `core/widgets/` | Selección de foto (cámara / galería) |
| `LoadingOverlay` | `core/widgets/` | Capa de carga semitransparente |
| `MainShell` | `core/widgets/` | Wrapper con bottom nav y pestaña activa elevada |
| `DashboardHeader` | `home/ui/widgets/` | Header oscuro con grid + logo + campana |
| `ServiceCard` | `home/ui/widgets/` | Tarjeta circular para servicios |
| `NewsChipFilter` | `home/ui/widgets/` | Filtro horizontal de chips |
| `PromoBanner` | `home/ui/widgets/` | Banner promocional con gradiente |

---

## 🛠 Stack tecnológico

| Capa | Tecnología |
|------|------------|
| **Framework** | Flutter |
| **Lenguaje** | Dart |
| **Arquitectura** | Clean Architecture (Domain / Data / Presentation) |
| **Manejo de estado** | BLoC |
| **Backend** | Supabase (Auth, PostgreSQL, Storage) |
| **Manejo de errores** | Either (dartz) |
| **Navegación** | go_router |
| **Tipografía** | google_fonts (DM Sans) |

---

## 🗂️ Estructura del proyecto

```
lib/
├── main.dart                         # Punto de entrada
├── core/
│   ├── navigation/
│   │   ├── main_screen.dart          # Splash + decisión de ruta inicial
│   │   └── app_router.dart           # GoRouter + inyección de BLoCs
│   ├── theme/
│   │   └── app_theme.dart            # Paleta verde/blanco/negro + DM Sans
│   ├── error/
│   │   └── failures.dart             # Failure tipados (dartz Either)
│   ├── utils/
│   │   ├── constants.dart            # Tablas, rutas, roles, storage keys
│   │   └── validators.dart           # Validadores de formularios (es-CO)
│   └── widgets/
│       ├── custom_text_field.dart
│       ├── custom_button.dart
│       ├── role_selector.dart
│       ├── avatar_picker.dart
│       ├── loading_overlay.dart
│       ├── simple_form.dart
│       └── main_shell.dart
└── features/
    ├── auth/                         # Lógica compartida de autenticación
    │   ├── data/{repo,sources}
    │   └── domain/{repo,usecases}
    ├── login/ui/{bloc,screens}
    ├── signup/ui/{bloc,screens}
    ├── welcome/ui/{models,screens}   # Carrusel presentacional
    ├── onboarding/
    │   ├── data/{repo,sources}
    │   ├── domain/{repo,usecases}
    │   └── ui/{bloc,screens}
    ├── profile/
    │   ├── data/{repository,source}
    │   ├── domain/{model,repository}
    │   └── ui/{bloc,pages}
    └── home/ui/pages/
        ├── client_home_page.dart
        └── provider_home_page.dart
```

---

## 🚀 Puesta en marcha

### 1. Prerrequisitos

- Flutter SDK instalado
- Dart SDK
- Un emulador Android/iOS o dispositivo físico
- Proyecto en [Supabase](https://supabase.com)

### 2. Clonar el repositorio

```bash
git clone https://github.com/davidone007/domora
cd domora
```

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Configuracion Supabase

1. En el **SQL Editor** se ejecuto el archivo `supabase_schema.sql` (incluido en el repositorio). Este script crea:
   - Todas las tablas requeridas (`roles`, `users`, `user_roles`, `client_profiles`, `provider_profiles`, `addresses`)
   - Políticas de RLS con permisos adecuados
   - Bucket `avatars` para fotos de perfil
   - Trigger `handle_new_user()` para sincronizar `auth.users` con `public.users`
   - Permisos de esquema para los roles `anon` y `authenticated`
2. Crea `.env` y reemplaza con tus credenciales:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-publishable-key
```

> ⚠️ Verifica que `assets: - .env` está incluido en `pubspec.yaml`.

### 5. Ejecutar la aplicación

```bash
flutter run
```

---

## 🔑 Decisiones de diseño

### Arquitectura

- **Domain layer** sin dependencias externas: solo entidades, contratos abstractos (`AuthRepository`, `OnboardingRepository`, `ProfileRepository`) y casos de uso (`LoginUseCase`, `SignupUseCase`, etc.).
- **Data layer** con `*DataSource` (acceso directo a Supabase) y `*RepositoryImpl` que traduce excepciones a `Failure`.
- **Presentation** con un BLoC por flujo (`LoginBloc`, `SignupBloc`, `OnboardingBloc`, `ProfileBloc`), cada uno con eventos y estados inmutables (`Equatable`).
- Manejo de errores con `Either<Failure, T>` (dartz).

### Sesión persistente (HU2)

Se aprovecha la persistencia integrada de `supabase_flutter`, que almacena los tokens de forma segura (`flutter_secure_storage` por debajo). Al iniciar la app, `MainScreen` evalúa `Supabase.instance.client.auth.currentSession` y decide la ruta de destino.

### Rol y onboarding

- El rol se guarda en `user_roles` al registrarse (HU1). Se lee mediante un join `user_roles → roles(name)` al iniciar sesión.
- El estado de onboarding se persiste en la columna `users.onboarding_completed`, lo que evita depender de almacenamiento local y funciona en cualquier dispositivo del mismo usuario.

### Onboarding adaptable (HU3)

`OnboardingScreen` recibe el rol mediante `_OnboardingRouteResolver` y muestra un formulario distinto:

| Rol | Campos que guarda | Tablas afectadas |
|-----|-------------------|------------------|
| **Cliente** | nombres, apellidos, teléfono, avatar | `users`, `client_profiles` |
| **Proveedor** | datos básicos + años de experiencia, tarifa, bio, dirección | `users`, `provider_profiles`, `addresses` |

### Perfil (HU4)

`ProfileRepositoryImpl` agrega datos de `users`, `roles`, perfil específico y dirección principal en una entidad `FullProfile`. La UI en `profile_page.dart` se adapta automáticamente mostrando información de contacto y, si es proveedor, experiencia, tarifa, disponibilidad y ubicación.

### Bottom navigation

`MainShell` provee un bottom nav oscuro de 4 pestañas:
- **Inicio** → dashboard actual
- **Solicitudes** → placeholder "Próximamente"
- **Cupones** → placeholder "Próximamente"
- **Perfil** → `/profile`

La pestaña activa se eleva como un círculo blanco con icono verde.

---

## 🔄 Flujo de navegación completo

```
WelcomeScreen (carrusel)
      │
      ├── "Comenzar"/"Siguiente"/"Omitir" → /login
      ▼
LoginScreen
      │
      ├── "Regístrate" → /signup (push)
      ├── Login exitoso → onboarding o dashboard según rol
      └── Flecha atrás → /welcome (si no hay pop)
      ▼
SignupScreen
      │
      ├── Registro exitoso → /onboarding
      └── Flecha atrás → pop() a login
      ▼
OnboardingScreen → MainScreen → dashboard según rol
      │
      ├── Cliente → ClientHomePage
      └── Proveedor → ProviderHomePage
      ▼
MainShell (bottom navigation)
      │
      ├── Inicio → dashboard actual
      ├── Perfil → ProfilePage
      ├── Solicitudes/Cupones → "Próximamente" snackbar
      │
      ▼
Cierre de sesión → /welcome
```

---

## 🐘 Modelo de datos (Supabase)

### Tablas principales

| Tabla | Propósito |
|-------|-----------|
| `roles` | Catálogo de roles (`client`, `provider`) |
| `users` | Datos básicos y flag `onboarding_completed` |
| `user_roles` | Relación N:N entre usuarios y roles |
| `client_profiles` | Datos específicos de clientes (`avatar_url`, `bio`) |
| `provider_profiles` | Datos específicos de proveedores (experiencia, tarifa, disponibilidad, bio, avatar) |
| `addresses` | Direcciones de servicio (principalmente para proveedores) |

### Políticas RLS

- `anon` tiene permisos `USAGE` en el esquema `public` y `SELECT`/`INSERT` limitados
- `authenticated` tiene permisos completos (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) sobre sus propios registros
- Cada usuario solo puede ver/modificar sus propios datos (excepto `roles` que es de solo lectura)

### Bucket de storage

- `avatars`: bucket público para fotos de perfil
- Políticas que permiten a usuarios autenticados subir/actualizar/eliminar sus propias imágenes

---

## 📦 Dependencias principales

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `supabase_flutter` | ^2.0.0 | Backend, autenticación y storage |
| `flutter_bloc` | ^8.1.3 | Manejo de estado |
| `equatable` | ^2.0.5 | Comparación de objetos |
| `go_router` | ^13.0.0 | Navegación declarativa |
| `dartz` | ^0.10.1 | Either para manejo de errores |
| `google_fonts` | ^6.2.1 | Tipografía DM Sans |
| `image_picker` | ^1.0.0 | Selección de avatar |
| `intl` | ^0.18.0 | Formateo de moneda y fechas |

---

## 🧪 Próximos pasos (Sprint 2)

- Edición de perfil (PUT/PATCH reutilizando validadores existentes)
- Publicación de solicitudes de servicio (HU5)
- Envío y gestión de cotizaciones (HU6)
- Sistema de calificaciones y reseñas (HU7)
- Notificaciones push

---

## 📄 Licencia

Proyecto desarrollado como parte del curso **Aplicaciones Móviles** en la **Universidad ICESI**.

---

*Creado por el equipo de Domora — Sprint 1.*