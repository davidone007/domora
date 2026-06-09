import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/full_profile.dart';
import '../../domain/usecases/get_client_public_profile_usecase.dart';

// Events
abstract class ClientPublicProfileEvent extends Equatable {
  const ClientPublicProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchClientPublicProfileEvent extends ClientPublicProfileEvent {
  final String userId;

  const FetchClientPublicProfileEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// States
enum ClientPublicProfileStatus { initial, loading, success, error }

class ClientPublicProfileState extends Equatable {
  final ClientPublicProfileStatus status;
  final FullProfile? profile;
  final String? errorMessage;

  const ClientPublicProfileState({
    this.status = ClientPublicProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  ClientPublicProfileState copyWith({
    ClientPublicProfileStatus? status,
    FullProfile? profile,
    String? errorMessage,
  }) {
    return ClientPublicProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}

// BLoC
class ClientPublicProfileBloc
    extends Bloc<ClientPublicProfileEvent, ClientPublicProfileState> {
  final GetClientPublicProfileUseCase _getClientPublicProfile;

  ClientPublicProfileBloc({
    required GetClientPublicProfileUseCase getClientPublicProfile,
  })  : _getClientPublicProfile = getClientPublicProfile,
        super(const ClientPublicProfileState()) {
    on<FetchClientPublicProfileEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchClientPublicProfileEvent event,
    Emitter<ClientPublicProfileState> emit,
  ) async {
    emit(state.copyWith(status: ClientPublicProfileStatus.loading));

    final result = await _getClientPublicProfile.execute(event.userId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ClientPublicProfileStatus.error,
        errorMessage: 'No se pudo cargar el perfil del cliente',
      )),
      (profile) => emit(state.copyWith(
        status: ClientPublicProfileStatus.success,
        profile: profile,
      )),
    );
  }
}
