import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/auth/domain/repo/auth_repo.dart';
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
  final AuthResult result;
  const LoginSuccessState(this.result);

  @override
  List<Object?> get props => [result];
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

  LoginBloc(this._loginUseCase) : super(const LoginInitialState()) {
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

    result.fold(
      (failure) => emit(LoginFailState(failure.message)),
      (auth) => emit(LoginSuccessState(auth)),
    );
  }
}
