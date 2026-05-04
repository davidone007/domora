import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/error_config.dart';
import 'package:domora/core/error/error_logger.dart';
import 'package:domora/core/error/failures.dart';

/// Implementación concreta del mapeador de errores colocada en la capa de
/// infraestructura. Implementa el contrato `FailureMapper` definido en core.
class ErrorMapperImpl implements FailureMapper {
  final ErrorLogger _logger;
  final ErrorConfig _config;

  const ErrorMapperImpl({
    required ErrorLogger logger,
    required ErrorConfig config,
  })  : _logger = logger,
        _config = config;

  @override
  Failure mapException(
    Object exception, {
    StackTrace? stackTrace,
    String? context,
  }) {
    try {
      _logger.logError(exception, stackTrace, context);
    } catch (e) {
      // ignore: avoid_print
      print('ErrorLogger failed: $e');
    }

    try {
      return _mapExceptionInternal(exception);
    } catch (e) {
      return UnknownFailure(_config.genericErrorMessage);
    }
  }

  Failure _mapExceptionInternal(Object exception) {
    if (exception is StorageException) {
      final msg = exception.message ?? 'Error subiendo archivo. Verifica permisos de Storage.';
      return ServerFailure(
        _buildMessage(
          userMessage: 'No se pudo subir la imagen. Revisa permisos y reglas de Storage.',
          technicalMessage: msg,
        ),
      );
    }
    if (exception is ClientException ||
        exception is SocketException ||
        exception is TimeoutException ||
        exception is HttpException) {
      return mapNetworkException(exception);
    }

    if (exception is AuthException) {
      return mapAuthException(exception);
    }

    if (exception is PostgrestException) {
      return mapPostgrestException(exception);
    }

    if (exception is FormatException) {
      return mapValidationException(exception);
    }

    final exceptionString = exception.toString();
    if (_looksLikeNetworkIssue(exceptionString)) {
      return const NetworkFailure(
        'No hay conexión a internet. Verifica tu red e intenta nuevamente',
        type: NetworkErrorType.noConnection,
      );
    }

    return UnknownFailure(_config.genericErrorMessage);
  }

  Failure mapAuthException(AuthException exception) {
    final message = exception.message;

    if (_looksLikeNetworkIssue(message)) {
      return const NetworkFailure(
        'No hay conexión a internet. Verifica tu red e intenta nuevamente',
        type: NetworkErrorType.noConnection,
      );
    }

    final normalizedMessage = message.toLowerCase();

    if (normalizedMessage.contains('invalid login credentials')) {
      return const AuthFailure('Correo o contraseña incorrectos');
    }

    if (normalizedMessage.contains('user already registered') ||
        normalizedMessage.contains('already been registered')) {
      return const AuthFailure(
          'Este correo ya está registrado. Intenta iniciar sesión');
    }

    if (normalizedMessage.contains('email not confirmed')) {
      return const AuthFailure(
        'Debes confirmar tu correo antes de iniciar sesión. '
        'Revisa tu bandeja de entrada',
      );
    }

    if (normalizedMessage.contains('password should be')) {
      return const AuthFailure(
        'La contraseña debe tener al menos 8 caracteres, '
        'una letra y un número',
      );
    }

    // Mensaje común de Supabase al limitar peticiones por seguridad, p.ej:
    // "For security purposes, you can only request this after 47 seconds."
    if (normalizedMessage.contains('for security purposes') ||
        normalizedMessage.contains('you can only request this')) {
      return const AuthFailure(
        'Por motivos de seguridad, debes esperar unos segundos antes de intentar de nuevo.',
      );
    }

    if (normalizedMessage.contains('session') &&
        normalizedMessage.contains('expired')) {
      return const AuthFailure('Tu sesión ha expirado. Inicia sesión nuevamente');
    }

    return AuthFailure(
      _buildMessage(
        userMessage: 'Ocurrió un error al autenticar. Intenta nuevamente',
        technicalMessage: message,
      ),
    );
  }

  Failure mapPostgrestException(PostgrestException exception) {
    final code = exception.code;
    final message = exception.message;

    if (_looksLikeNetworkIssue(message)) {
      return const NetworkFailure(
        'No hay conexión a internet. Verifica tu red e intenta nuevamente',
        type: NetworkErrorType.noConnection,
      );
    }

    if (code == '500' || code == 'PGRST000') {
      return const ServerFailure(
        'Algo salió mal en nuestro servidor. Intenta más tarde',
        code: '500',
      );
    }

    if (code == '503') {
      return const ServerFailure(
        'El servicio está temporalmente no disponible. '
        'Intenta en unos minutos',
        code: '503',
      );
    }

    if (code == '429') {
      return const ServerFailure(
        'Has realizado demasiadas solicitudes. '
        'Espera un momento e intenta nuevamente',
        code: '429',
      );
    }

    if (code == '403') {
      return const ServerFailure(
        'No tienes permisos para realizar esta acción',
        code: '403',
      );
    }

    if (code == '404') {
      return const ServerFailure(
        'El recurso solicitado no existe',
        code: '404',
      );
    }

    return ServerFailure(
      _buildMessage(
        userMessage: 'Ocurrió un error en el servidor. Intenta más tarde',
        technicalMessage: message,
      ),
    );
  }

  NetworkFailure mapNetworkException(Object exception) {
    if (exception is TimeoutException) {
      return const NetworkFailure(
        'La operación tardó demasiado. Verifica tu conexión e intenta nuevamente',
        type: NetworkErrorType.timeout,
      );
    }

    if (exception is SocketException) {
      return const NetworkFailure(
        'No hay conexión a internet. Verifica tu red e intenta nuevamente',
        type: NetworkErrorType.noConnection,
      );
    }

    if (exception is ClientException) {
      final message = exception.toString().toLowerCase();

      if (message.contains('socketexception') ||
          message.contains('failed host lookup') ||
          message.contains('no address associated with hostname')) {
        return const NetworkFailure(
          'No hay conexión a internet. Verifica tu red e intenta nuevamente',
          type: NetworkErrorType.noConnection,
        );
      }

      if (message.contains('timeout')) {
        return const NetworkFailure(
          'La operación tardó demasiado. Verifica tu conexión e intenta nuevamente',
          type: NetworkErrorType.timeout,
        );
      }

      return const NetworkFailure(
        'No hay conexión a internet. Verifica tu red e intenta nuevamente',
        type: NetworkErrorType.noConnection,
      );
    }

    if (exception is HttpException) {
      return const NetworkFailure(
        'El servidor no está disponible. Intenta más tarde',
        type: NetworkErrorType.serverUnreachable,
      );
    }

    return const NetworkFailure(
      'Problema de conexión. Verifica tu red e intenta nuevamente',
      type: NetworkErrorType.unknown,
    );
  }

  ValidationFailure mapValidationException(Object exception) {
    if (exception is FormatException) {
      return ValidationFailure(
        exception.message,
      );
    }

    return const ValidationFailure('Datos inválidos');
  }

  PermissionFailure mapPermissionException(
    PermissionType permissionType, {
    bool permanentlyDenied = false,
  }) {
    String message;

    switch (permissionType) {
      case PermissionType.camera:
        message =
            'Necesitamos acceso a tu cámara para tomar fotos. ${_permissionActionHint(permanentlyDenied)}';
        break;
      case PermissionType.photos:
        message =
            'Necesitamos acceso a tus fotos para seleccionar imágenes. ${_permissionActionHint(permanentlyDenied)}';
        break;
      case PermissionType.location:
        message =
            'Necesitamos acceso a tu ubicación para mostrarte servicios cercanos. ${_permissionActionHint(permanentlyDenied)}';
        break;
      case PermissionType.storage:
        message =
            'Necesitamos acceso al almacenamiento para guardar archivos. ${_permissionActionHint(permanentlyDenied)}';
        break;
      case PermissionType.microphone:
        message =
            'Necesitamos acceso al micrófono para grabar audio. ${_permissionActionHint(permanentlyDenied)}';
        break;
    }

    return PermissionFailure(
      message: message,
      permissionType: permissionType,
      permanentlyDenied: permanentlyDenied,
    );
  }

  bool _looksLikeNetworkIssue(String rawMessage) {
    final message = rawMessage.toLowerCase();
    return message.contains('clientexception') ||
        message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('no address associated') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused') ||
        message.contains('connection timed out');
  }

  String _permissionActionHint(bool permanentlyDenied) {
    if (permanentlyDenied) {
      return 'Ve a Configuración para otorgar el permiso';
    }
    return 'Intenta nuevamente y acepta el permiso cuando se te solicite';
  }

  String _buildMessage({
    required String userMessage,
    required String technicalMessage,
  }) {
    if (!_config.showTechnicalDetails) {
      return userMessage;
    }

    final compactTechnical = technicalMessage.trim();
    if (compactTechnical.isEmpty) {
      return userMessage;
    }

    return '$userMessage\nDetalle técnico: $compactTechnical';
  }
}
