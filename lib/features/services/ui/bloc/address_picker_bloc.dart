import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/address_suggestion.dart';
import '../../domain/entities/geo_coordinates.dart';
import '../../domain/entities/service_address.dart';
import '../../domain/usecases/autocomplete_address_usecase.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/reverse_geocode_usecase.dart';

// --- EVENTS ---
abstract class AddressPickerEvent extends Equatable {
  const AddressPickerEvent();

  @override
  List<Object?> get props => [];
}

class AddressPickerLoadCurrentLocationEvent extends AddressPickerEvent {
  const AddressPickerLoadCurrentLocationEvent();
}

class AddressPickerQueryChangedEvent extends AddressPickerEvent {
  final String query;

  const AddressPickerQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddressPickerSelectSuggestionEvent extends AddressPickerEvent {
  final AddressSuggestion suggestion;

  const AddressPickerSelectSuggestionEvent(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class AddressPickerSelectPositionEvent extends AddressPickerEvent {
  final GeoCoordinates position;

  const AddressPickerSelectPositionEvent(this.position);

  @override
  List<Object?> get props => [position];
}

// --- STATE ---
enum AddressPickerStatus { idle, loadingLocation, loadingSuggestions, resolvingAddress }

class AddressPickerState extends Equatable {
  final AddressPickerStatus status;
  final GeoCoordinates? position;
  final List<AddressSuggestion> suggestions;
  final ServiceAddress? resolvedAddress;
  final String query;
  final Failure? failure;

  const AddressPickerState({
    this.status = AddressPickerStatus.idle,
    this.position,
    this.suggestions = const [],
    this.resolvedAddress,
    this.query = '',
    this.failure,
  });

  AddressPickerState copyWith({
    AddressPickerStatus? status,
    GeoCoordinates? position,
    List<AddressSuggestion>? suggestions,
    ServiceAddress? resolvedAddress,
    String? query,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return AddressPickerState(
      status: status ?? this.status,
      position: position ?? this.position,
      suggestions: suggestions ?? this.suggestions,
      resolvedAddress: resolvedAddress ?? this.resolvedAddress,
      query: query ?? this.query,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, position, suggestions, resolvedAddress, query, failure];
}

// --- BLOC ---
class AddressPickerBloc extends Bloc<AddressPickerEvent, AddressPickerState> {
  final GetCurrentLocationUseCase _getCurrentLocation;
  final AutocompleteAddressUseCase _autocomplete;
  final ReverseGeocodeUseCase _reverseGeocode;

  AddressPickerBloc({
    required GetCurrentLocationUseCase getCurrentLocation,
    required AutocompleteAddressUseCase autocomplete,
    required ReverseGeocodeUseCase reverseGeocode,
  })  : _getCurrentLocation = getCurrentLocation,
        _autocomplete = autocomplete,
        _reverseGeocode = reverseGeocode,
        super(const AddressPickerState()) {
    on<AddressPickerLoadCurrentLocationEvent>(_onLoadCurrentLocation);
    on<AddressPickerQueryChangedEvent>(_onQueryChanged);
    on<AddressPickerSelectSuggestionEvent>(_onSelectSuggestion);
    on<AddressPickerSelectPositionEvent>(_onSelectPosition);
  }

  Future<void> _onLoadCurrentLocation(
    AddressPickerLoadCurrentLocationEvent event,
    Emitter<AddressPickerState> emit,
  ) async {
    emit(state.copyWith(status: AddressPickerStatus.loadingLocation, clearFailure: true));

    final result = await _getCurrentLocation.call();
    await result.fold(
      (failure) {
        emit(state.copyWith(
          status: AddressPickerStatus.idle,
          failure: failure,
        ));
      },
      (coords) async {
        emit(state.copyWith(
          status: AddressPickerStatus.resolvingAddress,
          position: coords,
        ));
        await _resolveAddress(coords, emit);
      },
    );
  }

  Future<void> _onQueryChanged(
    AddressPickerQueryChangedEvent event,
    Emitter<AddressPickerState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(query: query, clearFailure: true));

    if (query.length < 3) {
      emit(state.copyWith(suggestions: const [], status: AddressPickerStatus.idle));
      return;
    }

    emit(state.copyWith(status: AddressPickerStatus.loadingSuggestions));
    final result = await _autocomplete.call(query);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AddressPickerStatus.idle,
        suggestions: const [],
        failure: failure,
      )),
      (suggestions) => emit(state.copyWith(
        status: AddressPickerStatus.idle,
        suggestions: suggestions,
      )),
    );
  }

  Future<void> _onSelectSuggestion(
    AddressPickerSelectSuggestionEvent event,
    Emitter<AddressPickerState> emit,
  ) async {
    final coords = GeoCoordinates(
      latitude: event.suggestion.latitude,
      longitude: event.suggestion.longitude,
    );

    emit(state.copyWith(
      status: AddressPickerStatus.resolvingAddress,
      position: coords,
      suggestions: const [],
      query: event.suggestion.label,
      clearFailure: true,
    ));

    final fallback = _buildFallbackAddress(event.suggestion);
    await _resolveAddress(coords, emit, fallback: fallback);
  }

  Future<void> _onSelectPosition(
    AddressPickerSelectPositionEvent event,
    Emitter<AddressPickerState> emit,
  ) async {
    emit(state.copyWith(
      status: AddressPickerStatus.resolvingAddress,
      position: event.position,
      suggestions: const [],
      clearFailure: true,
    ));

    await _resolveAddress(event.position, emit);
  }

  Future<void> _resolveAddress(
    GeoCoordinates coords,
    Emitter<AddressPickerState> emit, {
    ServiceAddress? fallback,
  }) async {
    final result = await _reverseGeocode.call(coords);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AddressPickerStatus.idle,
        resolvedAddress: fallback,
        failure: failure,
      )),
      (address) => emit(state.copyWith(
        status: AddressPickerStatus.idle,
        resolvedAddress: address,
      )),
    );
  }

  ServiceAddress _buildFallbackAddress(AddressSuggestion suggestion) {
    return ServiceAddress(
      addressLine1: suggestion.addressLine1 ?? suggestion.label,
      addressLine2: suggestion.addressLine2,
      city: suggestion.city ?? '',
      neighborhood: suggestion.neighborhood,
      latitude: suggestion.latitude,
      longitude: suggestion.longitude,
    );
  }
}
