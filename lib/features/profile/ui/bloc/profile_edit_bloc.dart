import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/core/entities/avatar_file.dart';
import 'package:domora/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_client_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_provider_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_provider_address_usecase.dart';
import 'package:domora/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_email_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_password_usecase.dart';

// Events
abstract class ProfileEditEvent extends Equatable {
  const ProfileEditEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfileFieldsEvent extends ProfileEditEvent {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? phone;

  const UpdateProfileFieldsEvent(
      {required this.userId, this.firstName, this.lastName, this.phone});

  @override
  List<Object?> get props => [userId, firstName, lastName, phone];
}

class UpdateClientProfileEvent extends ProfileEditEvent {
  final String userId;
  final String? bio;
  final String? avatarUrl;

  const UpdateClientProfileEvent({
    required this.userId,
    this.bio,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [userId, bio, avatarUrl];
}

class UpdateProviderProfileEvent extends ProfileEditEvent {
  final String userId;
  final int? yearsExperience;
  final double? hourlyRate;
  final bool? isAvailable;
  final String? bio;
  final String? avatarUrl;

  const UpdateProviderProfileEvent({
    required this.userId,
    this.yearsExperience,
    this.hourlyRate,
    this.isAvailable,
    this.bio,
    this.avatarUrl,
  });

  @override
  List<Object?> get props =>
      [userId, yearsExperience, hourlyRate, isAvailable, bio, avatarUrl];
}

class UpdateProviderAddressEvent extends ProfileEditEvent {
  final String userId;
  final String addressLine1;
  final String? addressLine2;
  final String department;
  final String city;
  final String? neighborhood;

  const UpdateProviderAddressEvent({
    required this.userId,
    required this.addressLine1,
    this.addressLine2,
    required this.department,
    required this.city,
    this.neighborhood,
  });

  @override
  List<Object?> get props =>
      [userId, addressLine1, addressLine2, department, city, neighborhood];
}

class UploadAvatarEvent extends ProfileEditEvent {
  final String userId;
  final AvatarFile avatarFile;
  final bool isProvider;

  const UploadAvatarEvent({
    required this.userId,
    required this.avatarFile,
    required this.isProvider,
  });

  @override
  List<Object?> get props => [userId, avatarFile, isProvider];
}

class UpdateEmailEvent extends ProfileEditEvent {
  final String currentEmail;
  final String currentPassword;
  final String newEmail;
  const UpdateEmailEvent({
    required this.currentEmail,
    required this.currentPassword,
    required this.newEmail,
  });

  @override
  List<Object?> get props => [currentEmail, currentPassword, newEmail];
}

class UpdatePasswordEvent extends ProfileEditEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  const UpdatePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

class ProfileEditResetEvent extends ProfileEditEvent {
  const ProfileEditResetEvent();
}

// States
abstract class ProfileEditState extends Equatable {
  const ProfileEditState();

  @override
  List<Object?> get props => [];
}

class ProfileEditInitial extends ProfileEditState {
  const ProfileEditInitial();
}

class ProfileEditLoading extends ProfileEditState {
  const ProfileEditLoading();
}

enum ProfileEditSuccessKind {
  fieldsUpdated,
  clientProfileUpdated,
  providerProfileUpdated,
  locationUpdated,
  emailUpdated,
  passwordUpdated,
}

class ProfileEditSuccess extends ProfileEditState {
  final ProfileEditSuccessKind kind;
  final String message;
  const ProfileEditSuccess({required this.kind, this.message = 'OK'});

  @override
  List<Object?> get props => [kind, message];
}

class AvatarUploadSuccess extends ProfileEditState {
  final String avatarUrl;
  const AvatarUploadSuccess(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class ProfileEditFailure extends ProfileEditState {
  final String message;
  const ProfileEditFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  final UpdateProfileUseCase _updateProfile;
  final UpdateClientProfileUseCase _updateClientProfile;
  final UpdateProviderProfileUseCase _updateProviderProfile;
  final UpdateProviderAddressUseCase _updateProviderAddress;
  final UploadAvatarUseCase _uploadAvatar;
  final UpdateEmailUseCase _updateEmail;
  final UpdatePasswordUseCase _updatePassword;

  ProfileEditBloc(
    this._updateProfile,
    this._updateClientProfile,
    this._updateProviderProfile,
    this._updateProviderAddress,
    this._uploadAvatar,
    this._updateEmail,
    this._updatePassword,
  ) : super(const ProfileEditInitial()) {
    on<UpdateProfileFieldsEvent>(_onUpdateProfileFields);
    on<UpdateClientProfileEvent>(_onUpdateClientProfile);
    on<UpdateProviderProfileEvent>(_onUpdateProviderProfile);
    on<UpdateProviderAddressEvent>(_onUpdateProviderAddress);
    on<UploadAvatarEvent>(_onUploadAvatar);
    on<UpdateEmailEvent>(_onUpdateEmail);
    on<UpdatePasswordEvent>(_onUpdatePassword);
    on<ProfileEditResetEvent>(_onReset);
  }

  Future<void> _onUpdateProfileFields(
      UpdateProfileFieldsEvent event, Emitter<ProfileEditState> emit) async {
    emit(const ProfileEditLoading());
    final res = await _updateProfile(
      UpdateUserFieldsParams(
        userId: event.userId,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
      ),
    );
    res.fold(
      (f) => emit(ProfileEditFailure(f.message)),
      (_) => emit(const ProfileEditSuccess(
        kind: ProfileEditSuccessKind.fieldsUpdated,
        message: 'Perfil actualizado',
      )),
    );
  }

  Future<void> _onUpdateClientProfile(
      UpdateClientProfileEvent event, Emitter<ProfileEditState> emit) async {
    emit(const ProfileEditLoading());
    final res = await _updateClientProfile(
      UpdateClientProfileParams(
        userId: event.userId,
        bio: event.bio,
        avatarUrl: event.avatarUrl,
      ),
    );
    res.fold(
      (f) => emit(ProfileEditFailure(f.message)),
      (_) => emit(const ProfileEditSuccess(
        kind: ProfileEditSuccessKind.clientProfileUpdated,
        message: 'Perfil de cliente actualizado',
      )),
    );
  }

  Future<void> _onUpdateProviderProfile(
      UpdateProviderProfileEvent event, Emitter<ProfileEditState> emit) async {
    emit(const ProfileEditLoading());
    final res = await _updateProviderProfile(
      UpdateProviderProfileParams(
        userId: event.userId,
        yearsExperience: event.yearsExperience,
        hourlyRate: event.hourlyRate,
        isAvailable: event.isAvailable,
        bio: event.bio,
        avatarUrl: event.avatarUrl,
      ),
    );
    res.fold(
      (f) => emit(ProfileEditFailure(f.message)),
      (_) => emit(const ProfileEditSuccess(
        kind: ProfileEditSuccessKind.providerProfileUpdated,
        message: 'Perfil de proveedor actualizado',
      )),
    );
  }

  Future<void> _onUpdateProviderAddress(
    UpdateProviderAddressEvent event,
    Emitter<ProfileEditState> emit,
  ) async {
    emit(const ProfileEditLoading());
    final res = await _updateProviderAddress(
      UpdateProviderAddressParams(
        userId: event.userId,
        addressLine1: event.addressLine1,
        addressLine2: event.addressLine2,
        department: event.department,
        city: event.city,
        neighborhood: event.neighborhood,
      ),
    );
    res.fold(
      (f) => emit(ProfileEditFailure(f.message)),
      (_) => emit(const ProfileEditSuccess(
        kind: ProfileEditSuccessKind.locationUpdated,
        message: 'Ubicación actualizada',
      )),
    );
  }

  Future<void> _onUploadAvatar(
      UploadAvatarEvent event, Emitter<ProfileEditState> emit) async {
    emit(const ProfileEditLoading());
    final res = await _uploadAvatar(
      userId: event.userId,
      avatarFile: event.avatarFile,
      isProvider: event.isProvider,
    );
    res.fold(
      (f) => emit(ProfileEditFailure(f.message)),
      (url) => emit(AvatarUploadSuccess(url)),
    );
  }

  Future<void> _onUpdateEmail(
      UpdateEmailEvent event, Emitter<ProfileEditState> emit) async {
    emit(const ProfileEditLoading());
    final res = await _updateEmail(
      currentEmail: event.currentEmail,
      currentPassword: event.currentPassword,
      newEmail: event.newEmail,
    );
    res.fold(
      (f) => emit(ProfileEditFailure(f.message)),
      (_) => emit(const ProfileEditSuccess(
        kind: ProfileEditSuccessKind.emailUpdated,
        message: 'Correo actualizado',
      )),
    );
  }

  Future<void> _onUpdatePassword(
      UpdatePasswordEvent event, Emitter<ProfileEditState> emit) async {
    emit(const ProfileEditLoading());
    if (event.newPassword != event.confirmPassword) {
      emit(const ProfileEditFailure(
          'La nueva contraseña y su confirmación no coinciden'));
      return;
    }

    final res = await _updatePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    res.fold(
      (f) => emit(ProfileEditFailure(f.message)),
      (_) => emit(const ProfileEditSuccess(
        kind: ProfileEditSuccessKind.passwordUpdated,
        message: 'Contraseña actualizada',
      )),
    );
  }

  Future<void> _onReset(
      ProfileEditResetEvent event, Emitter<ProfileEditState> emit) async {
    emit(const ProfileEditInitial());
  }
}
