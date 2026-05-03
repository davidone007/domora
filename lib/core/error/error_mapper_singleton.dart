import 'error_config.dart';
import 'error_logger.dart';
import 'error_mapper.dart';

/// Singleton para acceder al ErrorMapper globalmente.
/// 
/// Debe ser inicializado en main.dart antes de usar la aplicación.
class ErrorMapperSingleton {
  static ErrorMapper? _instance;

  /// Inicializa el singleton con la configuración especificada
  static void initialize(ErrorMapper mapper) {
    _instance = mapper;
  }

  /// Obtiene la instancia del ErrorMapper
  /// 
  /// Lanza una excepción si no ha sido inicializado.
  static ErrorMapper get instance {
    if (_instance == null) {
      throw StateError(
        'ErrorMapper no ha sido inicializado. '
        'Llama a ErrorMapperSingleton.initialize() en main.dart',
      );
    }
    return _instance!;
  }

  /// Crea una instancia con configuración automática (dev/prod)
  static ErrorMapper createDefault() {
    final config = ErrorConfig.auto();
    final logger = ErrorLogger(config);
    return ErrorMapper(logger: logger, config: config);
  }
}
