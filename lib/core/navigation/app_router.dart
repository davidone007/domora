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

import 'package:domora/features/home/ui/pages/client_home_page.dart';
import 'package:domora/features/home/ui/pages/provider_home_page.dart';

/// Construye y devuelve el router raíz de la aplicación.
GoRouter buildRouter() {
  final supabase = Supabase.instance.client;

  // Singletons de la capa de datos / dominio.
  final AuthDataSource authDs = AuthDataSourceImpl(supabase);
  final AuthRepository authRepo = AuthRepositoryImpl(authDs);

  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (_, __) => const MainScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (_, __) => BlocProvider(
          create: (_) => LoginBloc(LoginUseCase(authRepo)),
          child: const LoginScreen(),
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
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
}
