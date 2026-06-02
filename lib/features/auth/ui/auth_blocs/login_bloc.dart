import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/core/services/fcm_service.dart';
import 'package:domora/features/auth/domain/usecases/login_usecase.dart';
 
// EVENTS
abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitEvent extends LoginEvent {
  final String email;
  final String password;
  const LoginSubmitEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginResetEvent extends LoginEvent {
  const LoginResetEvent();
}

// STATES
abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitialState extends LoginState {
  const LoginInitialState();
}

class LoginLoadingState extends LoginState {
  const LoginLoadingState();
}

class LoginSuccessState extends LoginState {
  final String? role;
  final bool onboardingCompleted;

  const LoginSuccessState({
    required this.role,
    required this.onboardingCompleted,
  });

  @override
  List<Object?> get props => [role, onboardingCompleted];
}

class LoginFailState extends LoginState {
  final String message;
  const LoginFailState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final FcmService _fcmService;

  LoginBloc(this._loginUseCase, this._fcmService) : super(const LoginInitialState()) {
    on<LoginSubmitEvent>(_onSubmit);
    on<LoginResetEvent>((_, emit) => emit(const LoginInitialState()));
  }

  Future<void> _onSubmit(
    LoginSubmitEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoadingState());

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async => emit(LoginFailState(failure.message)),
      (auth) async {
        // Registrar/refrescar el token FCM antes de navegar, para garantizar
        // que el dispositivo está suscrito a notificaciones al entrar al home.
        try {
          await _fcmService.initialize();
        } catch (_) {
          // No bloqueamos la navegación si la inicialización FCM falla.
        }
        emit(
          LoginSuccessState(
            role: auth.role,
            onboardingCompleted: auth.onboardingCompleted,
          ),
        );
      },
    );
  }
}
