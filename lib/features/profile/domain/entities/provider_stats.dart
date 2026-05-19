import 'package:equatable/equatable.dart';

class ProviderStats extends Equatable {
  final double averageRating;
  final int completedServicesCount;
  final int totalReviewsCount;

  const ProviderStats({
    this.averageRating = 0.0,
    this.completedServicesCount = 0,
    this.totalReviewsCount = 0,
  });

  @override
  List<Object?> get props => [averageRating, completedServicesCount, totalReviewsCount];
}
