import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
import '../../domain/entities/proposal_with_provider.dart';
import '../../domain/usecases/get_proposals_by_service_usecase.dart';

// Events
abstract class ServiceProposalsEvent extends Equatable {
  const ServiceProposalsEvent();

  @override
  List<Object?> get props => [];
}

class FetchServiceProposalsEvent extends ServiceProposalsEvent {
  final String serviceId;

  const FetchServiceProposalsEvent(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class SortProposalsByPriceEvent extends ServiceProposalsEvent {
  final bool ascending;

  const SortProposalsByPriceEvent({this.ascending = true});

  @override
  List<Object?> get props => [ascending];
}

// States
enum ServiceProposalsStatus { initial, loading, success, error }

class ServiceProposalsState extends Equatable {
  final ServiceProposalsStatus status;
  final List<ProposalWithProvider> proposals;
  final String? errorMessage;

  const ServiceProposalsState({
    this.status = ServiceProposalsStatus.initial,
    this.proposals = const [],
    this.errorMessage,
  });

  ServiceProposalsState copyWith({
    ServiceProposalsStatus? status,
    List<ProposalWithProvider>? proposals,
    String? errorMessage,
  }) {
    return ServiceProposalsState(
      status: status ?? this.status,
      proposals: proposals ?? this.proposals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, proposals, errorMessage];
}

// BLoC
class ServiceProposalsBloc extends Bloc<ServiceProposalsEvent, ServiceProposalsState> {
  final GetProposalsByServiceUseCase _getProposalsByServiceUseCase;
  final GetCurrentSessionUseCase _getCurrentSession;

  ServiceProposalsBloc({
    required GetProposalsByServiceUseCase getProposalsByServiceUseCase,
    required GetCurrentSessionUseCase getCurrentSession,
  })  : _getProposalsByServiceUseCase = getProposalsByServiceUseCase,
        _getCurrentSession = getCurrentSession,
        super(const ServiceProposalsState()) {
    on<FetchServiceProposalsEvent>(_onFetchServiceProposals);
    on<SortProposalsByPriceEvent>(_onSortProposalsByPrice);
  }

  Future<void> _onFetchServiceProposals(
    FetchServiceProposalsEvent event,
    Emitter<ServiceProposalsState> emit,
  ) async {
    emit(state.copyWith(status: ServiceProposalsStatus.loading));

    // Validamos identidad del cliente para asegurar propiedad del servicio (HU12).
    final sessionResult = await _getCurrentSession();
    final userId = sessionResult.fold((_) => null, (auth) => auth?.userId);

    if (userId == null) {
      emit(state.copyWith(
        status: ServiceProposalsStatus.error,
        errorMessage: 'Sesión no válida o expirada',
      ));
      return;
    }

    final result = await _getProposalsByServiceUseCase.execute(
      serviceId: event.serviceId,
      clientId: userId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ServiceProposalsStatus.error,
        errorMessage: failure.message,
      )),
      (proposals) => emit(state.copyWith(
        status: ServiceProposalsStatus.success,
        proposals: proposals,
      )),
    );
  }

  void _onSortProposalsByPrice(
    SortProposalsByPriceEvent event,
    Emitter<ServiceProposalsState> emit,
  ) {
    if (state.status != ServiceProposalsStatus.success) return;

    final sortedProposals = List<ProposalWithProvider>.from(state.proposals);
    sortedProposals.sort((a, b) => event.ascending
        ? a.proposal.price.compareTo(b.proposal.price)
        : b.proposal.price.compareTo(a.proposal.price));

    emit(state.copyWith(proposals: sortedProposals));
  }
}
