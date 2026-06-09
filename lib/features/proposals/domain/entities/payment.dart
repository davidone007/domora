import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String? id;
  final String bookingId;
  final String clientId;
  final double amount;
  final String paymentMethod; // 'cash', 'card'
  final String status; // 'completed', 'pending'
  final String? transactionId;
  final DateTime? createdAt;

  const Payment({
    this.id,
    required this.bookingId,
    required this.clientId,
    required this.amount,
    required this.paymentMethod,
    this.status = 'completed',
    this.transactionId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        clientId,
        amount,
        paymentMethod,
        status,
        transactionId,
        createdAt,
      ];
}
