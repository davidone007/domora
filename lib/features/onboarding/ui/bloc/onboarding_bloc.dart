import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:domora/features/onboarding/data/sources/onboarding_data_source.dart';
import 'package:domora/features/onboarding/domain/usecases/save_client_profile_usecase.dart';
import 'package:domora/features/onboarding/domain/usecases/save_provider_profile_usecase.dart';

// EVENTS
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

class OnboardingSaveClientEvent extends OnboardingEvent {
  final ClientOnboardingData data;
  const OnboardingSaveClientEvent(this.data);
}

class OnboardingSaveProviderEvent extends OnboardingEvent {
  final ProviderOnboardingData data;
  const OnboardingSaveProviderEvent(this.data);
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
    final result = await _saveClient(event.data);
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
    final result = await _saveProvider(event.data);
    result.fold(
      (failure) => emit(OnboardingFailState(failure.message)),
      (_) => emit(const OnboardingSuccessState('provider')),
    );
  }
}
