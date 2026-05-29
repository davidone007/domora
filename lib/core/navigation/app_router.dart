import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/injection_container.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:domora/features/app/ui/bloc/onboarding_route_bloc.dart';
import 'package:domora/features/app/ui/bloc/splash_bloc.dart';
import 'package:domora/core/navigation/main_screen.dart';
import 'package:domora/core/utils/constants.dart';

import 'package:domora/features/auth/ui/auth_blocs/login_bloc.dart';
import 'package:domora/features/auth/ui/auth_screens/login_screen.dart';
import 'package:domora/features/auth/ui/auth_blocs/signup_bloc.dart';
import 'package:domora/features/auth/ui/auth_screens/signup_screen.dart';

import 'package:domora/features/onboarding/ui/bloc/onboarding_bloc.dart';
import 'package:domora/features/onboarding/ui/screens/onboarding_screen.dart';

import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/ui/bloc/profile_bloc.dart';
import 'package:domora/features/profile/ui/bloc/profile_signout_bloc.dart';
import 'package:domora/features/profile/ui/bloc/provider_public_profile_bloc.dart';
import 'package:domora/features/profile/ui/pages/profile_page.dart';
import 'package:domora/features/profile/ui/screens/provider_public_profile_screen.dart';
import 'package:domora/features/profile/ui/bloc/profile_edit_bloc.dart';
import 'package:domora/features/profile/ui/pages/edit_profile_page.dart';

import 'package:domora/features/services/ui/bloc/address_picker_bloc.dart';
import 'package:domora/features/services/ui/bloc/service_publish_bloc.dart';
import 'package:domora/features/services/ui/screens/publish_service_flow_screen.dart';
import 'package:domora/features/services/ui/bloc/my_services_bloc.dart';
import 'package:domora/features/services/ui/bloc/service_detail_bloc.dart';
import 'package:domora/features/services/ui/screens/my_services_screen.dart';
import 'package:domora/features/services/ui/screens/service_detail_screen.dart';

import 'package:domora/features/proposals/ui/bloc/booking_activity_bloc.dart';
import 'package:domora/features/proposals/ui/screens/booking_activity_screen.dart';
import 'package:domora/features/proposals/ui/bloc/review_bloc.dart';
import 'package:domora/features/proposals/ui/screens/rating_screen.dart';
import 'package:domora/features/proposals/ui/bloc/payment_bloc.dart';
import 'package:domora/features/proposals/ui/screens/payment_selection_screen.dart';
import 'package:domora/features/proposals/ui/bloc/proposal_send_bloc.dart';
import 'package:domora/features/proposals/ui/bloc/service_proposals_bloc.dart';
import 'package:domora/features/proposals/ui/screens/send_proposal_screen.dart';
import 'package:domora/features/proposals/ui/screens/service_proposals_screen.dart';

import 'package:domora/features/notifications/ui/bloc/notification_bloc.dart';
import 'package:domora/features/notifications/ui/screens/notifications_screen.dart';

import 'package:domora/features/home/ui/pages/client_home_page.dart';
import 'package:domora/features/home/ui/pages/provider_home_page.dart';

import 'package:domora/features/welcome/ui/screens/welcome_screen.dart';

/// Construye y devuelve el router raíz de la aplicación.
GoRouter buildRouter({required NetworkInfo networkInfo}) {
  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<SplashBloc>()..add(const SplashCheckSessionEvent()),
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
          create: (_) => sl<LoginBloc>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeSignup,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<SignupBloc>(),
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<OnboardingBloc>()),
            BlocProvider(
              create: (_) => sl<OnboardingRouteBloc>()
                ..add(const OnboardingRouteLoadEvent()),
            ),
          ],
          child: const _OnboardingRouteResolver(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeClientHome,
        builder: (_, __) => ClientHomePage(userId: sl<SupabaseClient>().auth.currentUser?.id),
      ),
      GoRoute(
        path: AppConstants.routeProviderHome,
        builder: (_, __) => const ProviderHomePage(),
      ),
      GoRoute(
        path: '/publish-service',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<ServicePublishBloc>()),
              BlocProvider(create: (_) => sl<AddressPickerBloc>()),
            ],
            child: const PublishServiceFlowScreen(),
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeProfile,
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ProfileBloc>()),
            BlocProvider(create: (_) => sl<ProfileSignOutBloc>()),
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
            create: (_) => sl<ProfileEditBloc>(),
            child: EditProfilePage(initialProfile: initialProfile),
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeMyServices,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<MyServicesBloc>(),
          child: const MyServicesScreen(),
        ),
      ),
      GoRoute(
        path: '/service-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<ServiceDetailBloc>()..add(FetchServiceDetailEvent(id)),
            child: ServiceDetailScreen(serviceId: id),
          );
        },
      ),
      GoRoute(
        path: '/send-proposal/:serviceId',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return BlocProvider(
            create: (_) => sl<ProposalSendBloc>(),
            child: SendProposalScreen(serviceId: serviceId),
          );
        },
      ),
      GoRoute(
        path: '${AppConstants.routeServiceProposals}/:serviceId',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return BlocProvider(
            create: (_) => sl<ServiceProposalsBloc>(),
            child: ServiceProposalsScreen(serviceId: serviceId),
          );
        },
      ),
      GoRoute(
        path: '/provider-profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return BlocProvider(
            create: (_) => sl<ProviderPublicProfileBloc>(),
            child: ProviderPublicProfileScreen(userId: userId),
          );
        },
      ),
      GoRoute(
        path: '/payment/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          final extra = state.extra as Map<String, dynamic>;
          final amount = (extra['amount'] as num).toDouble();

          return BlocProvider(
            create: (_) => sl<PaymentBloc>(),
            child: PaymentSelectionScreen(
              bookingId: bookingId,
              amount: amount,
            ),
          );
        },
      ),
      GoRoute(
        path: '/activity',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<BookingActivityBloc>(),
            child: const BookingActivityScreen(),
          );
        },
      ),
      GoRoute(
        path: '/rate-service/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          final extra = state.extra as Map<String, dynamic>;
          final serviceTitle = extra['serviceTitle'] as String;
          final providerName = extra['providerName'] as String;

          return BlocProvider(
            create: (_) => sl<ReviewBloc>()..add(CheckReviewStatusEvent(bookingId)),
            child: RatingScreen(
              bookingId: bookingId,
              serviceTitle: serviceTitle,
              providerName: providerName,
            ),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<NotificationBloc>(),
            child: const NotificationsScreen(),
          );
        },
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
