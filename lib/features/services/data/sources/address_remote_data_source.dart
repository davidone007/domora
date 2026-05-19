import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:domora/core/network/network_info.dart';

abstract class AddressRemoteDataSource {
  /// Devuelve las features crudas de Geoapify. El mapeo a modelos
  /// es responsabilidad del [AddressRepositoryImpl].
  Future<List<Map<String, dynamic>>> autocomplete(String query);

  /// Devuelve el JSON crudo de Geoapify reverse-geocode.
  /// El mapeo a [ServiceAddress] es responsabilidad del RepositoryImpl.
  Future<Map<String, dynamic>> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  static const String _baseUrl = 'https://api.geoapify.com/v1/geocode';
  final NetworkInfo _networkInfo;

  AddressRemoteDataSourceImpl({required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  String get _apiKey {
    final key = dotenv.env['GEOAPIFY_API_KEY'];
    if (key == null || key.isEmpty) {
      throw const FormatException('Geoapify API key missing');
    }
    return key;
  }

  @override
  Future<List<Map<String, dynamic>>> autocomplete(String query) async {
    if (!await _networkInfo.isConnected()) {
      throw const HttpException('No hay conexión a internet');
    }

    final uri = Uri.parse('$_baseUrl/autocomplete').replace(
      queryParameters: {
        'text': query,
        'apiKey': _apiKey,
        'lang': 'es',
        'limit': '5',
      },
    );

    final client = http.Client();
    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Geoapify autocomplete error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = (data['features'] as List?) ?? [];
      return features.cast<Map<String, dynamic>>();
    } finally {
      client.close();
    }
  }

  @override
  Future<Map<String, dynamic>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const HttpException('No hay conexión a internet');
    }

    final uri = Uri.parse('$_baseUrl/reverse').replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'apiKey': _apiKey,
        'lang': 'es',
      },
    );

    final client = http.Client();
    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Geoapify reverse error: ${response.statusCode}');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

}
