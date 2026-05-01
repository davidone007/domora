import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/profile/domain/model/full_profile.dart';
import 'package:domora/features/profile/domain/repository/profile_repository.dart';

// ---------------------------------------------------------------------------
// EVENTS
// ---------------------------------------------------------------------------
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadEvent extends ProfileEvent {
  const ProfileLoadEvent();
}

class ProfileRefreshEvent extends ProfileEvent {
  const ProfileRefreshEvent();
}

// ---------------------------------------------------------------------------
// STATES
// ---------------------------------------------------------------------------
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileLoadedState extends ProfileState {
  final FullProfile profile;
  const ProfileLoadedState(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileErrorState extends ProfileState {
  final String message;
  const ProfileErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// BLOC
// ---------------------------------------------------------------------------
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(const ProfileInitialState()) {
    on<ProfileLoadEvent>(_onLoad);
    on<ProfileRefreshEvent>(_onLoad);
  }

  Future<void> _onLoad(
    ProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    final result = await _repository.getCurrentProfile();
    result.fold(
      (failure) => emit(ProfileErrorState(failure.message)),
      (profile) => emit(ProfileLoadedState(profile)),
    );
  }
}
