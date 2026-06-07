import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/usecases/get_service_detail_usecase.dart';
import '../../domain/usecases/check_provider_has_proposed_usecase.dart';

// --- EVENTS ---
abstract class ServiceDetailEvent extends Equatable {
  const ServiceDetailEvent();
  @override
  List<Object?> get props => [];
}

class FetchServiceDetailEvent extends ServiceDetailEvent {
  final String serviceId;
  const FetchServiceDetailEvent(this.serviceId);
  @override
  List<Object?> get props => [serviceId];
}

// --- STATE ---
enum ServiceDetailStatus { initial, loading, success, error }

class ServiceDetailState extends Equatable {
  final ServiceDetailStatus status;
  final ServiceDetail? serviceDetail;
  final String? errorMessage;
  final bool isProvider;
  final String? currentUserId;
  final bool hasProposed;

  const ServiceDetailState({
    this.status = ServiceDetailStatus.initial,
    this.serviceDetail,
    this.errorMessage,
    this.isProvider = false,
    this.currentUserId,
    this.hasProposed = false,
  });

  ServiceDetailState copyWith({
    ServiceDetailStatus? status,
    ServiceDetail? serviceDetail,
    String? errorMessage,
    bool? isProvider,
    String? currentUserId,
    bool? hasProposed,
  }) {
    return ServiceDetailState(
      status: status ?? this.status,
      serviceDetail: serviceDetail ?? this.serviceDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isProvider: isProvider ?? this.isProvider,
      currentUserId: currentUserId ?? this.currentUserId,
      hasProposed: hasProposed ?? this.hasProposed,
    );
  }

  @override
  List<Object?> get props => [
        status,
        serviceDetail,
        errorMessage,
        isProvider,
        currentUserId,
        hasProposed
      ];
}

// --- BLOC ---
class ServiceDetailBloc extends Bloc<ServiceDetailEvent, ServiceDetailState> {
  final GetServiceDetailUseCase _getServiceDetail;
  final GetCurrentSessionUseCase _getCurrentSession;
  final CheckProviderHasProposedUseCase _checkHasProposed;

  ServiceDetailBloc(
      this._getServiceDetail, this._getCurrentSession, this._checkHasProposed)
      : super(const ServiceDetailState()) {
    on<FetchServiceDetailEvent>(_onFetch);
  }

  Future<void> _onFetch(
      FetchServiceDetailEvent event, Emitter<ServiceDetailState> emit) async {
    emit(state.copyWith(status: ServiceDetailStatus.loading));

    // Obtener sesión y rol a través del caso de uso
    final sessionResult = await _getCurrentSession();
    String? userId;
    bool isProvider = false;
    bool hasProposed = false;

    sessionResult.fold(
      (_) {},
      (authResult) {
        if (authResult != null) {
          userId = authResult.userId;
          isProvider = authResult.role == 'provider';
        }
      },
    );

    if (isProvider && userId != null) {
      final proposalResult =
          await _checkHasProposed.execute(event.serviceId, userId!);
      proposalResult.fold((_) {}, (exists) => hasProposed = exists);
    }

    final result = await _getServiceDetail.execute(event.serviceId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ServiceDetailStatus.error,
        errorMessage: failure.message,
        isProvider: isProvider,
        currentUserId: userId,
        hasProposed: hasProposed,
      )),
      (detail) => emit(state.copyWith(
        status: ServiceDetailStatus.success,
        serviceDetail: detail,
        isProvider: isProvider,
        currentUserId: userId,
        hasProposed: hasProposed,
      )),
    );
  }
}
