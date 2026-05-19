import 'package:flutter/foundation.dart';

/// Configuración global del sistema de manejo de errores.
/// 
/// Controla el comportamiento del logging, mensajes de error y timeouts.
/// Puede configurarse para desarrollo o producción, o detectar automáticamente
/// el modo según kDebugMode.
class ErrorConfig {
  /// Habilita el logging de errores
  final bool enableLogging;
  
  /// Habilita logging verbose con stack traces completos
  final bool verboseLogging;
  
  /// Muestra detalles técnicos en mensajes de error (solo desarrollo)
  final bool showTechnicalDetails;
  
  /// Mensaje genérico para errores desconocidos
  final String genericErrorMessage;
  
  /// Timeout por defecto para operaciones de red
  final Duration defaultTimeout;
  
  /// Idioma de los mensajes de error
  final String language;

  const ErrorConfig({
    this.enableLogging = true,
    this.verboseLogging = false,
    this.showTechnicalDetails = false,
    this.genericErrorMessage = 'Ocurrió un error inesperado. Intenta nuevamente',
    this.defaultTimeout = const Duration(seconds: 30),
    this.language = 'en',
  });

  /// Configuración para desarrollo: logging verbose y detalles técnicos
  factory ErrorConfig.development() => const ErrorConfig(
        enableLogging: true,
        verboseLogging: true,
        showTechnicalDetails: true,
      );

  /// Configuración para producción: logging básico sin detalles técnicos
  factory ErrorConfig.production() => const ErrorConfig(
        enableLogging: true,
        verboseLogging: false,
        showTechnicalDetails: false,
      );

  /// Configuración automática según modo de Flutter (debug vs release)
  factory ErrorConfig.auto() {
    return kDebugMode ? ErrorConfig.development() : ErrorConfig.production();
  }
}
