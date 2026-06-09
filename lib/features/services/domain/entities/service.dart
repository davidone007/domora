import 'package:equatable/equatable.dart';

/// Entidad que representa un servicio en la lista de solicitudes.
class Service extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime? preferredDate;
  final String? preferredTimeStart;
  final int quotesCount;
  final String? bookingProviderId;
  final List<String> quoteProviderIds;

  const Service({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    this.preferredDate,
    this.preferredTimeStart,
    this.quotesCount = 0,
    this.bookingProviderId,
    this.quoteProviderIds = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        createdAt,
        preferredDate,
        preferredTimeStart,
        quotesCount,
        bookingProviderId,
        quoteProviderIds,
      ];
}
