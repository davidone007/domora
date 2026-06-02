# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Domora is a Flutter mobile marketplace for home services (cleaning, maintenance, etc.) connecting clients with service providers. Backend is Supabase (PostgreSQL + Auth + Storage). Push notifications via Firebase Cloud Messaging. Language: Spanish (es_CO).

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter analyze          # Static analysis (flutter_lints)
flutter test             # Run all tests
flutter test test/path   # Run a single test file
```

## Architecture

**Clean Architecture** with three layers per feature:

```
lib/
├── main.dart                        # App init (Supabase, Firebase, DI)
├── injection_container.dart         # get_it DI setup (all repos, sources, use cases, blocs)
├── core/
│   ├── navigation/app_router.dart   # GoRouter route definitions
│   ├── services/                    # Cross-feature singletons (e.g. FcmService)
│   ├── theme/app_theme.dart         # Color palette (#4FBF67 green primary) + DM Sans
│   ├── error/                       # failures.dart + FailureMapper + ErrorLogger
│   ├── utils/constants.dart         # Route paths, table names, role strings, storage keys
│   └── widgets/                     # Shared UI (CustomTextField, CustomButton, etc.)
└── features/{feature_name}/
    ├── data/
    │   ├── models/                  # Extend domain entities, add fromJson/toJson
    │   ├── sources/                 # Supabase client calls (remote data sources)
    │   └── repository/             # Implements domain repo, maps exceptions to Failures
    ├── domain/
    │   ├── entities/               # Pure data classes
    │   ├── repositories/           # Abstract contracts
    │   └── usecases/               # Single-responsibility, returns Either<Failure, T>
    └── ui/
        ├── bloc/                   # Events (Equatable), States (Equatable), BLoC
        └── screens/               # Flutter widgets
```

**Features**: `auth`, `onboarding`, `profile`, `services`, `proposals`, `notifications`, `home`, `welcome`, `app` (splash + routing logic).

The `proposals` feature bundles four sub-domains each with their own repo/source/BLoC: quotes, bookings, payments, reviews.

## Key Patterns

- **State management**: BLoC (flutter_bloc). BLoCs registered as `registerFactory` in get_it; repos and data sources as `registerLazySingleton`. Exceptions: `NotificationBloc` and `FcmService` are lazy singletons because they hold long-lived realtime subscriptions.
- **Error handling**: `Either<Failure, T>` (dartz) throughout use cases and repositories. Repositories call `FailureMapper.mapException()` to convert raw exceptions to typed failures. Typed failures: `AuthFailure`, `ServerFailure`, `NetworkFailure`, `ValidationFailure`, `PermissionFailure`, `UnknownFailure`.
- **Navigation**: GoRouter with BlocProviders at route level. Most route paths live in `AppConstants`; a few (`/publish-service`, `/service-detail/:id`, `/send-proposal/:serviceId`, `/payment/:bookingId`, `/rate-service/:bookingId`, `/activity`, `/notifications`, `/provider-profile/:userId`) are hardcoded inline in `app_router.dart`. Data is passed between routes via `state.extra`.
- **Network**: Health probe to Supabase before queries (1500ms timeout via `NetworkInfo`).
- **Local storage**: `flutter_secure_storage` for `onboarding_done` and `user_role` flags (keys in `AppConstants`).
- **Location**: `geolocator` for device GPS, `flutter_map` + `latlong2` for map display, custom `AddressRemoteDataSource` for autocomplete/reverse-geocode.
- **Push notifications**: `FcmService.initialize()` must be called after a session is confirmed (post-login or post-splash). It registers the FCM token and attaches foreground/tap listeners that trigger `FetchNotificationsEvent`. Realtime updates come via Supabase stream in `NotificationRepository`.
- **Auth flow**: Splash → checks session → routes to Welcome, Login, Onboarding, or Dashboard based on session + onboarding status.
- **Testing**: `mocktail` for mocks.

## Supabase Tables

`users`, `roles`, `user_roles`, `client_profiles`, `provider_profiles`, `services`, `cleaning_details`, `addresses`, `quotes`, `bookings`, `payments`, `reviews`, `notifications`. Storage bucket: `avatars`.

## Environment

Requires `.env` file in project root with `SUPABASE_URL` and `SUPABASE_ANON_KEY`. Firebase credentials configured per platform (GoogleService-Info.plist / google-services.json).
