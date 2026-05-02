import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/navigation/main_screen.dart';
import 'package:domora/core/utils/constants.dart';

import 'package:domora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:domora/features/auth/data/sources/auth_data_source.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';
import 'package:domora/features/auth/domain/usecases/login_usecase.dart';
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

import 'package:domora/features/profile/data/repository/profile_repository_impl.dart';
import 'package:domora/features/profile/data/source/profile_data_source.dart';
import 'package:domora/features/profile/domain/repository/profile_repository.dart';
import 'package:domora/features/profile/ui/bloc/profile_bloc.dart';
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

  final OnboardingDataSource onbDs = OnboardingDataSourceImpl(supabase);
  final OnboardingRepository onbRepo = OnboardingRepositoryImpl(onbDs);

  final ProfileDataSource profDs = ProfileDataSourceImpl(supabase);
  final ProfileRepository profRepo = ProfileRepositoryImpl(profDs, supabase);

  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (_, __) => const MainScreen(),
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
        builder: (context, state) {
          // Redirección defensiva: si no hay sesión, regresa al login.
          if (supabase.auth.currentUser == null) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => context.go(AppConstants.routeLogin));
            return const SizedBox.shrink();
          }
          return BlocProvider(
            create: (_) => OnboardingBloc(
              saveClient: SaveClientProfileUseCase(onbRepo),
              saveProvider: SaveProviderProfileUseCase(onbRepo),
            ),
            child: _OnboardingRouteResolver(),
          );
        },
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
        builder: (_, __) => BlocProvider(
          create: (_) => ProfileBloc(profRepo),
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
class _OnboardingRouteResolver extends StatefulWidget {
  @override
  State<_OnboardingRouteResolver> createState() =>
      _OnboardingRouteResolverState();
}

class _OnboardingRouteResolverState extends State<_OnboardingRouteResolver> {
  String? _role;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final ds = AuthDataSourceImpl(Supabase.instance.client);
      final user = ds.currentUser;
      if (user == null) {
        setState(() => _error = 'Sesión no encontrada');
        return;
      }
      final role = await ds.getUserRole(user.id);
      if (!mounted) return;
      if (role == null) {
        setState(() => _error = 'No se encontró el rol del usuario');
      } else {
        setState(() => _role = role);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }
    if (_role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return OnboardingScreen(role: _role!);
  }
}
