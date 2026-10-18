import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/data/models/checkout_order_model.dart';

void main() {
  group('CheckoutOrderModel and CheckoutOrderItemModel', () {
    final testJson = {
      'id': 209,
      'products': [
        {
          'id': 1,
          'title': 'Essence Mascara Lash Princess',
          'price': 9.99,
          'quantity': 2,
          'total': 19.98,
          'discountPercentage': 10.48,
          'discountedPrice': 17.88,
          'thumbnail': 'https://example.com/mascara.jpg',
        },
      ],
      'total': 19.98,
      'discountedTotal': 17.88,
      'userId': 5,
      'totalProducts': 1,
      'totalQuantity': 2,
    };

    test('correctly parses order response from DummyJSON', () {
      final order = CheckoutOrderModel.fromJson(testJson);

      expect(order.id, 209);
      expect(order.userId, 5);
      expect(order.total, 19.98);
      expect(order.discountedTotal, 17.88);
      expect(order.totalProducts, 1);
      expect(order.totalQuantity, 2);
      expect(order.products.length, 1);

      final item = order.products.first;
      expect(item.id, 1);
      expect(item.title, 'Essence Mascara Lash Princess');
      expect(item.price, 9.99);
      expect(item.quantity, 2);
      expect(item.total, 19.98);
      expect(item.discountPercentage, 10.48);
      expect(item.discountedTotal, 17.88);
      expect(item.thumbnail, 'https://example.com/mascara.jpg');

      expect(order.formattedTotal, '\$19.98');
      expect(order.formattedDiscountedTotal, '\$17.88');
      expect(order.formattedDiscount, '\$2.10');
    });

    test('toJson serializes correctly', () {
      final order = CheckoutOrderModel.fromJson(testJson);
      final json = order.toJson();

      expect(json['id'], 209);
      expect(json['userId'], 5);
      expect(json['total'], 19.98);
      expect(json['discountedTotal'], 17.88);
      expect(json['totalProducts'], 1);
      expect(json['totalQuantity'], 2);
      expect((json['products'] as List).length, 1);
    });

    test('handles empty products and zero numbers safely', () {
      final minimalJson = {'id': 100, 'userId': 2, 'products': const []};

      final order = CheckoutOrderModel.fromJson(minimalJson);

      expect(order.id, 100);
      expect(order.userId, 2);
      expect(order.products, isEmpty);
      expect(order.total, 0.0);
      expect(order.discountedTotal, 0.0);
      expect(order.totalProducts, 0);
      expect(order.totalQuantity, 0);
    });
  });
}
