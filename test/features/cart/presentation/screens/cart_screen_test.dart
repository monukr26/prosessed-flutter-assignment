import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_totals.dart';
import 'package:shopsphere/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/save_cart_usecase.dart';
import 'package:shopsphere/features/cart/presentation/providers/cart_notifier.dart';
import 'package:shopsphere/features/cart/presentation/providers/cart_state.dart';
import 'package:shopsphere/features/cart/presentation/providers/checkout_notifier.dart';
import 'package:shopsphere/features/cart/presentation/providers/checkout_state.dart';
import 'package:shopsphere/features/cart/presentation/screens/cart_screen.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockSaveCartUseCase extends Mock implements SaveCartUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late MockGetCartUseCase mockGetCart;
  late MockSaveCartUseCase mockSaveCart;
  late MockClearCartUseCase mockClearCart;

  const testProduct = Product(
    id: 1,
    title: 'Essence Mascara Lash Princess',
    description: 'Test description',
    category: 'beauty',
    price: 9.99,
    discountPercentage: 7.17,
    rating: 4.94,
    stock: 5,
    brand: 'Essence',
    thumbnail:
        'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png',
    images: [],
  );

  const testItem = CartItem(product: testProduct, quantity: 2);

  setUp(() {
    mockGetCart = MockGetCartUseCase();
    mockSaveCart = MockSaveCartUseCase();
    mockClearCart = MockClearCartUseCase();

    when(
      () => mockGetCart(),
    ).thenAnswer((_) async => const Result.success([testItem]));
    when(
      () => mockSaveCart(any()),
    ).thenAnswer((_) async => const Result.success(null));
  });

  Widget buildCartScreen({List<CartItem> items = const [testItem]}) {
    return ProviderScope(
      overrides: [
        cartNotifierProvider.overrideWith(
          () => FakeCartNotifier(
            CartState(
              status: CartStatus.loaded,
              items: items,
              totals: CartTotals.calculate(items),
            ),
            getCartUseCase: mockGetCart,
            saveCartUseCase: mockSaveCart,
            clearCartUseCase: mockClearCart,
          ),
        ),
        checkoutNotifierProvider.overrideWith(() => FakeCheckoutNotifier()),
      ],
      child: const MaterialApp(home: CartScreen()),
    );
  }

  testWidgets('renders back button in AppBar and shopping cart title', (
    tester,
  ) async {
    await tester.pumpWidget(buildCartScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('Shopping Cart (2)'), findsOneWidget);
    expect(find.byType(CartItemTile), findsOneWidget);
  });

  testWidgets(
    'tapping back button pops when canPop is true or triggers back action',
    (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartNotifierProvider.overrideWith(
              () => FakeCartNotifier(
                CartState(
                  status: CartStatus.loaded,
                  items: const [testItem],
                  totals: CartTotals.calculate(const [testItem]),
                ),
                getCartUseCase: mockGetCart,
                saveCartUseCase: mockSaveCart,
                clearCartUseCase: mockClearCart,
              ),
            ),
            checkoutNotifierProvider.overrideWith(() => FakeCheckoutNotifier()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CartScreen(),
                          ),
                        )
                        .then((_) {
                          popped = true;
                        });
                  },
                  child: const Text('Open Cart'),
                );
              },
            ),
          ),
        ),
      );

      // Tap Open Cart
      await tester.tap(find.text('Open Cart'));
      await tester.pumpAndSettle();

      expect(find.byType(CartScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Tap the Back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.text('Open Cart'), findsOneWidget);
    },
  );

  testWidgets('CartItemTile triggers onTap when tapped', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CartItemTile(
            item: testItem,
            onIncrement: () {},
            onDecrement: () {},
            onRemove: () {},
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Tap on product title or card
    await tester.tap(find.text('Essence Mascara Lash Princess'));
    expect(tapped, isTrue);
  });
}

class FakeCartNotifier extends CartNotifier {
  final CartState _initialState;

  FakeCartNotifier(
    this._initialState, {
    super.getCartUseCase,
    super.saveCartUseCase,
    super.clearCartUseCase,
  });

  @override
  CartState build() => _initialState;
}

class FakeCheckoutNotifier extends CheckoutNotifier {
  @override
  CheckoutState build() => const CheckoutInitial();
}
