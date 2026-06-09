import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/domain/usecases/get_current_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_provider_profile_usecase.dart';

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

/// Invierte el campo `is_available` del proveedor autenticado.
class ProfileToggleAvailabilityEvent extends ProfileEvent {
  const ProfileToggleAvailabilityEvent();
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

/// Estado intermedio durante el toggle de disponibilidad. Conserva
/// el perfil actual para que la UI no pierda el dato mientras espera.
class ProfileTogglingAvailabilityState extends ProfileState {
  final FullProfile profile;
  const ProfileTogglingAvailabilityState(this.profile);

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
  final GetCurrentProfileUseCase _getCurrentProfile;
  final UpdateProviderProfileUseCase _updateProviderProfile;

  ProfileBloc(this._getCurrentProfile, this._updateProviderProfile)
      : super(const ProfileInitialState()) {
    on<ProfileLoadEvent>(_onLoad);
    on<ProfileRefreshEvent>(_onLoad);
    on<ProfileToggleAvailabilityEvent>(_onToggleAvailability);
  }

  Future<void> _onLoad(
    ProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    final result = await _getCurrentProfile();
    result.fold(
      (failure) => emit(ProfileErrorState(failure.message)),
      (profile) => emit(ProfileLoadedState(profile)),
    );
  }

  Future<void> _onToggleAvailability(
    ProfileToggleAvailabilityEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoadedState) return;
    final provider = current.profile.providerProfile;
    if (provider == null) return;

    emit(ProfileTogglingAvailabilityState(current.profile));

    final newAvailability = !provider.isAvailable;
    final result = await _updateProviderProfile(
      UpdateProviderProfileParams(
        userId: current.profile.user.id,
        isAvailable: newAvailability,
      ),
    );

    await result.fold(
      (failure) async => emit(ProfileErrorState(failure.message)),
      (_) async {
        final reloadResult = await _getCurrentProfile();
        reloadResult.fold(
          (failure) => emit(ProfileErrorState(failure.message)),
          (profile) => emit(ProfileLoadedState(profile)),
        );
      },
    );
  }
}
