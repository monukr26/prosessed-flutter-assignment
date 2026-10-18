import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

void main() {
  const testProduct = Product(
    id: 10,
    title: 'Wireless Earbuds',
    description: 'Noise cancelling earbuds',
    category: 'audio',
    price: 49.99,
    discountPercentage: 10.0,
    rating: 4.6,
    stock: 25,
    brand: 'AudioTech',
    thumbnail: 'https://example.com/earbuds.jpg',
  );

  group('CartItemModel', () {
    test('serializes to valid JSON map', () {
      const item = CartItemModel(product: testProduct, quantity: 2);

      final json = item.toJson();

      expect(json['quantity'], 2);
      expect(json['product'], isA<Map<String, dynamic>>());
      expect((json['product'] as Map<String, dynamic>)['id'], 10);
      expect(
        (json['product'] as Map<String, dynamic>)['title'],
        'Wireless Earbuds',
      );
    });

    test('deserializes accurately from JSON', () {
      final json = {
        'quantity': 3,
        'product': ProductModel.fromEntity(testProduct).toJson(),
      };

      final item = CartItemModel.fromJson(json);

      expect(item.quantity, 3);
      expect(item.product.id, 10);
      expect(item.product.title, 'Wireless Earbuds');
      expect(item.product.price, 49.99);
      expect(item.product.brand, 'AudioTech');
    });

    test(
      'safely falls back to minimum quantity 1 on missing or invalid quantity',
      () {
        final jsonZero = {
          'quantity': 0,
          'product': {'id': 10, 'title': 'Earbuds'},
        };
        final jsonMissing = {
          'product': {'id': 10, 'title': 'Earbuds'},
        };

        expect(CartItemModel.fromJson(jsonZero).quantity, 1);
        expect(CartItemModel.fromJson(jsonMissing).quantity, 1);
      },
    );

    test('safely falls back when product map is missing or invalid', () {
      final json = {'quantity': 2, 'product': null};

      final item = CartItemModel.fromJson(json);
      expect(item.quantity, 2);
      expect(item.product.id, 0);
      expect(item.product.title, '');
    });
  });
}
