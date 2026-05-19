import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:domora/core/network/network_info.dart';
import '../models/address_suggestion_model.dart';
import '../../domain/entities/service_address.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressSuggestionModel>> autocomplete(String query);

  Future<ServiceAddress> reverseGeocode({
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
  Future<List<AddressSuggestionModel>> autocomplete(String query) async {
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

      return features
          .map((item) => AddressSuggestionModel.fromGeoapifyJson(item as Map<String, dynamic>))
          .toList();
    } finally {
      client.close();
    }
  }

  @override
  Future<ServiceAddress> reverseGeocode({
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = (data['features'] as List?) ?? [];
      if (features.isEmpty) {
        return const ServiceAddress(addressLine1: '', city: '');
      }

      final properties = (features.first as Map<String, dynamic>)['properties']
              as Map<String, dynamic>? ??
          {};

      final addressLine1 = _readAddressLine1(properties);
      final city = _readCity(properties);

      return ServiceAddress(
        addressLine1: addressLine1,
        addressLine2: properties['address_line2']?.toString(),
        city: city,
        neighborhood: _readNeighborhood(properties),
        latitude: (properties['lat'] as num?)?.toDouble(),
        longitude: (properties['lon'] as num?)?.toDouble(),
      );
    } finally {
      client.close();
    }
  }

  String _readAddressLine1(Map<String, dynamic> properties) {
    return properties['address_line1']?.toString() ??
        properties['street']?.toString() ??
        properties['formatted']?.toString() ??
        '';
  }

  String _readCity(Map<String, dynamic> properties) {
    return properties['city']?.toString() ??
        properties['town']?.toString() ??
        properties['village']?.toString() ??
        properties['county']?.toString() ??
        '';
  }

  String? _readNeighborhood(Map<String, dynamic> properties) {
    return properties['neighbourhood']?.toString() ??
        properties['neighborhood']?.toString() ??
        properties['suburb']?.toString() ??
        properties['district']?.toString() ??
        properties['quarter']?.toString();
  }
}
