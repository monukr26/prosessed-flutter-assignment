import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/models/review_model.dart';

void main() {
  group('Product details JSON parsing with reviews', () {
    const detailsJson = {
      'id': 1,
      'title': 'iPhone 15 Pro',
      'description': 'Titanium design with A17 Pro chip',
      'category': 'smartphones',
      'price': 999.0,
      'discountPercentage': 12.5,
      'rating': 4.85,
      'stock': 15,
      'brand': 'Apple',
      'thumbnail': 'https://cdn.dummyjson.com/phone/thumbnail.png',
      'images': [
        'https://cdn.dummyjson.com/phone/1.png',
        'https://cdn.dummyjson.com/phone/2.png',
      ],
      'reviews': [
        {
          'rating': 5,
          'comment': 'Awesome phone and camera!',
          'date': '2024-05-23T08:56:21.618Z',
          'reviewerName': 'Alex Rivera',
          'reviewerEmail': 'alex.rivera@x.dummyjson.com',
        },
        {
          'rating': 4,
          'comment': 'Battery life is great.',
          'date': '2024-06-01T12:00:00.000Z',
          'reviewerName': 'Sam Smith',
        },
      ],
    };

    test('correctly parses product details including customer reviews', () {
      final product = ProductModel.fromJson(detailsJson);

      expect(product.id, equals(1));
      expect(product.title, equals('iPhone 15 Pro'));
      expect(product.brand, equals('Apple'));
      expect(product.stock, equals(15));
      expect(product.isInStock, isTrue);
      expect(product.images.length, equals(2));
      expect(product.reviews.length, equals(2));

      final firstReview = product.reviews.first;
      expect(firstReview.rating, equals(5.0));
      expect(firstReview.comment, equals('Awesome phone and camera!'));
      expect(firstReview.reviewerName, equals('Alex Rivera'));
      expect(firstReview.date, isNotNull);
      expect(firstReview.date?.year, equals(2024));
    });

    test(
      'ReviewModel handles missing optional reviewerEmail and invalid date',
      () {
        const reviewJson = {
          'rating': 3,
          'comment': 'Average product',
          'reviewerName': null,
          'date': 'invalid-date',
        };

        final review = ReviewModel.fromJson(reviewJson);

        expect(review.rating, equals(3.0));
        expect(review.comment, equals('Average product'));
        expect(review.reviewerName, equals('Verified Buyer'));
        expect(review.date, isNull);
        expect(review.reviewerEmail, isNull);
      },
    );

    test('handles absent reviews list with empty fallback', () {
      const noReviewsJson = {
        'id': 99,
        'title': 'New Item',
        'description': 'No reviews yet',
        'category': 'general',
        'price': 20.0,
        'discountPercentage': 0,
        'rating': 0.0,
        'stock': 0,
        'brand': null,
        'thumbnail': '',
      };

      final product = ProductModel.fromJson(noReviewsJson);

      expect(product.id, equals(99));
      expect(product.brand, isNull);
      expect(product.reviews, isEmpty);
      expect(product.isInStock, isFalse);
    });
  });
}
