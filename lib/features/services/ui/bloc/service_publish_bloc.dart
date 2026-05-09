import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cleaning_service_request.dart';
import '../../domain/usecases/publish_cleaning_service_usecase.dart';

// EVENTS
abstract class ServicePublishEvent extends Equatable {
  const ServicePublishEvent();
  @override
  List<Object?> get props => [];
}

class ServicePublishSubmitEvent extends ServicePublishEvent {
  final CleaningServiceRequest request;

  const ServicePublishSubmitEvent(this.request);

  @override
  List<Object?> get props => [request];
}

// STATES
abstract class ServicePublishState extends Equatable {
  const ServicePublishState();
  @override
  List<Object?> get props => [];
}

class ServicePublishInitial extends ServicePublishState {
  const ServicePublishInitial();
}

class ServicePublishLoading extends ServicePublishState {
  const ServicePublishLoading();
}

class ServicePublishSuccess extends ServicePublishState {
  const ServicePublishSuccess();
}

class ServicePublishError extends ServicePublishState {
  final String message;
  const ServicePublishError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class ServicePublishBloc extends Bloc<ServicePublishEvent, ServicePublishState> {
  final PublishCleaningServiceUseCase _publishCleaningService;

  ServicePublishBloc(this._publishCleaningService) : super(const ServicePublishInitial()) {
    on<ServicePublishSubmitEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    ServicePublishSubmitEvent event,
    Emitter<ServicePublishState> emit,
  ) async {
    emit(const ServicePublishLoading());
    final result = await _publishCleaningService(event.request);
    result.fold(
      (failure) => emit(ServicePublishError(failure.message)),
      (_) => emit(const ServicePublishSuccess()),
    );
  }
}
