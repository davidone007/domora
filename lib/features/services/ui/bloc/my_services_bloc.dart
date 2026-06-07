import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/utils/constants.dart';
import '../../domain/entities/service.dart';
import '../../domain/usecases/get_my_services_usecase.dart';
import '../../domain/usecases/get_all_services_usecase.dart';
import '../../../auth/domain/usecases/get_current_session_usecase.dart';

// --- EVENTS ---
abstract class MyServicesEvent extends Equatable {
  const MyServicesEvent();
  @override
  List<Object?> get props => [];
}

class FetchMyServicesEvent extends MyServicesEvent {
  final String? role;
  const FetchMyServicesEvent({this.role});
  @override
  List<Object?> get props => [role];
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
  final String? role;
  final String? currentUserId;

  const MyServicesState({
    this.status = MyServicesStatus.initial,
    this.allServices = const [],
    this.filteredServices = const [],
    this.selectedStatus,
    this.errorMessage,
    this.role,
    this.currentUserId,
  });

  MyServicesState copyWith({
    MyServicesStatus? status,
    List<Service>? allServices,
    List<Service>? filteredServices,
    String? selectedStatus,
    bool clearStatus = false,
    String? errorMessage,
    String? role,
    String? currentUserId,
  }) {
    return MyServicesState(
      status: status ?? this.status,
      allServices: allServices ?? this.allServices,
      filteredServices: filteredServices ?? this.filteredServices,
      selectedStatus:
          clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      errorMessage: errorMessage ?? this.errorMessage,
      role: role ?? this.role,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allServices,
        filteredServices,
        selectedStatus,
        errorMessage,
        role,
        currentUserId,
      ];
}

// --- BLOC ---
class MyServicesBloc extends Bloc<MyServicesEvent, MyServicesState> {
  final GetMyServicesUseCase _getMyServices;
  final GetAllServicesUseCase _getAllServices;
  final GetCurrentSessionUseCase _getCurrentSession;

  MyServicesBloc(
    this._getMyServices,
    this._getAllServices,
    this._getCurrentSession,
  ) : super(const MyServicesState()) {
    on<FetchMyServicesEvent>(_onFetch);
    on<FilterMyServicesEvent>(_onFilter);
  }

  Future<void> _onFetch(
      FetchMyServicesEvent event, Emitter<MyServicesState> emit) async {
    emit(state.copyWith(status: MyServicesStatus.loading));

    // 1. Obtener la sesión oficial (Fuente de Verdad)
    final sessionResult = await _getCurrentSession();
    
    String? userId;
    String? role = event.role;

    // Resolvemos identidad y rol desde la sesión
    sessionResult.fold(
      (failure) {
        emit(state.copyWith(
          status: MyServicesStatus.error,
          errorMessage: "No se pudo validar la sesión: ${failure.message}",
        ));
      },
      (auth) {
        userId = auth?.userId;
        role ??= auth?.role;
      },
    );

    // Si no hay usuario en la sesión, no podemos continuar
    if (userId == null) {
      if (state.status != MyServicesStatus.error) {
        emit(state.copyWith(
          status: MyServicesStatus.error,
          errorMessage: "Sesión no válida o expirada",
        ));
      }
      return;
    }

    emit(state.copyWith(role: role, currentUserId: userId));

    final result = role == AppConstants.roleProvider
        ? await _getAllServices.execute()
        : await _getMyServices.execute(userId!);

    result.fold(
      (failure) => emit(state.copyWith(
        status: MyServicesStatus.error,
        errorMessage: failure.message,
      )),
      (services) => emit(state.copyWith(
        status: MyServicesStatus.success,
        allServices: services,
        filteredServices: _applyFilter(
          services,
          state.selectedStatus,
          role: role,
          userId: userId,
        ),
      )),
    );
  }

  void _onFilter(FilterMyServicesEvent event, Emitter<MyServicesState> emit) {
    emit(state.copyWith(
      selectedStatus: event.status,
      clearStatus: event.status == null,
      filteredServices: _applyFilter(
        state.allServices,
        event.status,
        role: state.role,
        userId: state.currentUserId,
      ),
    ));
  }

  List<Service> _applyFilter(
    List<Service> services,
    String? status, {
    String? role,
    String? userId,
  }) {
    Iterable<Service> filtered = services;
    if (role == AppConstants.roleProvider && userId != null) {
      filtered = filtered.where((service) {
        if (service.status == 'open') {
          return true;
        }

        if (service.status == 'in_progress' || service.status == 'completed') {
          return service.bookingProviderId == userId;
        }

        return false;
      });
    }

    if (status == null || status.isEmpty) return filtered.toList();
    return filtered.where((service) => service.status == status).toList();
  }
}
