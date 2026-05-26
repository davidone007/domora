import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:domora/core/utils/constants.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<void> sendReview(ReviewModel review);
  Future<ReviewModel?> getReviewByBookingId(String bookingId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  ReviewRemoteDataSourceImpl(this._client, {required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  @override
  Future<void> sendReview(ReviewModel review) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    await _client.from(AppConstants.tableReviews).insert(review.toJson());
  }

  @override
  Future<ReviewModel?> getReviewByBookingId(String bookingId) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    final response = await _client
        .from(AppConstants.tableReviews)
        .select()
        .eq('booking_id', bookingId)
        .maybeSingle();

    if (response == null) return null;
    return ReviewModel.fromJson(response);
  }
}
