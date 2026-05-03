/// Contexto adicional para logging de errores.
/// 
/// Proporciona información sobre la operación que falló, parámetros
/// (sin datos sensibles) y timestamp para debugging.
class ErrorContext {
  /// Nombre de la operación que falló (ej: "login", "fetchProfile")
  final String operation;
  
  /// Parámetros de la operación (sin datos sensibles como contraseñas)
  final Map<String, dynamic>? parameters;
  
  /// ID del usuario (opcional, para correlacionar errores)
  final String? userId;
  
  /// Timestamp de cuando ocurrió el error
  final DateTime timestamp;

  ErrorContext({
    required this.operation,
    this.parameters,
    this.userId,
  }) : timestamp = DateTime.now();

  /// Convierte el contexto a JSON para logging
  Map<String, dynamic> toJson() => {
        'operation': operation,
        'parameters': parameters,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() {
    return 'ErrorContext(operation: $operation, userId: $userId, timestamp: ${timestamp.toIso8601String()})';
  }
}
