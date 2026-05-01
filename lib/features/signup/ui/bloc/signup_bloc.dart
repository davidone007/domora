import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/auth/domain/repo/auth_repo.dart';
import 'package:domora/features/auth/domain/usecases/signup_usecase.dart';

// EVENTS
abstract class SignupEvent extends Equatable {
  const SignupEvent();
  @override
  List<Object?> get props => [];
}

class SignupSubmitEvent extends SignupEvent {
  final String email;
  final String password;
  final String role;

  const SignupSubmitEvent({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

class SignupResetEvent extends SignupEvent {
  const SignupResetEvent();
}

// STATES
abstract class SignupState extends Equatable {
  const SignupState();
  @override
  List<Object?> get props => [];
}

class SignupInitialState extends SignupState {
  const SignupInitialState();
}

class SignupLoadingState extends SignupState {
  const SignupLoadingState();
}

class SignupSuccessState extends SignupState {
  final AuthResult result;
  const SignupSuccessState(this.result);

  @override
  List<Object?> get props => [result];
}

class SignupFailState extends SignupState {
  final String message;
  const SignupFailState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupUseCase _signupUseCase;

  SignupBloc(this._signupUseCase) : super(const SignupInitialState()) {
    on<SignupSubmitEvent>(_onSubmit);
    on<SignupResetEvent>((_, emit) => emit(const SignupInitialState()));
  }

  Future<void> _onSubmit(
    SignupSubmitEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(const SignupLoadingState());

    final result = await _signupUseCase(
      SignupParams(
        email: event.email,
        password: event.password,
        role: event.role,
      ),
    );

    result.fold(
      (failure) => emit(SignupFailState(failure.message)),
      (auth) => emit(SignupSuccessState(auth)),
    );
  }
}
