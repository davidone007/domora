import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/error/error_mapper_singleton.dart';
import 'package:domora/core/network/network_info.dart';
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
import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/ui/bloc/profile_bloc.dart';
import 'package:domora/features/profile/ui/bloc/profile_signout_bloc.dart';
import 'package:domora/features/profile/ui/pages/profile_page.dart';
import 'package:domora/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_client_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_provider_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_provider_address_usecase.dart';
import 'package:domora/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_email_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_password_usecase.dart';
import 'package:domora/features/profile/ui/bloc/profile_edit_bloc.dart';
import 'package:domora/features/profile/ui/pages/edit_profile_page.dart';

import 'package:domora/features/services/data/repo/service_repository_impl.dart';
import 'package:domora/features/services/data/sources/service_remote_data_source.dart';
import 'package:domora/features/services/domain/repo/service_repository.dart';
import 'package:domora/features/services/domain/usecases/publish_cleaning_service_usecase.dart';
import 'package:domora/features/services/ui/bloc/service_publish_bloc.dart';
import 'package:domora/features/services/ui/screens/publish_service_flow_screen.dart';

import 'package:domora/features/services/domain/usecases/get_my_services_usecase.dart';
import 'package:domora/features/services/ui/bloc/my_services_bloc.dart';
import 'package:domora/features/services/ui/screens/my_services_screen.dart';

import 'package:domora/features/home/ui/pages/client_home_page.dart';
import 'package:domora/features/home/ui/pages/provider_home_page.dart';

import 'package:domora/features/welcome/ui/screens/welcome_screen.dart';

/// Construye y devuelve el router raíz de la aplicación.
GoRouter buildRouter({required NetworkInfo networkInfo}) {
  final supabase = Supabase.instance.client;

  // Singletons de la capa de datos / dominio.
  final errorMapper = ErrorMapperSingleton.instance;

  final AuthDataSource authDs = AuthDataSourceImpl(supabase, networkInfo: networkInfo);
  final AuthRepository authRepo = AuthRepositoryImpl(authDs, errorMapper);
  final getCurrentSession = GetCurrentSessionUseCase(authRepo);
  final signOut = SignOutUseCase(authRepo);

  final OnboardingDataSource onbDs = OnboardingDataSourceImpl(supabase, networkInfo: networkInfo);
  final OnboardingRepository onbRepo = OnboardingRepositoryImpl(onbDs, errorMapper);

  final ProfileDataSource profDs = ProfileDataSourceImpl(supabase, networkInfo: networkInfo);
  final ProfileRepository profRepo = ProfileRepositoryImpl(profDs, authRepo, errorMapper);

  final ServiceRemoteDataSource servDs = ServiceRemoteDataSourceImpl(supabase, networkInfo: networkInfo);
  final ServiceRepository servRepo = ServiceRepositoryImpl(servDs, errorMapper);

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
        builder: (_, __) => ClientHomePage(userId: supabase.auth.currentUser?.id),
      ),
      GoRoute(
        path: AppConstants.routeProviderHome,
        builder: (_, __) => const ProviderHomePage(),
      ),
      GoRoute(
        path: '/publish-service',
        builder: (context, state) {
          final userId = state.extra as String? ?? '';
          return BlocProvider(
            create: (_) => ServicePublishBloc(
              PublishCleaningServiceUseCase(servRepo),
              userId,
            ),
            child: const PublishServiceFlowScreen(),
          );
        },
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
      GoRoute(
        path: AppConstants.routeProfileEdit,
        builder: (context, state) {
          final extra = state.extra;
          FullProfile? initialProfile;
          if (extra is FullProfile) {
            initialProfile = extra;
          }

          return BlocProvider(
            create: (_) => ProfileEditBloc(
              UpdateProfileUseCase(profRepo),
              UpdateClientProfileUseCase(profRepo),
              UpdateProviderProfileUseCase(profRepo),
              UpdateProviderAddressUseCase(profRepo),
              UploadAvatarUseCase(profRepo),
              UpdateEmailUseCase(profRepo),
              UpdatePasswordUseCase(profRepo),
            ),
            child: EditProfilePage(initialProfile: initialProfile),
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeMyServices,
        builder: (_, __) => BlocProvider(
          create: (_) => MyServicesBloc(GetMyServicesUseCase(servRepo)),
          child: const MyServicesScreen(),
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
