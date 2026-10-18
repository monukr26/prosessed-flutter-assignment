import 'package:equatable/equatable.dart';

/// Domain entity representing a product in the catalogue.
///
/// Pure Dart model without any framework or HTTP dependencies.
class Product extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    required this.thumbnail,
    this.images = const [],
  });

  /// Calculates the discounted price if discountPercentage > 0.
  double get discountedPrice {
    if (discountPercentage <= 0) return price;
    return price * (1 - (discountPercentage / 100));
  }

  /// Whether the product is currently in stock.
  bool get isInStock => stock > 0;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    price,
    discountPercentage,
    rating,
    stock,
    brand,
    thumbnail,
    images,
  ];
}
