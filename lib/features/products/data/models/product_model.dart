import 'package:shopsphere/features/products/data/models/review_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Data Transfer Object for [Product] entity.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    super.brand,
    required super.thumbnail,
    super.images,
    super.reviews,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['reviews'] as List<dynamic>? ?? const [];
    final reviews = rawReviews
        .whereType<Map<String, dynamic>>()
        .map(ReviewModel.fromJson)
        .toList();

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String?,
      thumbnail: json['thumbnail'] as String? ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      reviews: reviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      if (brand != null) 'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
      'reviews': reviews
          .map((r) => ReviewModel.fromEntity(r).toJson())
          .toList(),
    };
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      price: entity.price,
      discountPercentage: entity.discountPercentage,
      rating: entity.rating,
      stock: entity.stock,
      brand: entity.brand,
      thumbnail: entity.thumbnail,
      images: entity.images,
      reviews: entity.reviews,
    );
  }
}
