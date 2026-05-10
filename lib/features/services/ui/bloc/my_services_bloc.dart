import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/service.dart';
import '../../domain/usecases/get_my_services_usecase.dart';

// --- EVENTS ---
abstract class MyServicesEvent extends Equatable {
  const MyServicesEvent();
  @override
  List<Object?> get props => [];
}

class FetchMyServicesEvent extends MyServicesEvent {
  final String userId;
  const FetchMyServicesEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class FilterMyServicesEvent extends MyServicesEvent {
  final String? status;
  const FilterMyServicesEvent(this.status);
  @override
  List<Object?> get props => [status];
}

// --- STATE ---
enum MyServicesStatus { initial, loading, success, error }

class MyServicesState extends Equatable {
  final MyServicesStatus status;
  final List<Service> allServices;
  final List<Service> filteredServices;
  final String? selectedStatus;
  final String? errorMessage;

  const MyServicesState({
    this.status = MyServicesStatus.initial,
    this.allServices = const [],
    this.filteredServices = const [],
    this.selectedStatus,
    this.errorMessage,
  });

  MyServicesState copyWith({
    MyServicesStatus? status,
    List<Service>? allServices,
    List<Service>? filteredServices,
    String? selectedStatus,
    bool clearStatus = false,
    String? errorMessage,
  }) {
    return MyServicesState(
      status: status ?? this.status,
      allServices: allServices ?? this.allServices,
      filteredServices: filteredServices ?? this.filteredServices,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allServices, filteredServices, selectedStatus, errorMessage];
}

// --- BLOC ---
class MyServicesBloc extends Bloc<MyServicesEvent, MyServicesState> {
  final GetMyServicesUseCase _getMyServices;

  MyServicesBloc(this._getMyServices) : super(const MyServicesState()) {
    on<FetchMyServicesEvent>(_onFetch);
    on<FilterMyServicesEvent>(_onFilter);
  }

  Future<void> _onFetch(FetchMyServicesEvent event, Emitter<MyServicesState> emit) async {
    emit(state.copyWith(status: MyServicesStatus.loading));
    
    final result = await _getMyServices.execute(event.userId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: MyServicesStatus.error,
        errorMessage: failure.message,
      )),
      (services) => emit(state.copyWith(
        status: MyServicesStatus.success,
        allServices: services,
        filteredServices: _applyFilter(services, state.selectedStatus),
      )),
    );
  }

  void _onFilter(FilterMyServicesEvent event, Emitter<MyServicesState> emit) {
    emit(state.copyWith(
      selectedStatus: event.status,
      clearStatus: event.status == null,
      filteredServices: _applyFilter(state.allServices, event.status),
    ));
  }

  List<Service> _applyFilter(List<Service> services, String? status) {
    if (status == null || status.isEmpty) return services;
    return services.where((s) => s.status == status).toList();
  }
}
