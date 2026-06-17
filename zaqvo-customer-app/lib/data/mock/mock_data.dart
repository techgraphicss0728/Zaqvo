import 'package:zaqvo_customer_app/domain/models/category.dart';
import 'package:zaqvo_customer_app/domain/models/customer_order.dart';
import 'package:zaqvo_customer_app/domain/models/product.dart';
import 'package:zaqvo_customer_app/domain/models/promo_banner.dart';

class MockData {
  static const categories = <Category>[
    Category(id: 'c1', title: 'Health', icon: 'health_and_safety'),
    Category(id: 'c2', title: 'Wellness', icon: 'spa'),
    Category(id: 'c3', title: 'Nutrition', icon: 'restaurant'),
    Category(id: 'c4', title: 'Diagnostics', icon: 'biotech'),
  ];

  static const products = <Product>[
    Product(
      id: 'p1',
      name: '20L Water Can',
      categoryId: 'c3',
      shortDescription: 'Premium purified drinking water delivered fresh.',
      price: 20,
      rating: 4.9,
      isPopular: true,
    ),
    Product(
      id: 'p2',
      name: '10L Water Can',
      categoryId: 'c3',
      shortDescription: 'Compact family pack with premium quality water.',
      price: 20,
      rating: 4.7,
      isPopular: true,
    ),
    Product(
      id: 'p3',
      name: '5L Water Can',
      categoryId: 'c3',
      shortDescription: 'Easy-to-carry can for everyday hydration.',
      price: 15,
      rating: 4.6,
    ),
    Product(
      id: 'p4',
      name: '2L Water Bottle Pack',
      categoryId: 'c2',
      shortDescription: 'Clean mineral-rich water bottles for travel.',
      price: 30,
      rating: 4.5,
    ),
    Product(
      id: 'p5',
      name: '1L Water Bottle Pack',
      categoryId: 'c1',
      shortDescription: 'Daily-use bottles with safe purified water.',
      price: 25,
      rating: 4.5,
    ),
  ];

  static final orders = <CustomerOrder>[
    CustomerOrder(
      id: 'o1001',
      productName: '20L Water Can',
      productId: 'p1',
      totalAmount: 20,
      placedAt: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.completed,
    ),
    CustomerOrder(
      id: 'o1002',
      productName: '10L Water Can',
      productId: 'p2',
      totalAmount: 20,
      placedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.processing,
    ),
  ];

  static const banners = <PromoBanner>[
    PromoBanner(
      id: 'b1',
      title: 'Get 20% off on diagnostics',
      subtitle: 'Use code ZAQVO20 at checkout.',
    ),
    PromoBanner(
      id: 'b2',
      title: 'Book wellness sessions',
      subtitle: 'Weekly plans from top experts.',
    ),
  ];
}
