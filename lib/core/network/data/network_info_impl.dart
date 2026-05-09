import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:domora/core/network/network_info.dart';

/// Implementación rápida de `NetworkInfo` que hace una petición HTTP ligera
/// al endpoint de salud del backend configurado.
///
/// Esto evita falsos negativos de un DNS público bloqueado por la red y sirve
/// tanto para mobile/desktop como para web.
class NetworkInfoImpl implements NetworkInfo {
  final Uri probeUri;

  NetworkInfoImpl({Uri? probeUri})
      : probeUri = probeUri ?? Uri.parse('https://www.gstatic.com/generate_204');

  @override
  Future<bool> isConnected({Duration timeout = const Duration(milliseconds: 1500)}) async {
    if (kIsWeb) {
      return true;
    }

    final client = http.Client();
    try {
      final response = await client.head(probeUri).timeout(timeout);
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }
}
