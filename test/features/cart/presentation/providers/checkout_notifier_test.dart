import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_order.dart';
import 'package:shopsphere/features/cart/domain/usecases/checkout_usecase.dart';
import 'package:shopsphere/features/cart/presentation/providers/checkout_notifier.dart';
import 'package:shopsphere/features/cart/presentation/providers/checkout_state.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockCheckoutUseCase extends Mock implements CheckoutUseCase {}

void main() {
  late MockCheckoutUseCase mockCheckoutUseCase;

  const testProduct = Product(
    id: 1,
    title: 'Product 1',
    description: 'Desc',
    category: 'cat',
    price: 50.0,
    discountPercentage: 0.0,
    rating: 4.5,
    stock: 10,
    thumbnail: 'https://example.com/p1.jpg',
  );

  const testOrder = CheckoutOrder(
    id: 209,
    userId: 5,
    products: [
      CheckoutOrderItem(
        id: 1,
        title: 'Product 1',
        price: 50.0,
        quantity: 2,
        total: 100.0,
        discountPercentage: 0.0,
        discountedTotal: 100.0,
        thumbnail: 'https://example.com/p1.jpg',
      ),
    ],
    total: 100.0,
    discountedTotal: 100.0,
    totalProducts: 1,
    totalQuantity: 2,
  );

  setUp(() {
    mockCheckoutUseCase = MockCheckoutUseCase();
    registerFallbackValue(<CartItem>[]);
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        checkoutNotifierProvider.overrideWith(
          () => CheckoutNotifier(checkoutUseCase: mockCheckoutUseCase),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CheckoutNotifier', () {
    const items = [CartItem(product: testProduct, quantity: 2)];

    test('initial state is CheckoutInitial', () {
      final container = createContainer();
      expect(container.read(checkoutNotifierProvider), const CheckoutInitial());
    });

    test(
      'successful checkout invokes onOrderConfirmed and emits CheckoutSuccess',
      () async {
        when(
          () => mockCheckoutUseCase(
            userId: any(named: 'userId'),
            items: any(named: 'items'),
          ),
        ).thenAnswer((_) async => const Result.success(testOrder));

        final container = createContainer();
        final notifier = container.read(checkoutNotifierProvider.notifier);

        var cartCleared = false;
        final success = await notifier.processCheckout(
          userId: 5,
          items: items,
          onOrderConfirmed: () async {
            cartCleared = true;
          },
        );

        expect(success, true);
        expect(cartCleared, true);
        expect(
          container.read(checkoutNotifierProvider),
          const CheckoutSuccess(testOrder),
        );
      },
    );

    test(
      'failed checkout does NOT invoke onOrderConfirmed and emits CheckoutError',
      () async {
        when(
          () => mockCheckoutUseCase(
            userId: any(named: 'userId'),
            items: any(named: 'items'),
          ),
        ).thenAnswer(
          (_) async =>
              const Result.failure(NetworkFailure('No internet connection')),
        );

        final container = createContainer();
        final notifier = container.read(checkoutNotifierProvider.notifier);

        var cartCleared = false;
        final success = await notifier.processCheckout(
          userId: 5,
          items: items,
          onOrderConfirmed: () async {
            cartCleared = true;
          },
        );

        expect(success, false);
        expect(cartCleared, false); // Cart preserved!
        expect(
          container.read(checkoutNotifierProvider),
          const CheckoutError('No internet connection'),
        );
      },
    );

    test(
      'prevents duplicate concurrent checkout requests while CheckoutLoading',
      () async {
        final completer = Completer<Result<CheckoutOrder>>();
        when(
          () => mockCheckoutUseCase(
            userId: any(named: 'userId'),
            items: any(named: 'items'),
          ),
        ).thenAnswer((_) => completer.future);

        final container = createContainer();
        final notifier = container.read(checkoutNotifierProvider.notifier);

        // Start first checkout (remains in loading)
        final firstCall = notifier.processCheckout(
          userId: 5,
          items: items,
          onOrderConfirmed: () async {},
        );

        expect(
          container.read(checkoutNotifierProvider),
          const CheckoutLoading(),
        );

        // Attempt second duplicate checkout while still loading
        final secondCallResult = await notifier.processCheckout(
          userId: 5,
          items: items,
          onOrderConfirmed: () async {},
        );

        // Duplicate submission rejected immediately
        expect(secondCallResult, false);

        // Complete first call
        completer.complete(const Result.success(testOrder));
        final firstCallResult = await firstCall;
        expect(firstCallResult, true);
      },
    );

    test('checkout with empty items list is rejected', () async {
      final container = createContainer();
      final notifier = container.read(checkoutNotifierProvider.notifier);

      final success = await notifier.processCheckout(
        userId: 5,
        items: const [],
        onOrderConfirmed: () async {},
      );

      expect(success, false);
      expect(
        container.read(checkoutNotifierProvider),
        const CheckoutError('Cannot checkout with an empty cart.'),
      );
    });
  });
}
