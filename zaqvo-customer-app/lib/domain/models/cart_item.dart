import 'package:equatable/equatable.dart';
import 'package:zaqvo_customer_app/domain/models/product.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  double get lineTotal => product.price * quantity;

  @override
  List<Object?> get props => [product, quantity];
}
