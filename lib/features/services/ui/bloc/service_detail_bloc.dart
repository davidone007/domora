import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/usecases/get_service_detail_usecase.dart';

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

  const ServiceDetailState({
    this.status = ServiceDetailStatus.initial,
    this.serviceDetail,
    this.errorMessage,
    this.isProvider = false,
    this.currentUserId,
  });

  ServiceDetailState copyWith({
    ServiceDetailStatus? status,
    ServiceDetail? serviceDetail,
    String? errorMessage,
    bool? isProvider,
    String? currentUserId,
  }) {
    return ServiceDetailState(
      status: status ?? this.status,
      serviceDetail: serviceDetail ?? this.serviceDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isProvider: isProvider ?? this.isProvider,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  @override
  List<Object?> get props => [status, serviceDetail, errorMessage, isProvider, currentUserId];
}

// --- BLOC ---
class ServiceDetailBloc extends Bloc<ServiceDetailEvent, ServiceDetailState> {
  final GetServiceDetailUseCase _getServiceDetail;
  final AuthRepository _authRepository;

  ServiceDetailBloc(this._getServiceDetail, this._authRepository) : super(const ServiceDetailState()) {
    on<FetchServiceDetailEvent>(_onFetch);
  }

  Future<void> _onFetch(FetchServiceDetailEvent event, Emitter<ServiceDetailState> emit) async {
    emit(state.copyWith(status: ServiceDetailStatus.loading));
    
    // Fetch role and userId from session
    final sessionResult = await _authRepository.getCurrentSession();
    String? userId;
    bool isProvider = false;

    sessionResult.fold(
      (_) {},
      (authResult) {
        if (authResult != null) {
          userId = authResult.userId;
          isProvider = authResult.role == 'provider';
        }
      },
    );

    final result = await _getServiceDetail.execute(event.serviceId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: ServiceDetailStatus.error,
        errorMessage: failure.message,
        isProvider: isProvider,
        currentUserId: userId,
      )),
      (detail) => emit(state.copyWith(
        status: ServiceDetailStatus.success,
        serviceDetail: detail,
        isProvider: isProvider,
        currentUserId: userId,
      )),
    );
  }
}
