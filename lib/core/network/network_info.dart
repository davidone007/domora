/// Contrato para chequeo rápido de conectividad de red.
/// Implementaciones concretas residen en `infrastructure`.
abstract class NetworkInfo {
  /// Retorna `true` si hay conectividad de red en un chequeo rápido.
  Future<bool> isConnected({Duration timeout = const Duration(milliseconds: 1500)});
}
