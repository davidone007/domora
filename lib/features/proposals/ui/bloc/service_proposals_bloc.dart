import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  ServiceProposalsBloc({
    required GetProposalsByServiceUseCase getProposalsByServiceUseCase,
  })  : _getProposalsByServiceUseCase = getProposalsByServiceUseCase,
        super(const ServiceProposalsState()) {
    on<FetchServiceProposalsEvent>(_onFetchServiceProposals);
    on<SortProposalsByPriceEvent>(_onSortProposalsByPrice);
  }

  Future<void> _onFetchServiceProposals(
    FetchServiceProposalsEvent event,
    Emitter<ServiceProposalsState> emit,
  ) async {
    emit(state.copyWith(status: ServiceProposalsStatus.loading));

    final result = await _getProposalsByServiceUseCase.execute(event.serviceId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ServiceProposalsStatus.error,
        errorMessage: 'Error al cargar las propuestas',
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
