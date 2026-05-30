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
│   ├── theme/app_theme.dart         # Color palette (#4FBF67 green primary) + DM Sans
│   ├── error/failures.dart          # Typed failures for Either<Failure, T>
│   ├── utils/constants.dart         # Route paths, table names, role strings, storage keys
│   └── widgets/                     # Shared UI (CustomTextField, CustomButton, MainShell, etc.)
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

**Features**: auth, onboarding, profile, services, proposals (quotes/bookings/payments/reviews), notifications, home, welcome.

## Key Patterns

- **State management**: BLoC (flutter_bloc). BLoCs registered as factories in get_it; repos and data sources as lazy singletons.
- **Error handling**: `Either<Failure, T>` (dartz) throughout use cases and repositories. Typed failures: `AuthFailure`, `ServerFailure`, `NetworkFailure`, `ValidationFailure`, `PermissionFailure`.
- **Navigation**: GoRouter with BlocProviders at route level. `MainShell` wraps dashboard routes with bottom navigation.
- **Network**: Health probe to Supabase before queries (1500ms timeout via `NetworkInfo`).
- **Auth flow**: Splash → checks session → routes to Welcome, Login, Onboarding, or Dashboard based on session + onboarding status.

## Supabase Tables

`users`, `roles`, `user_roles`, `client_profiles`, `provider_profiles`, `services`, `cleaning_details`, `addresses`, `quotes`, `bookings`, `payments`, `reviews`, `notifications`. Storage bucket: `avatars`.

## Environment

Requires `.env` file in project root with `SUPABASE_URL` and `SUPABASE_ANON_KEY`. Firebase credentials configured per platform (GoogleService-Info.plist / google-services.json).
