import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';

abstract class OnboardingRouteEvent extends Equatable {
  const OnboardingRouteEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingRouteLoadEvent extends OnboardingRouteEvent {
  const OnboardingRouteLoadEvent();
}

abstract class OnboardingRouteState extends Equatable {
  const OnboardingRouteState();

  @override
  List<Object?> get props => [];
}

class OnboardingRouteLoadingState extends OnboardingRouteState {
  const OnboardingRouteLoadingState();
}

class OnboardingRouteReadyState extends OnboardingRouteState {
  final String userId;
  final String role;

  const OnboardingRouteReadyState({
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, role];
}

class OnboardingRouteErrorState extends OnboardingRouteState {
  final String message;

  const OnboardingRouteErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class OnboardingRouteBloc
    extends Bloc<OnboardingRouteEvent, OnboardingRouteState> {
  final GetCurrentSessionUseCase _getCurrentSession;

  OnboardingRouteBloc(this._getCurrentSession)
      : super(const OnboardingRouteLoadingState()) {
    on<OnboardingRouteLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(
    OnboardingRouteLoadEvent event,
    Emitter<OnboardingRouteState> emit,
  ) async {
    final result = await _getCurrentSession();
    result.fold(
      (_) => emit(const OnboardingRouteErrorState('No se pudo obtener la sesión actual')),
      (session) {
        if (session == null) {
          emit(const OnboardingRouteErrorState('Sesión no encontrada'));
          return;
        }
        if (session.role == null) {
          emit(const OnboardingRouteErrorState('No se encontró el rol del usuario'));
          return;
        }
        emit(OnboardingRouteReadyState(userId: session.userId, role: session.role!));
      },
    );
  }
}
