import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/full_profile.dart';
import '../../domain/usecases/get_provider_profile_usecase.dart';

// Events
abstract class ProviderPublicProfileEvent extends Equatable {
  const ProviderPublicProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProviderPublicProfileEvent extends ProviderPublicProfileEvent {
  final String userId;

  const FetchProviderPublicProfileEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// States
enum ProviderPublicProfileStatus { initial, loading, success, error }

class ProviderPublicProfileState extends Equatable {
  final ProviderPublicProfileStatus status;
  final FullProfile? profile;
  final String? errorMessage;

  const ProviderPublicProfileState({
    this.status = ProviderPublicProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  ProviderPublicProfileState copyWith({
    ProviderPublicProfileStatus? status,
    FullProfile? profile,
    String? errorMessage,
  }) {
    return ProviderPublicProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}

// BLoC
class ProviderPublicProfileBloc extends Bloc<ProviderPublicProfileEvent, ProviderPublicProfileState> {
  final GetProviderProfileUseCase _getProviderProfileUseCase;

  ProviderPublicProfileBloc({
    required GetProviderProfileUseCase getProviderProfileUseCase,
  })  : _getProviderProfileUseCase = getProviderProfileUseCase,
        super(const ProviderPublicProfileState()) {
    on<FetchProviderPublicProfileEvent>(_onFetchProviderPublicProfile);
  }

  Future<void> _onFetchProviderPublicProfile(
    FetchProviderPublicProfileEvent event,
    Emitter<ProviderPublicProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProviderPublicProfileStatus.loading));

    final result = await _getProviderProfileUseCase.execute(event.userId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProviderPublicProfileStatus.error,
        errorMessage: 'No se pudo cargar el perfil del proveedor',
      )),
      (profile) => emit(state.copyWith(
        status: ProviderPublicProfileStatus.success,
        profile: profile,
      )),
    );
  }
}
