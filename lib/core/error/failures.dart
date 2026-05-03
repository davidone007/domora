import 'package:equatable/equatable.dart';

/// Representa una falla de dominio. Se usa con `Either<Failure, T>`
/// para propagar errores de forma tipada desde la capa de datos hasta la UI.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ServerFailure extends Failure {
  final String? code;

  const ServerFailure(super.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Tipos de errores de red
enum NetworkErrorType {
  timeout,
  noConnection,
  serverUnreachable,
  unknown,
}

class NetworkFailure extends Failure {
  final NetworkErrorType type;

  const NetworkFailure(
    super.message, {
    this.type = NetworkErrorType.unknown,
  });

  @override
  List<Object?> get props => [message, type];
}

class ValidationFailure extends Failure {
  final String? fieldName;

  const ValidationFailure(super.message, {this.fieldName});

  @override
  List<Object?> get props => [message, fieldName];
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado']);
}

/// Tipos de permisos del sistema
enum PermissionType {
  camera,
  photos,
  location,
  storage,
  microphone,
}

/// Falla relacionada con permisos del sistema
class PermissionFailure extends Failure {
  final PermissionType permissionType;
  final bool permanentlyDenied;

  const PermissionFailure({
    required String message,
    required this.permissionType,
    this.permanentlyDenied = false,
  }) : super(message);

  @override
  List<Object?> get props => [message, permissionType, permanentlyDenied];
}
