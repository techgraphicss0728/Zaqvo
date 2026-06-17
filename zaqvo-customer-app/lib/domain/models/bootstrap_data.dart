import 'package:equatable/equatable.dart';
import 'package:zaqvo_customer_app/domain/models/category.dart';
import 'package:zaqvo_customer_app/domain/models/customer_order.dart';
import 'package:zaqvo_customer_app/domain/models/product.dart';
import 'package:zaqvo_customer_app/domain/models/promo_banner.dart';

class BootstrapData extends Equatable {
  const BootstrapData({
    required this.categories,
    required this.products,
    required this.orders,
    required this.banners,
  });

  final List<Category> categories;
  final List<Product> products;
  final List<CustomerOrder> orders;
  final List<PromoBanner> banners;

  @override
  List<Object?> get props => [categories, products, orders, banners];
}
