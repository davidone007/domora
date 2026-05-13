import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/utils/constants.dart';
import '../../domain/entities/service.dart';
import '../../domain/usecases/get_my_services_usecase.dart';
import '../../domain/usecases/get_all_services_usecase.dart';
import '../../../auth/domain/repo/auth_repo.dart';

// --- EVENTS ---
abstract class MyServicesEvent extends Equatable {
  const MyServicesEvent();
  @override
  List<Object?> get props => [];
}

class FetchMyServicesEvent extends MyServicesEvent {
  final String userId;
  final String? role; 
  const FetchMyServicesEvent(this.userId, {this.role});
  @override
  List<Object?> get props => [userId, role];
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

  const MyServicesState({
    this.status = MyServicesStatus.initial,
    this.allServices = const [],
    this.filteredServices = const [],
    this.selectedStatus,
    this.errorMessage,
    this.role,
  });

  MyServicesState copyWith({
    MyServicesStatus? status,
    List<Service>? allServices,
    List<Service>? filteredServices,
    String? selectedStatus,
    bool clearStatus = false,
    String? errorMessage,
    String? role,
  }) {
    return MyServicesState(
      status: status ?? this.status,
      allServices: allServices ?? this.allServices,
      filteredServices: filteredServices ?? this.filteredServices,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      errorMessage: errorMessage ?? this.errorMessage,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [status, allServices, filteredServices, selectedStatus, errorMessage, role];
}

// --- BLOC ---
class MyServicesBloc extends Bloc<MyServicesEvent, MyServicesState> {
  final GetMyServicesUseCase _getMyServices;
  final GetAllServicesUseCase _getAllServices;
  final AuthRepository _authRepository;

  MyServicesBloc(
    this._getMyServices,
    this._getAllServices,
    this._authRepository,
  ) : super(const MyServicesState()) {
    on<FetchMyServicesEvent>(_onFetch);
    on<FilterMyServicesEvent>(_onFilter);
  }

  Future<void> _onFetch(FetchMyServicesEvent event, Emitter<MyServicesState> emit) async {
    emit(state.copyWith(status: MyServicesStatus.loading));

    String? role = event.role;
    
    // 1. Intentar obtener el rol desde metadatos de Supabase (es rápido y suele estar disponible)
    if (role == null) {
      final user = Supabase.instance.client.auth.currentUser;
      role = user?.userMetadata?['role'] as String?;
    }

    // 2. Si aún no tenemos el rol, lo buscamos en la base de datos (fuente de verdad definitiva)
    if (role == null) {
      final sessionResult = await _authRepository.getCurrentSession();
      role = sessionResult.fold(
        (_) => AppConstants.roleClient, // Por defecto cliente en caso de error
        (res) => res?.role ?? AppConstants.roleClient,
      );
    }

    emit(state.copyWith(role: role));
    
    final result = role == AppConstants.roleProvider 
        ? await _getAllServices.execute()
        : await _getMyServices.execute(event.userId);
    
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
