import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'error_config.dart';
import 'error_logger.dart';
import 'failures.dart';

/// Mapea excepciones técnicas a objetos Failure con mensajes amigables.
/// 
/// Este es el componente central del sistema de manejo de errores.
/// Traduce excepciones de Supabase, red, validación y otras fuentes
/// a mensajes comprensibles para el usuario final.
class ErrorMapper {
  final ErrorLogger _logger;
  final ErrorConfig _config;

  const ErrorMapper({
    required ErrorLogger logger,
    required ErrorConfig config,
  })  : _logger = logger,
        _config = config;

  /// Mapea cualquier excepción a un Failure apropiado
  /// 
  /// Este es el método principal que debe usarse en los repositories.
  /// Maneja defensivamente sus propios errores para no afectar la UX.
  Failure mapException(
    Object exception, {
    StackTrace? stackTrace,
    String? context,
  }) {
    // Log el error con detalles técnicos
    try {
      _logger.logError(exception, stackTrace, context);
    } catch (e) {
      // Logging failure no debe afectar el mapeo
      // ignore: avoid_print
      print('ErrorLogger failed: $e');
    }

    try {
      // Mapeo específico por tipo
      return _mapExceptionInternal(exception);
    } catch (e) {
      // Si el mapeo falla, retornar UnknownFailure
      return UnknownFailure(_config.genericErrorMessage);
    }
  }

  /// Lógica interna de mapeo de excepciones
  Failure _mapExceptionInternal(Object exception) {
    // Primero verificar si es un error de red (más común)
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

    // Verificar si el mensaje de la excepción contiene indicadores de problemas de red
    final exceptionString = exception.toString().toLowerCase();
    if (exceptionString.contains('clientexception') ||
        exceptionString.contains('socketexception') ||
        exceptionString.contains('failed host lookup') ||
        exceptionString.contains('no address associated') ||
        exceptionString.contains('network is unreachable') ||
        exceptionString.contains('connection refused') ||
        exceptionString.contains('connection timed out') ||
        exceptionString.contains('timeout')) {
      return const NetworkFailure(
        'No hay conexión a internet. Verifica tu red e intenta nuevamente',
        type: NetworkErrorType.noConnection,
      );
    }

    // Fallback: UnknownFailure con mensaje genérico
    return UnknownFailure(_config.genericErrorMessage);
  }

  /// Mapea específicamente AuthException de Supabase
  AuthFailure mapAuthException(AuthException exception) {
    final message = exception.message.toLowerCase();

    // Verificar si AuthException contiene un error de red
    if (message.contains('clientexception') ||
        message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('no address associated') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return const AuthFailure(
        'No hay conexión a internet. Verifica tu red e intenta nuevamente',
      );
    }

    if (message.contains('invalid login credentials')) {
      return const AuthFailure('Correo o contraseña incorrectos');
    }

    if (message.contains('user already registered') ||
        message.contains('already been registered')) {
      return const AuthFailure(
          'Este correo ya está registrado. Intenta iniciar sesión');
    }

    if (message.contains('email not confirmed')) {
      return const AuthFailure(
        'Debes confirmar tu correo antes de iniciar sesión. '
        'Revisa tu bandeja de entrada',
      );
    }

    if (message.contains('password should be')) {
      return const AuthFailure(
        'La contraseña debe tener al menos 8 caracteres, '
        'una letra y un número',
      );
    }

    if (message.contains('session') && message.contains('expired')) {
      return const AuthFailure('Tu sesión ha expirado. Inicia sesión nuevamente');
    }

    // Fallback: mensaje genérico en lugar del mensaje técnico
    return const AuthFailure(
      'Ocurrió un error al autenticar. Intenta nuevamente',
    );
  }

  /// Mapea específicamente PostgrestException de Supabase
  ServerFailure mapPostgrestException(PostgrestException exception) {
    final code = exception.code;
    final message = exception.message.toLowerCase();

    // Verificar si PostgrestException contiene un error de red
    if (message.contains('clientexception') ||
        message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('no address associated') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return const ServerFailure(
        'No hay conexión a internet. Verifica tu red e intenta nuevamente',
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

    // Fallback: mensaje genérico en lugar del mensaje técnico
    return const ServerFailure(
      'Ocurrió un error en el servidor. Intenta más tarde',
    );
  }

  /// Mapea errores de red (timeouts, conexión)
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
      // ClientException puede contener otras excepciones dentro
      // Revisar el mensaje para determinar el tipo específico
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
      
      // Fallback genérico para ClientException
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

  /// Mapea errores de validación
  ValidationFailure mapValidationException(Object exception) {
    if (exception is FormatException) {
      return ValidationFailure(
        exception.message,
      );
    }

    return const ValidationFailure('Datos inválidos');
  }

  /// Mapea errores de permisos
  PermissionFailure mapPermissionException(
    PermissionType permissionType, {
    bool permanentlyDenied = false,
  }) {
    String message;

    switch (permissionType) {
      case PermissionType.camera:
        message =
            'Necesitamos acceso a tu cámara para tomar fotos. Ve a Configuración para otorgar el permiso';
        break;
      case PermissionType.photos:
        message =
            'Necesitamos acceso a tus fotos para seleccionar imágenes. Ve a Configuración para otorgar el permiso';
        break;
      case PermissionType.location:
        message =
            'Necesitamos acceso a tu ubicación para mostrarte servicios cercanos. Ve a Configuración para otorgar el permiso';
        break;
      case PermissionType.storage:
        message =
            'Necesitamos acceso al almacenamiento para guardar archivos. Ve a Configuración para otorgar el permiso';
        break;
      case PermissionType.microphone:
        message =
            'Necesitamos acceso al micrófono para grabar audio. Ve a Configuración para otorgar el permiso';
        break;
    }

    return PermissionFailure(
      message: message,
      permissionType: permissionType,
      permanentlyDenied: permanentlyDenied,
    );
  }
}
