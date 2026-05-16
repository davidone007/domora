import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
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
  const CheckProposalStatusEvent({required this.serviceId});
  @override
  List<Object?> get props => [serviceId];
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
  final GetCurrentSessionUseCase _getCurrentSession;

  ProposalSendBloc(
    this._sendProposal,
    this._checkUserProposal,
    this._getCurrentSession,
  ) : super(const ProposalSendState()) {
    on<CheckProposalStatusEvent>(_onCheckStatus);
    on<SubmitProposalEvent>(_onSubmit);
  }

  Future<void> _onCheckStatus(
    CheckProposalStatusEvent event,
    Emitter<ProposalSendState> emit,
  ) async {
    emit(state.copyWith(status: ProposalSendStatus.loading));

    // Obtener providerId de la sesión
    final sessionResult = await _getCurrentSession();
    
    final providerId = sessionResult.fold(
      (_) => null,
      (auth) => auth?.userId,
    );

    if (providerId == null) {
      emit(state.copyWith(
        status: ProposalSendStatus.error,
        errorMessage: 'Sesión no válida o expirada',
      ));
      return;
    }

    final result = await _checkUserProposal.execute(event.serviceId, providerId);

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

    // Obtener el userId real de la sesión e inyectarlo en la propuesta.
    final sessionResult = await _getCurrentSession();
    final currentUserId = sessionResult.fold((_) => null, (a) => a?.userId);

    if (currentUserId == null) {
      emit(state.copyWith(
        status: ProposalSendStatus.error,
        errorMessage: 'Sesión no válida o expirada',
      ));
      return;
    }

    // Construimos la propuesta final con el providerId real de la sesión.
    final proposalWithProvider = event.proposal.copyWith(providerId: currentUserId);

    final result = await _sendProposal.execute(proposalWithProvider);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProposalSendStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: ProposalSendStatus.success)),
    );
  }
}
