import 'package:domora/core/entities/avatar_file.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
import '../../domain/entities/cleaning_service_request.dart';
import '../../domain/entities/cleaning_service_detail.dart';
import '../../domain/entities/service_address.dart';
import '../../domain/usecases/publish_cleaning_service_usecase.dart';

// --- EVENTS ---
abstract class ServicePublishEvent extends Equatable {
  const ServicePublishEvent();
  @override
  List<Object?> get props => [];
}

class ServicePublishUpdateDraftEvent extends ServicePublishEvent {
  final String? title;
  final String? description;
  final DateTime? preferredDate;
  final String? preferredTimeStart;
  final ServiceAddress? address;
  final CleaningServiceDetail? details;

  const ServicePublishUpdateDraftEvent({
    this.title,
    this.description,
    this.preferredDate,
    this.preferredTimeStart,
    this.address,
    this.details,
  });

  @override
  List<Object?> get props => [title, description, preferredDate, preferredTimeStart, address, details];
}

class ServicePublishAddImageEvent extends ServicePublishEvent {
  final AvatarFile image;
  const ServicePublishAddImageEvent(this.image);
  @override
  List<Object?> get props => [image];
}

class ServicePublishRemoveImageEvent extends ServicePublishEvent {
  final int index;
  const ServicePublishRemoveImageEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class ServicePublishSetPrimaryImageEvent extends ServicePublishEvent {
  final int index;
  const ServicePublishSetPrimaryImageEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class ServicePublishNextStepEvent extends ServicePublishEvent {
  const ServicePublishNextStepEvent();
}

class ServicePublishPrevStepEvent extends ServicePublishEvent {
  const ServicePublishPrevStepEvent();
}

class ServicePublishSubmitEvent extends ServicePublishEvent {
  const ServicePublishSubmitEvent();
}

// --- STATE ---
enum ServicePublishStatus { initial, loading, success, error }

class ServicePublishState extends Equatable {
  final int currentStep; // 0 to 4 (Step 1 to 5)
  final ServicePublishStatus status;
  final String? errorMessage;
  
  // Borrador de la solicitud
  final String title;
  final String? description;
  final DateTime preferredDate;
  final String preferredTimeStart;
  final ServiceAddress address;
  final CleaningServiceDetail details;
  
  // Imágenes (HU8)
  final List<AvatarFile> images;
  final int primaryImageIndex;

  const ServicePublishState({
    this.currentStep = 0,
    this.status = ServicePublishStatus.initial,
    this.errorMessage,
    this.title = '',
    this.description,
    required this.preferredDate,
    this.preferredTimeStart = '08:00:00',
    required this.address,
    required this.details,
    this.images = const [],
    this.primaryImageIndex = 0,
  });

  factory ServicePublishState.initial() {
    return ServicePublishState(
      preferredDate: DateTime.now().add(const Duration(days: 1)),
      address: const ServiceAddress(addressLine1: '', city: 'Cali'),
      details: const CleaningServiceDetail(),
    );
  }

  ServicePublishState copyWith({
    int? currentStep,
    ServicePublishStatus? status,
    String? errorMessage,
    String? title,
    String? description,
    DateTime? preferredDate,
    String? preferredTimeStart,
    ServiceAddress? address,
    CleaningServiceDetail? details,
    List<AvatarFile>? images,
    int? primaryImageIndex,
  }) {
    return ServicePublishState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      title: title ?? this.title,
      description: description ?? this.description,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTimeStart: preferredTimeStart ?? this.preferredTimeStart,
      address: address ?? this.address,
      details: details ?? this.details,
      images: images ?? this.images,
      primaryImageIndex: primaryImageIndex ?? this.primaryImageIndex,
    );
  }

  CleaningServiceRequest toRequest(String clientId) {
    return CleaningServiceRequest(
      clientId: clientId,
      title: title,
      description: description,
      preferredDate: preferredDate,
      preferredTimeStart: preferredTimeStart,
      address: address,
      details: details,
      images: images,
      primaryImageIndex: primaryImageIndex,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        status,
        errorMessage,
        title,
        description,
        preferredDate,
        preferredTimeStart,
        address,
        details,
        images,
        primaryImageIndex,
      ];
}

// --- BLOC ---
class ServicePublishBloc extends Bloc<ServicePublishEvent, ServicePublishState> {
  final PublishCleaningServiceUseCase _publishCleaningService;
  final GetCurrentSessionUseCase _getCurrentSession;

  ServicePublishBloc({
    required PublishCleaningServiceUseCase publishCleaningService,
    required GetCurrentSessionUseCase getCurrentSession,
  })  : _publishCleaningService = publishCleaningService,
        _getCurrentSession = getCurrentSession,
        super(ServicePublishState.initial()) {
    on<ServicePublishUpdateDraftEvent>(_onUpdateDraft);
    on<ServicePublishAddImageEvent>(_onAddImage);
    on<ServicePublishRemoveImageEvent>(_onRemoveImage);
    on<ServicePublishSetPrimaryImageEvent>(_onSetPrimaryImage);
    on<ServicePublishNextStepEvent>(_onNextStep);
    on<ServicePublishPrevStepEvent>(_onPrevStep);
    on<ServicePublishSubmitEvent>(_onSubmit);
  }

  void _onUpdateDraft(ServicePublishUpdateDraftEvent event, Emitter<ServicePublishState> emit) {
    emit(state.copyWith(
      title: event.title,
      description: event.description,
      preferredDate: event.preferredDate,
      preferredTimeStart: event.preferredTimeStart,
      address: event.address,
      details: event.details,
    ));
  }

  void _onAddImage(ServicePublishAddImageEvent event, Emitter<ServicePublishState> emit) {
    final newImages = List<AvatarFile>.from(state.images)..add(event.image);
    emit(state.copyWith(images: newImages));
  }

  void _onRemoveImage(ServicePublishRemoveImageEvent event, Emitter<ServicePublishState> emit) {
    final newImages = List<AvatarFile>.from(state.images)..removeAt(event.index);
    int newPrimaryIndex = state.primaryImageIndex;
    if (newPrimaryIndex >= newImages.length) {
      newPrimaryIndex = newImages.isEmpty ? 0 : newImages.length - 1;
    }
    emit(state.copyWith(images: newImages, primaryImageIndex: newPrimaryIndex));
  }

  void _onSetPrimaryImage(ServicePublishSetPrimaryImageEvent event, Emitter<ServicePublishState> emit) {
    emit(state.copyWith(primaryImageIndex: event.index));
  }

  void _onNextStep(ServicePublishNextStepEvent event, Emitter<ServicePublishState> emit) {
    if (state.currentStep < 4) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPrevStep(ServicePublishPrevStepEvent event, Emitter<ServicePublishState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> _onSubmit(ServicePublishSubmitEvent event, Emitter<ServicePublishState> emit) async {
    emit(state.copyWith(status: ServicePublishStatus.loading));

    // Obtener userId de la sesión
    final sessionResult = await _getCurrentSession();
    
    final userId = sessionResult.fold(
      (_) => null,
      (auth) => auth?.userId,
    );

    if (userId == null) {
      emit(state.copyWith(
        status: ServicePublishStatus.error,
        errorMessage: 'Sesión no válida o expirada',
      ));
      return;
    }
    
    final result = await _publishCleaningService(state.toRequest(userId));
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: ServicePublishStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ServicePublishStatus.success,
        currentStep: 4, // Mover a la pantalla de éxito
      )),
    );
  }
}
