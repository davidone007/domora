import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/device_position.dart';
import '../../domain/entities/service_address.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/reverse_geocode_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

/// Solicita obtener la posición GPS actual y geocodificar la dirección.
class LocationFetchEvent extends LocationEvent {
  const LocationFetchEvent();
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

class LocationInitialState extends LocationState {
  const LocationInitialState();
}

class LocationLoadingState extends LocationState {
  const LocationLoadingState();
}

class LocationLoadedState extends LocationState {
  final DevicePosition position;
  final ServiceAddress address;

  const LocationLoadedState({required this.position, required this.address});

  @override
  List<Object?> get props => [position, address];
}

class LocationErrorState extends LocationState {
  final String message;
  final bool permanentlyDenied;

  const LocationErrorState({
    required this.message,
    this.permanentlyDenied = false,
  });

  @override
  List<Object?> get props => [message, permanentlyDenied];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetCurrentLocationUseCase _getCurrentLocation;
  final ReverseGeocodeUseCase _reverseGeocode;

  LocationBloc({
    required GetCurrentLocationUseCase getCurrentLocation,
    required ReverseGeocodeUseCase reverseGeocode,
  })  : _getCurrentLocation = getCurrentLocation,
        _reverseGeocode = reverseGeocode,
        super(const LocationInitialState()) {
    on<LocationFetchEvent>(_onFetch);
  }

  Future<void> _onFetch(
    LocationFetchEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoadingState());

    final positionResult = await _getCurrentLocation();

    await positionResult.fold(
      (failure) async {
        emit(LocationErrorState(
          message: failure.message,
          permanentlyDenied: failure is PermissionFailure && failure.permanentlyDenied,
        ));
      },
      (position) async {
        final addressResult = await _reverseGeocode(position);
        addressResult.fold(
          (failure) => emit(LocationErrorState(message: failure.message)),
          (address) => emit(LocationLoadedState(position: position, address: address)),
        );
      },
    );
  }
}
