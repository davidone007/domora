import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
import '../../domain/entities/proposal_with_service.dart';
import '../../domain/usecases/get_my_proposals_usecase.dart';

// --- EVENTS ---
abstract class MyProposalsEvent extends Equatable {
  const MyProposalsEvent();
  @override
  List<Object?> get props => [];
}

class FetchMyProposalsEvent extends MyProposalsEvent {
  const FetchMyProposalsEvent();
}

// --- STATE ---
enum MyProposalsStatus { initial, loading, success, error }

class MyProposalsState extends Equatable {
  final MyProposalsStatus status;
  final List<ProposalWithService> proposals;
  final String? errorMessage;

  const MyProposalsState({
    this.status = MyProposalsStatus.initial,
    this.proposals = const [],
    this.errorMessage,
  });

  MyProposalsState copyWith({
    MyProposalsStatus? status,
    List<ProposalWithService>? proposals,
    String? errorMessage,
  }) {
    return MyProposalsState(
      status: status ?? this.status,
      proposals: proposals ?? this.proposals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, proposals, errorMessage];
}

// --- BLOC ---
class MyProposalsBloc extends Bloc<MyProposalsEvent, MyProposalsState> {
  final GetMyProposalsUseCase _getMyProposals;
  final GetCurrentSessionUseCase _getCurrentSession;

  MyProposalsBloc({
    required GetMyProposalsUseCase getMyProposals,
    required GetCurrentSessionUseCase getCurrentSession,
  })  : _getMyProposals = getMyProposals,
        _getCurrentSession = getCurrentSession,
        super(const MyProposalsState()) {
    on<FetchMyProposalsEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchMyProposalsEvent event,
    Emitter<MyProposalsState> emit,
  ) async {
    emit(state.copyWith(status: MyProposalsStatus.loading));

    final sessionResult = await _getCurrentSession();
    final auth = sessionResult.fold((_) => null, (a) => a);

    if (auth == null) {
      emit(state.copyWith(
        status: MyProposalsStatus.error,
        errorMessage: 'Sesión expirada',
      ));
      return;
    }

    final result = await _getMyProposals.execute(auth.userId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: MyProposalsStatus.error,
        errorMessage: failure.message,
      )),
      (proposals) => emit(state.copyWith(
        status: MyProposalsStatus.success,
        proposals: proposals,
      )),
    );
  }
}
