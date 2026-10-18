import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    const fullJson = {
      'id': 1,
      'title': 'Essence Mascara Lash Princess',
      'description': 'The Essence Mascara Lash Princess is a popular mascara.',
      'category': 'beauty',
      'price': 9.99,
      'discountPercentage': 10.0,
      'rating': 4.94,
      'stock': 5,
      'brand': 'Essence',
      'thumbnail':
          'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png',
      'images': [
        'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/1.png',
      ],
    };

    test('correctly parses full JSON response from DummyJSON', () {
      final model = ProductModel.fromJson(fullJson);

      expect(model.id, equals(1));
      expect(model.title, equals('Essence Mascara Lash Princess'));
      expect(model.category, equals('beauty'));
      expect(model.price, equals(9.99));
      expect(model.discountPercentage, equals(10.0));
      expect(model.rating, equals(4.94));
      expect(model.stock, equals(5));
      expect(model.brand, equals('Essence'));
      expect(model.thumbnail, contains('thumbnail.png'));
      expect(model.images.length, equals(1));
      expect(model.isInStock, isTrue);
      // 9.99 * 0.9 = ~8.991
      expect(model.discountedPrice, closeTo(8.991, 0.001));
    });

    test('safely handles missing nullable brand and optional fields', () {
      const minimalJson = {
        'id': 2,
        'title': 'Generic Item',
        'description': 'A product without brand',
        'category': 'groceries',
        'price': 15,
        'discountPercentage': 0,
        'rating': 3.5,
        'stock': 0,
        'brand': null,
        'thumbnail': '',
      };

      final model = ProductModel.fromJson(minimalJson);

      expect(model.id, equals(2));
      expect(model.brand, isNull);
      expect(model.images, isEmpty);
      expect(model.isInStock, isFalse);
      expect(model.discountedPrice, equals(15.0));
    });

    test('toJson serializes correctly', () {
      final model = ProductModel.fromJson(fullJson);
      final json = model.toJson();

      expect(json['id'], equals(1));
      expect(json['brand'], equals('Essence'));
      expect(json['price'], equals(9.99));
    });
  });
}
