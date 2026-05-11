import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/usecases/check_user_proposal_usecase.dart';
import '../../domain/usecases/send_proposal_usecase.dart';

// --- EVENTS ---
abstract class ProposalSendEvent extends Equatable {
  const ProposalSendEvent();
  @override
  List<Object?> get props => [];
}

class CheckProposalStatusEvent extends ProposalSendEvent {
  final String serviceId;
  final String providerId;
  const CheckProposalStatusEvent({required this.serviceId, required this.providerId});
  @override
  List<Object?> get props => [serviceId, providerId];
}

class SubmitProposalEvent extends ProposalSendEvent {
  final Proposal proposal;
  const SubmitProposalEvent(this.proposal);
  @override
  List<Object?> get props => [proposal];
}

// --- STATE ---
enum ProposalSendStatus { initial, loading, submitting, success, error, alreadyProposed }

class ProposalSendState extends Equatable {
  final ProposalSendStatus status;
  final String? errorMessage;

  const ProposalSendState({
    this.status = ProposalSendStatus.initial,
    this.errorMessage,
  });

  ProposalSendState copyWith({
    ProposalSendStatus? status,
    String? errorMessage,
  }) {
    return ProposalSendState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

// --- BLOC ---
class ProposalSendBloc extends Bloc<ProposalSendEvent, ProposalSendState> {
  final SendProposalUseCase _sendProposal;
  final CheckUserProposalUseCase _checkUserProposal;

  ProposalSendBloc(this._sendProposal, this._checkUserProposal)
      : super(const ProposalSendState()) {
    on<CheckProposalStatusEvent>(_onCheckStatus);
    on<SubmitProposalEvent>(_onSubmit);
  }

  Future<void> _onCheckStatus(
    CheckProposalStatusEvent event,
    Emitter<ProposalSendState> emit,
  ) async {
    emit(state.copyWith(status: ProposalSendStatus.loading));

    final result = await _checkUserProposal.execute(event.serviceId, event.providerId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProposalSendStatus.error,
        errorMessage: failure.message,
      )),
      (exists) {
        if (exists) {
          emit(state.copyWith(status: ProposalSendStatus.alreadyProposed));
        } else {
          emit(state.copyWith(status: ProposalSendStatus.initial));
        }
      },
    );
  }

  Future<void> _onSubmit(
    SubmitProposalEvent event,
    Emitter<ProposalSendState> emit,
  ) async {
    emit(state.copyWith(status: ProposalSendStatus.submitting));

    final result = await _sendProposal.execute(event.proposal);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProposalSendStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: ProposalSendStatus.success)),
    );
  }
}
