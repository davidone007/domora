import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    super.id,
    required super.bookingId,
    required super.clientId,
    required super.amount,
    required super.paymentMethod,
    super.status,
    super.transactionId,
    super.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'client_id': clientId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'transaction_id': transactionId,
    };
  }

  factory PaymentModel.fromEntity(Payment entity) {
    return PaymentModel(
      bookingId: entity.bookingId,
      clientId: entity.clientId,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod,
      status: entity.status,
      transactionId: entity.transactionId,
    );
  }
}
