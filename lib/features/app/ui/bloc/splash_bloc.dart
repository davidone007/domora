import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/core/utils/constants.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:domora/features/notifications/domain/usecases/initialize_fcm_usecase.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

class SplashCheckSessionEvent extends SplashEvent {
  const SplashCheckSessionEvent();
}

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitialState extends SplashState {
  const SplashInitialState();
}

class SplashNavigateState extends SplashState {
  final String route;

  const SplashNavigateState(this.route);

  @override
  List<Object?> get props => [route];
}

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCurrentSessionUseCase _getCurrentSession;
  final InitializeFcmUseCase _initializeFcm;

  SplashBloc(this._getCurrentSession, this._initializeFcm) : super(const SplashInitialState()) {
    on<SplashCheckSessionEvent>(_onCheckSession);
  }

  Future<void> _onCheckSession(
    SplashCheckSessionEvent event,
    Emitter<SplashState> emit,
  ) async {
    final result = await _getCurrentSession();
    result.fold(
      (_) => emit(const SplashNavigateState(AppConstants.routeWelcome)),
      (session) {
        if (session == null) {
          emit(const SplashNavigateState(AppConstants.routeWelcome));
          return;
        }

        if (!session.onboardingCompleted) {
          emit(const SplashNavigateState(AppConstants.routeOnboarding));
          return;
        }

        // Si ya completó onboarding pero por alguna razón el rol es nulo,
        // mandamos al Welcome para evitar dashboards inconsistentes.
        if (session.role == null) {
          emit(const SplashNavigateState(AppConstants.routeWelcome));
          return;
        }

        // Sesión válida persistida: registrar/refrescar el token FCM.
        _initializeFcm();

        emit(
          SplashNavigateState(
            session.role == AppConstants.roleProvider
                ? AppConstants.routeProviderHome
                : AppConstants.routeClientHome,
          ),
        );
      },
    );
  }
}
