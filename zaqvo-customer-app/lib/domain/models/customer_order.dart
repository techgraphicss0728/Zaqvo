import 'package:equatable/equatable.dart';

enum OrderStatus { placed, processing, completed, cancelled }

class CustomerOrder extends Equatable {
  const CustomerOrder({
    required this.id,
    required this.productName,
    this.productId,
    required this.totalAmount,
    required this.placedAt,
    required this.status,
  });

  final String id;
  final String productName;
  final String? productId;
  final double totalAmount;
  final DateTime placedAt;
  final OrderStatus status;

  @override
  List<Object?> get props => [
        id,
        productName,
        productId,
        totalAmount,
        placedAt,
        status,
      ];
}
