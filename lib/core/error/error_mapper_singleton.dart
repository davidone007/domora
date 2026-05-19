import 'failure_mapper.dart';

/// Singleton para acceder al FailureMapper globalmente.
///
/// Debe ser inicializado en `main.dart` o desde la capa de aplicación antes
/// de usar la aplicación. Este archivo permite que los features dependan 
/// de la abstracción FailureMapper.
class ErrorMapperSingleton {
  static FailureMapper? _instance;

  /// Inicializa el singleton con la configuración especificada
  static void initialize(FailureMapper mapper) {
    _instance = mapper;
  }

  /// Obtiene la instancia del FailureMapper
  ///
  /// Lanza una excepción si no ha sido inicializado.
  static FailureMapper get instance {
    if (_instance == null) {
      throw StateError(
        'FailureMapper no ha sido inicializado. '
        'Crea la implementación concreta en la capa de aplicación e ' 
        'inicializa con ErrorMapperSingleton.initialize()',
      );
    }
    return _instance!;
  }
}
