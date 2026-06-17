import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.shortDescription,
    required this.price,
    required this.rating,
    this.isPopular = false,
  });

  final String id;
  final String name;
  final String categoryId;
  final String shortDescription;
  final double price;
  final double rating;
  final bool isPopular;

  @override
  List<Object?> get props => [
        id,
        name,
        categoryId,
        shortDescription,
        price,
        rating,
        isPopular,
      ];
}
