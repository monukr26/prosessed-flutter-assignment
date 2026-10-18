import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_totals.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

void main() {
  const testProductA = Product(
    id: 1,
    title: 'Product A',
    description: 'Description A',
    category: 'beauty',
    price: 100.0,
    discountPercentage: 0.0, // No discount
    rating: 4.5,
    stock: 10,
    thumbnail: 'https://example.com/a.jpg',
  );

  const testProductB = Product(
    id: 2,
    title: 'Product B',
    description: 'Description B',
    category: 'beauty',
    price: 50.0,
    discountPercentage: 20.0, // 20% off -> unit discounted price: 40.0
    rating: 4.8,
    stock: 5,
    thumbnail: 'https://example.com/b.jpg',
  );

  group('CartTotals Domain Logic', () {
    test('empty cart produces zeroed totals and empty formatted strings', () {
      final totals = CartTotals.empty();

      expect(totals.subtotal, 0.0);
      expect(totals.totalDiscount, 0.0);
      expect(totals.grandTotal, 0.0);
      expect(totals.totalItems, 0);
      expect(totals.totalUniqueProducts, 0);
      expect(totals.formattedSubtotal, '\$0.00');
      expect(totals.formattedDiscount, '\$0.00');
      expect(totals.formattedGrandTotal, '\$0.00');
    });

    test('calculate returns zeroed totals when items list is empty', () {
      final totals = CartTotals.calculate(const []);

      expect(totals, CartTotals.empty());
    });

    test(
      'calculates correct subtotal, discount, and grand total for single item without discount',
      () {
        const item = CartItem(product: testProductA, quantity: 2);
        final totals = CartTotals.calculate([item]);

        expect(totals.subtotal, 200.0); // 100 * 2
        expect(totals.totalDiscount, 0.0);
        expect(totals.grandTotal, 200.0);
        expect(totals.totalItems, 2);
        expect(totals.totalUniqueProducts, 1);
        expect(totals.formattedSubtotal, '\$200.00');
        expect(totals.formattedDiscount, '\$0.00');
        expect(totals.formattedGrandTotal, '\$200.00');
      },
    );

    test(
      'calculates correct subtotal, discount, and grand total for discounted item',
      () {
        // Product B: price 50, discount 20% -> discounted price: 40
        const item = CartItem(product: testProductB, quantity: 3);
        final totals = CartTotals.calculate([item]);

        expect(totals.subtotal, 150.0); // 50 * 3
        expect(totals.totalDiscount, 30.0); // (50 - 40) * 3
        expect(totals.grandTotal, 120.0); // 40 * 3
        expect(totals.totalItems, 3);
        expect(totals.totalUniqueProducts, 1);
        expect(totals.formattedSubtotal, '\$150.00');
        expect(totals.formattedDiscount, '\$30.00');
        expect(totals.formattedGrandTotal, '\$120.00');
      },
    );

    test(
      'calculates aggregated totals across multiple mixed items without double discounting',
      () {
        // Item A: 2x 100 = 200 subtotal, 0 discount, 200 grand
        // Item B: 3x 50 = 150 subtotal, 30 discount, 120 grand
        const items = [
          CartItem(product: testProductA, quantity: 2),
          CartItem(product: testProductB, quantity: 3),
        ];

        final totals = CartTotals.calculate(items);

        expect(totals.subtotal, 350.0);
        expect(totals.totalDiscount, 30.0);
        expect(totals.grandTotal, 320.0);
        expect(totals.totalItems, 5);
        expect(totals.totalUniqueProducts, 2);
        expect(totals.formattedSubtotal, '\$350.00');
        expect(totals.formattedDiscount, '\$30.00');
        expect(totals.formattedGrandTotal, '\$320.00');
      },
    );
  });
}
