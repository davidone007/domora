import 'failures.dart';

/// Contrato para mapear excepciones técnicas a [Failure].
///
/// Esta abstracción permite que los repositorios dependan de una interfaz
/// estable en lugar de una implementación concreta.
abstract class FailureMapper {
  Failure mapException(
    Object exception, {
    StackTrace? stackTrace,
    String? context,
  });
}
