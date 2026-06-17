import 'package:equatable/equatable.dart';

class ScheduledDelivery extends Equatable {
  const ScheduledDelivery({
    required this.id,
    required this.productId,
    required this.scheduledDate,
    required this.timeSlotLabel,
    required this.quantity,
  });

  final String id;
  final String productId;
  final DateTime scheduledDate;
  final String timeSlotLabel;
  final int quantity;

  @override
  List<Object?> get props => [
        id,
        productId,
        scheduledDate,
        timeSlotLabel,
        quantity,
      ];
}
