import 'package:flutter/foundation.dart';
import 'error_config.dart';

/// Logger para registrar errores con contexto y detalles técnicos.
/// 
/// El comportamiento del logger se controla mediante ErrorConfig:
/// - En desarrollo: logs verbose con stack traces completos
/// - En producción: logs básicos sin información sensible
class ErrorLogger {
  final ErrorConfig _config;

  const ErrorLogger(this._config);

  /// Registra un error con stack trace y contexto opcional
  void logError(
    Object error,
    StackTrace? stackTrace,
    String? context,
  ) {
    // Solo log si está habilitado en config
    if (!_config.enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final errorType = error.runtimeType.toString();

    // Log básico siempre
    debugPrint('[$timestamp] ERROR: $errorType');
    if (context != null) {
      debugPrint('Context: $context');
    }
    debugPrint('Message: $error');

    // Stack trace solo en modo verbose
    if (_config.verboseLogging && stackTrace != null) {
      debugPrint('Stack trace:\n$stackTrace');
    }

    // En producción, aquí se enviaría a servicio de monitoreo
    // (Sentry, Firebase Crashlytics, etc.) - fuera del alcance actual
  }

  /// Registra información de debugging
  void logDebug(String message) {
    if (!_config.enableLogging || !_config.verboseLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] DEBUG: $message');
  }

  /// Registra advertencias
  void logWarning(String message) {
    if (!_config.enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] WARNING: $message');
  }
}
