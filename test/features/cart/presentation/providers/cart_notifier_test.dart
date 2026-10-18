import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/save_cart_usecase.dart';
import 'package:shopsphere/features/cart/presentation/providers/cart_notifier.dart';
import 'package:shopsphere/features/cart/presentation/providers/cart_state.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockSaveCartUseCase extends Mock implements SaveCartUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late MockGetCartUseCase mockGetCartUseCase;
  late MockSaveCartUseCase mockSaveCartUseCase;
  late MockClearCartUseCase mockClearCartUseCase;

  const testProductInStock = Product(
    id: 1,
    title: 'Essence Mascara',
    description: 'Description',
    category: 'beauty',
    price: 10.0,
    discountPercentage: 10.0, // Discounted: 9.0
    rating: 4.5,
    stock: 5,
    thumbnail: 'https://example.com/mascara.jpg',
  );

  const testProductOutOfStock = Product(
    id: 2,
    title: 'Sold Out Lipstick',
    description: 'Description',
    category: 'beauty',
    price: 15.0,
    discountPercentage: 0.0,
    rating: 4.0,
    stock: 0,
    thumbnail: 'https://example.com/lipstick.jpg',
  );

  setUp(() {
    mockGetCartUseCase = MockGetCartUseCase();
    mockSaveCartUseCase = MockSaveCartUseCase();
    mockClearCartUseCase = MockClearCartUseCase();

    registerFallbackValue(<CartItem>[]);

    when(
      () => mockSaveCartUseCase(any()),
    ).thenAnswer((_) async => const Result.success(null));
    when(
      () => mockClearCartUseCase(),
    ).thenAnswer((_) async => const Result.success(null));
  });

  Future<ProviderContainer> createContainer({
    List<CartItem> initialItems = const [],
  }) async {
    when(
      () => mockGetCartUseCase(),
    ).thenAnswer((_) async => Result.success(initialItems));

    final container = ProviderContainer(
      overrides: [
        cartNotifierProvider.overrideWith(
          () => CartNotifier(
            getCartUseCase: mockGetCartUseCase,
            saveCartUseCase: mockSaveCartUseCase,
            clearCartUseCase: mockClearCartUseCase,
          ),
        ),
      ],
    );

    addTearDown(container.dispose);
    await container.read(cartNotifierProvider.notifier).loadCart();
    return container;
  }

  group('CartNotifier', () {
    test('restores cached cart on initialization', () async {
      const existingItems = [
        CartItem(product: testProductInStock, quantity: 2),
      ];

      final container = await createContainer(initialItems: existingItems);

      final state = container.read(cartNotifierProvider);
      expect(state.status, CartStatus.loaded);
      expect(state.items.length, 1);
      expect(state.totalQuantity, 2);
      expect(state.totals.subtotal, 20.0);
      expect(state.totals.grandTotal, 18.0);
    });

    test('adding in-stock product appends item and persists', () async {
      final container = await createContainer();

      final notifier = container.read(cartNotifierProvider.notifier);
      final added = await notifier.addToCart(testProductInStock, quantity: 2);

      expect(added, true);
      final state = container.read(cartNotifierProvider);
      expect(state.items.length, 1);
      expect(state.items.first.quantity, 2);
      expect(state.totalQuantity, 2);
      verify(() => mockSaveCartUseCase(any())).called(1);
    });

    test('prevents adding out of stock product (stock <= 0)', () async {
      final container = await createContainer();

      final notifier = container.read(cartNotifierProvider.notifier);
      final added = await notifier.addToCart(
        testProductOutOfStock,
        quantity: 1,
      );

      expect(added, false);
      final state = container.read(cartNotifierProvider);
      expect(state.isEmpty, true);
      verifyNever(() => mockSaveCartUseCase(any()));
    });

    test(
      'merges duplicate entries for the same product instead of adding new line',
      () async {
        final container = await createContainer();

        final notifier = container.read(cartNotifierProvider.notifier);
        await notifier.addToCart(testProductInStock, quantity: 2);
        await notifier.addToCart(testProductInStock, quantity: 2);

        final state = container.read(cartNotifierProvider);
        expect(state.items.length, 1); // Only 1 distinct product entry
        expect(state.items.first.quantity, 4); // Merged: 2 + 2 = 4
        expect(state.totalQuantity, 4);
      },
    );

    test('clamps quantity to available product stock when adding', () async {
      final container = await createContainer();

      final notifier = container.read(cartNotifierProvider.notifier);
      // testProductInStock stock is 5
      await notifier.addToCart(testProductInStock, quantity: 10);

      final state = container.read(cartNotifierProvider);
      expect(state.items.first.quantity, 5); // Clamped to 5
    });

    test('incrementQuantity increases quantity up to stock limit', () async {
      final container = await createContainer();

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.addToCart(testProductInStock, quantity: 4);

      await notifier.incrementQuantity(testProductInStock.id);
      expect(container.read(cartNotifierProvider).items.first.quantity, 5);

      // Try incrementing past max stock (5)
      await notifier.incrementQuantity(testProductInStock.id);
      expect(
        container.read(cartNotifierProvider).items.first.quantity,
        5,
      ); // Remained at 5
    });

    test(
      'decrementQuantity decreases quantity but strictly prevents dropping below 1',
      () async {
        final container = await createContainer();

        final notifier = container.read(cartNotifierProvider.notifier);
        await notifier.addToCart(testProductInStock, quantity: 2);

        await notifier.decrementQuantity(testProductInStock.id);
        expect(container.read(cartNotifierProvider).items.first.quantity, 1);

        // Decrementing at quantity 1 is ignored
        await notifier.decrementQuantity(testProductInStock.id);
        expect(container.read(cartNotifierProvider).items.first.quantity, 1);
      },
    );

    test('removeItem removes product completely and updates totals', () async {
      final container = await createContainer();

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.addToCart(testProductInStock, quantity: 2);
      expect(container.read(cartNotifierProvider).isNotEmpty, true);

      await notifier.removeItem(testProductInStock.id);

      final state = container.read(cartNotifierProvider);
      expect(state.isEmpty, true);
      expect(state.totalQuantity, 0);
      expect(state.totals.grandTotal, 0.0);
    });

    test('clearCart empties items and calls clearCartUseCase', () async {
      final container = await createContainer();

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.addToCart(testProductInStock, quantity: 3);

      await notifier.clearCart();

      final state = container.read(cartNotifierProvider);
      expect(state.isEmpty, true);
      verify(() => mockClearCartUseCase()).called(1);
    });
  });
}
