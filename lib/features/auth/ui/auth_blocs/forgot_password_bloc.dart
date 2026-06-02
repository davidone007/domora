import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/auth/domain/usecases/request_password_reset_usecase.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
  @override
  List<Object?> get props => [];
}

class ForgotPasswordSubmitEvent extends ForgotPasswordEvent {
  final String email;
  const ForgotPasswordSubmitEvent(this.email);
  @override
  List<Object?> get props => [email];
}

enum ForgotPasswordStatus { idle, submitting, success, error }

class ForgotPasswordState extends Equatable {
  final ForgotPasswordStatus status;
  final String? errorMessage;

  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.idle,
    this.errorMessage,
  });

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final RequestPasswordResetUseCase _requestPasswordReset;

  ForgotPasswordBloc(this._requestPasswordReset)
      : super(const ForgotPasswordState()) {
    on<ForgotPasswordSubmitEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    ForgotPasswordSubmitEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(status: ForgotPasswordStatus.submitting));
    final result = await _requestPasswordReset(event.email);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: ForgotPasswordStatus.success)),
    );
  }
}
