import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/auth/domain/usecases/signout_usecase.dart';

abstract class ProfileSignOutEvent extends Equatable {
  const ProfileSignOutEvent();

  @override
  List<Object?> get props => [];
}

class ProfileSignOutSubmitEvent extends ProfileSignOutEvent {
  const ProfileSignOutSubmitEvent();
}

abstract class ProfileSignOutState extends Equatable {
  const ProfileSignOutState();

  @override
  List<Object?> get props => [];
}

class ProfileSignOutInitialState extends ProfileSignOutState {
  const ProfileSignOutInitialState();
}

class ProfileSignOutLoadingState extends ProfileSignOutState {
  const ProfileSignOutLoadingState();
}

class ProfileSignOutSuccessState extends ProfileSignOutState {
  const ProfileSignOutSuccessState();
}

class ProfileSignOutFailState extends ProfileSignOutState {
  final String message;

  const ProfileSignOutFailState(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileSignOutBloc extends Bloc<ProfileSignOutEvent, ProfileSignOutState> {
  final SignOutUseCase _signOut;

  ProfileSignOutBloc(this._signOut) : super(const ProfileSignOutInitialState()) {
    on<ProfileSignOutSubmitEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    ProfileSignOutSubmitEvent event,
    Emitter<ProfileSignOutState> emit,
  ) async {
    emit(const ProfileSignOutLoadingState());
    final result = await _signOut();
    result.fold(
      (failure) => emit(ProfileSignOutFailState(failure.message)),
      (_) => emit(const ProfileSignOutSuccessState()),
    );
  }
}
