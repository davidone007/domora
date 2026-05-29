import '../../domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    super.isRead,
    required super.createdAt,
    super.relatedServiceId,
    super.relatedQuoteId,
    super.relatedBookingId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      relatedServiceId: json['related_service_id'],
      relatedQuoteId: json['related_quote_id'],
      relatedBookingId: json['related_booking_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'related_service_id': relatedServiceId,
      'related_quote_id': relatedQuoteId,
      'related_booking_id': relatedBookingId,
    };
  }
}
