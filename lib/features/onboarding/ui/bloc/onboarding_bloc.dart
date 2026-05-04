import 'package:domora/features/onboarding/domain/entities/avatar_file.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/onboarding/domain/params/client_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/params/provider_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/usecases/save_client_profile_usecase.dart';
import 'package:domora/features/onboarding/domain/usecases/save_provider_profile_usecase.dart';

// EVENTS
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

class OnboardingSaveClientEvent extends OnboardingEvent {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final AvatarFile? avatar;

  const OnboardingSaveClientEvent({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.avatar,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, phone, avatar];
}

class OnboardingSaveProviderEvent extends OnboardingEvent {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final int yearsExperience;
  final double hourlyRate;
  final String? bio;
  final AvatarFile? avatar;
  final String addressLine1;
  final String? addressLine2;
  final String department;
  final String city;
  final String? neighborhood;

  const OnboardingSaveProviderEvent({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.yearsExperience,
    required this.hourlyRate,
    this.bio,
    this.avatar,
    required this.addressLine1,
    this.addressLine2,
    required this.department,
    required this.city,
    this.neighborhood,
  });

  @override
  List<Object?> get props => [
    userId,
    firstName,
    lastName,
    phone,
    yearsExperience,
    hourlyRate,
    bio,
    avatar,
    addressLine1,
    addressLine2,
    department,
    city,
    neighborhood,
  ];
}

// STATES
abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object?> get props => [];
}

class OnboardingInitialState extends OnboardingState {
  const OnboardingInitialState();
}

class OnboardingLoadingState extends OnboardingState {
  const OnboardingLoadingState();
}

class OnboardingSuccessState extends OnboardingState {
  /// Rol del usuario para decidir el destino (`client` o `provider`).
  final String role;
  const OnboardingSuccessState(this.role);

  @override
  List<Object?> get props => [role];
}

class OnboardingFailState extends OnboardingState {
  final String message;
  const OnboardingFailState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SaveClientProfileUseCase _saveClient;
  final SaveProviderProfileUseCase _saveProvider;

  OnboardingBloc({
    required SaveClientProfileUseCase saveClient,
    required SaveProviderProfileUseCase saveProvider,
  })  : _saveClient = saveClient,
        _saveProvider = saveProvider,
        super(const OnboardingInitialState()) {
    on<OnboardingSaveClientEvent>(_onSaveClient);
    on<OnboardingSaveProviderEvent>(_onSaveProvider);
  }

  Future<void> _onSaveClient(
    OnboardingSaveClientEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoadingState());
    final result = await _saveClient(
      ClientOnboardingParams(
        userId: event.userId,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        avatar: event.avatar,
      ),
    );
    result.fold(
      (failure) => emit(OnboardingFailState(failure.message)),
      (_) => emit(const OnboardingSuccessState('client')),
    );
  }

  Future<void> _onSaveProvider(
    OnboardingSaveProviderEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoadingState());
    final result = await _saveProvider(
      ProviderOnboardingParams(
        userId: event.userId,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        yearsExperience: event.yearsExperience,
        hourlyRate: event.hourlyRate,
        bio: event.bio,
        avatar: event.avatar,
        addressLine1: event.addressLine1,
        addressLine2: event.addressLine2,
        department: event.department,
        city: event.city,
        neighborhood: event.neighborhood,
      ),
    );
    result.fold(
      (failure) => emit(OnboardingFailState(failure.message)),
      (_) => emit(const OnboardingSuccessState('provider')),
    );
  }
}
