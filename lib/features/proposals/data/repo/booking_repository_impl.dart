import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/services/data/models/service_model.dart';
import '../../domain/entities/booking_with_service.dart';
import '../../domain/repo/booking_repository.dart';
import '../models/booking_model.dart';
import '../sources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;
  final FailureMapper _errorMapper;

  BookingRepositoryImpl(this._remoteDataSource, this._errorMapper);

  @override
  Future<Either<Failure, List<BookingWithService>>> getClientBookingHistory(String clientId) async {
    try {
      final results = await _remoteDataSource.getBookings(
        userId: clientId,
        isProvider: false,
        statuses: ['completed'],
      );
      return Right(_mapResults(results, isProvider: false));
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'getClientBookingHistory', userId: clientId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<BookingWithService>>> getProviderActiveBookings(String providerId) async {
    try {
      final results = await _remoteDataSource.getBookings(
        userId: providerId,
        isProvider: true,
        statuses: ['pending', 'confirmed'],
      );
      return Right(_mapResults(results, isProvider: true));
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'getProviderActiveBookings', userId: providerId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeBooking({
    required String bookingId,
    required String serviceId,
  }) async {
    try {
      await _remoteDataSource.completeBooking(bookingId: bookingId, serviceId: serviceId);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'completeBooking', userId: bookingId).toString(),
      ));
    }
  }

  List<BookingWithService> _mapResults(List<Map<String, dynamic>> results, {required bool isProvider}) {
    return results.map((json) {
      final booking = BookingModel.fromJson(json);
      final service = ServiceModel.fromJson(json['services']);
      
      // Intentamos obtener los datos del usuario de varias llaves posibles según el join
      final userData = json[isProvider ? 'users' : 'users'] ?? 
                      json['users!client_id'] ?? 
                      json['users!provider_id'] ??
                      json['users!bookings_client_id_fkey'] ??
                      json['users!bookings_provider_id_fkey'];

      if (userData == null) {
        throw Exception('No se pudieron encontrar los datos de la contraparte en la reserva');
      }

      final String name = '${userData['first_name']} ${userData['last_name']}';
      
      // El avatar puede estar en client_profiles o provider_profiles
      final clientProfile = userData['client_profiles'];
      final providerProfile = userData['provider_profiles'];
      
      String? avatarUrl;
      if (clientProfile is Map && clientProfile['avatar_url'] != null) {
        avatarUrl = clientProfile['avatar_url'];
      } else if (providerProfile is Map && providerProfile['avatar_url'] != null) {
        avatarUrl = providerProfile['avatar_url'];
      } else if (clientProfile is List && clientProfile.isNotEmpty) {
        avatarUrl = clientProfile[0]['avatar_url'];
      } else if (providerProfile is List && providerProfile.isNotEmpty) {
        avatarUrl = providerProfile[0]['avatar_url'];
      }

      return BookingWithService(
        booking: booking,
        service: service,
        otherPartyName: name,
        otherPartyAvatarUrl: avatarUrl,
      );
    }).toList();
  }
}
