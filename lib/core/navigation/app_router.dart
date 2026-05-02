import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/navigation/bloc/onboarding_route_bloc.dart';
import 'package:domora/core/navigation/bloc/splash_bloc.dart';
import 'package:domora/core/navigation/main_screen.dart';
import 'package:domora/core/utils/constants.dart';

import 'package:domora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:domora/features/auth/data/sources/auth_data_source.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:domora/features/auth/domain/usecases/login_usecase.dart';
import 'package:domora/features/auth/domain/usecases/signout_usecase.dart';
import 'package:domora/features/auth/domain/usecases/signup_usecase.dart';

import 'package:domora/features/login/ui/bloc/login_bloc.dart';
import 'package:domora/features/login/ui/screens/login_screen.dart';

import 'package:domora/features/signup/ui/bloc/signup_bloc.dart';
import 'package:domora/features/signup/ui/screens/signup_screen.dart';

import 'package:domora/features/onboarding/data/repo/onboarding_repo_impl.dart';
import 'package:domora/features/onboarding/data/sources/onboarding_data_source.dart';
import 'package:domora/features/onboarding/domain/repo/onboarding_repo.dart';
import 'package:domora/features/onboarding/domain/usecases/save_client_profile_usecase.dart';
import 'package:domora/features/onboarding/domain/usecases/save_provider_profile_usecase.dart';
import 'package:domora/features/onboarding/ui/bloc/onboarding_bloc.dart';
import 'package:domora/features/onboarding/ui/screens/onboarding_screen.dart';

import 'package:domora/features/profile/data/repo/profile_repository_impl.dart';
import 'package:domora/features/profile/data/sources/profile_data_source.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';
import 'package:domora/features/profile/domain/usecases/get_current_profile_usecase.dart';
import 'package:domora/features/profile/ui/bloc/profile_bloc.dart';
import 'package:domora/features/profile/ui/bloc/profile_signout_bloc.dart';
import 'package:domora/features/profile/ui/pages/profile_page.dart';

import 'package:domora/features/home/ui/pages/client_home_page.dart';
import 'package:domora/features/home/ui/pages/provider_home_page.dart';

import 'package:domora/features/welcome/ui/screens/welcome_screen.dart';

/// Construye y devuelve el router raíz de la aplicación.
GoRouter buildRouter() {
  final supabase = Supabase.instance.client;

  // Singletons de la capa de datos / dominio.
  final AuthDataSource authDs = AuthDataSourceImpl(supabase);
  final AuthRepository authRepo = AuthRepositoryImpl(authDs);
  final getCurrentSession = GetCurrentSessionUseCase(authRepo);
  final signOut = SignOutUseCase(authRepo);

  final OnboardingDataSource onbDs = OnboardingDataSourceImpl(supabase);
  final OnboardingRepository onbRepo = OnboardingRepositoryImpl(onbDs);

  final ProfileDataSource profDs = ProfileDataSourceImpl(supabase);
  final ProfileRepository profRepo = ProfileRepositoryImpl(profDs);

  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (_, __) => BlocProvider(
          create: (_) =>
              SplashBloc(getCurrentSession)..add(const SplashCheckSessionEvent()),
          child: const MainScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeWelcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (_, __) => BlocProvider(
          create: (_) => LoginBloc(LoginUseCase(authRepo)),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeSignup,
        builder: (_, __) => BlocProvider(
          create: (_) => SignupBloc(SignupUseCase(authRepo)),
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => OnboardingBloc(
                saveClient: SaveClientProfileUseCase(onbRepo),
                saveProvider: SaveProviderProfileUseCase(onbRepo),
              ),
            ),
            BlocProvider(
              create: (_) => OnboardingRouteBloc(getCurrentSession)
                ..add(const OnboardingRouteLoadEvent()),
            ),
          ],
          child: const _OnboardingRouteResolver(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeClientHome,
        builder: (_, __) => const ClientHomePage(),
      ),
      GoRoute(
        path: AppConstants.routeProviderHome,
        builder: (_, __) => const ProviderHomePage(),
      ),
      GoRoute(
        path: AppConstants.routeProfile,
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ProfileBloc(GetCurrentProfileUseCase(profRepo)),
            ),
            BlocProvider(
              create: (_) => ProfileSignOutBloc(signOut),
            ),
          ],
          child: const ProfilePage(),
        ),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
}

/// Resuelve el rol del usuario actual antes de mostrar el onboarding.
/// Necesario porque el rol vive en la base de datos, no en la URL.
class _OnboardingRouteResolver extends StatelessWidget {
  const _OnboardingRouteResolver();

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingRouteBloc, OnboardingRouteState>(
      listener: (context, state) {
        if (state is OnboardingRouteErrorState) {
          // Redirección defensiva: si falla la resolución (sesión expirada, etc.),
          // mandamos al usuario al inicio para evitar que quede atrapado.
          context.go(AppConstants.routeWelcome);
        }
      },
      child: BlocBuilder<OnboardingRouteBloc, OnboardingRouteState>(
        builder: (_, state) {
          if (state is OnboardingRouteReadyState) {
            return OnboardingScreen(
              role: state.role,
              userId: state.userId,
            );
          }
          // Mientras carga o en caso de error (antes de la redirección),
          // mostramos el indicador de carga.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
