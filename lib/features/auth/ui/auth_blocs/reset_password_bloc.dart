import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/auth/domain/usecases/set_new_password_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------
abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();
  @override
  List<Object?> get props => [];
}

class ResetPasswordSubmitEvent extends ResetPasswordEvent {
  final String newPassword;
  const ResetPasswordSubmitEvent(this.newPassword);
  @override
  List<Object?> get props => [newPassword];
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
enum ResetPasswordStatus { idle, loading, success, error }

class ResetPasswordState extends Equatable {
  final ResetPasswordStatus status;
  final String? errorMessage;

  const ResetPasswordState({
    this.status = ResetPasswordStatus.idle,
    this.errorMessage,
  });

  ResetPasswordState copyWith({
    ResetPasswordStatus? status,
    String? errorMessage,
  }) =>
      ResetPasswordState(
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, errorMessage];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------
class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final SetNewPasswordUseCase _setNewPassword;

  ResetPasswordBloc(this._setNewPassword)
      : super(const ResetPasswordState()) {
    on<ResetPasswordSubmitEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    ResetPasswordSubmitEvent event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(state.copyWith(status: ResetPasswordStatus.loading));
    final result = await _setNewPassword(event.newPassword);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ResetPasswordStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: ResetPasswordStatus.success)),
    );
  }
}
