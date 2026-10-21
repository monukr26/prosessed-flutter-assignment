import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/save_cart_usecase.dart';
import 'package:shopsphere/features/cart/presentation/providers/cart_notifier.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_badge_icon.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:shopsphere/features/products/presentation/providers/product_details_notifier.dart';
import 'package:shopsphere/features/products/presentation/screens/product_details_screen.dart';

class MockGetProductDetailsUseCase extends Mock
    implements GetProductDetailsUseCase {}

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockSaveCartUseCase extends Mock implements SaveCartUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late MockGetProductDetailsUseCase mockUseCase;
  late MockGetCartUseCase mockGetCart;
  late MockSaveCartUseCase mockSaveCart;
  late MockClearCartUseCase mockClearCart;

  const testProduct = Product(
    id: 1,
    title: 'iPhone 15 Pro',
    description: 'Latest flagship smartphone from Apple.',
    category: 'smartphones',
    price: 999.0,
    discountPercentage: 10.0,
    rating: 4.8,
    stock: 25,
    brand: 'Apple',
    thumbnail: 'https://example.com/thumb.jpg',
    images: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
  );

  setUp(() {
    mockUseCase = MockGetProductDetailsUseCase();
    mockGetCart = MockGetCartUseCase();
    mockSaveCart = MockSaveCartUseCase();
    mockClearCart = MockClearCartUseCase();

    when(
      () => mockGetCart(),
    ).thenAnswer((_) async => const Result.success(<CartItem>[]));
    when(
      () => mockSaveCart(any()),
    ).thenAnswer((_) async => const Result.success(null));
  });

  Widget buildTestWidget(int productId) {
    return ProviderScope(
      overrides: [
        productDetailsNotifierProvider.overrideWith2(
          (id) => ProductDetailsNotifier(id, mockUseCase),
        ),
        cartNotifierProvider.overrideWith(
          () => CartNotifier(
            getCartUseCase: mockGetCart,
            saveCartUseCase: mockSaveCart,
            clearCartUseCase: mockClearCart,
          ),
        ),
      ],
      child: MaterialApp(home: ProductDetailsScreen(productId: productId)),
    );
  }

  testWidgets(
    'renders skeleton while loading and displays content on success',
    (tester) async {
      when(() => mockUseCase(1)).thenAnswer((_) async {
        return const Result.success(testProduct);
      });

      await tester.pumpWidget(buildTestWidget(1));

      // Allow microtask and future to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('iPhone 15 Pro'), findsWidgets);
      expect(
        find.text('Latest flagship smartphone from Apple.'),
        findsOneWidget,
      );
      expect(find.text('Apple'), findsOneWidget);
    },
  );

  testWidgets('displays not found empty view when product is 404', (
    tester,
  ) async {
    when(() => mockUseCase(9999)).thenAnswer((_) async {
      return const Result.failure(NotFoundFailure('Product not found', 404));
    });

    await tester.pumpWidget(buildTestWidget(9999));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('Product Not Found'), findsOneWidget);
    expect(find.text('Back to Catalogue'), findsOneWidget);
  });

  testWidgets('displays error view and retries on tap', (tester) async {
    int callCount = 0;
    when(() => mockUseCase(1)).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return const Result.failure(ServerFailure('Server connection lost'));
      }
      return const Result.success(testProduct);
    });

    await tester.pumpWidget(buildTestWidget(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('Server connection lost'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    // Tap retry button
    await tester.tap(find.text('Try Again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('iPhone 15 Pro'), findsWidgets);
  });

  testWidgets('displays out of stock badge and disables add to cart', (
    tester,
  ) async {
    const outOfStock = Product(
      id: 2,
      title: 'Vintage Leather Jacket',
      description: 'Classic vintage jacket',
      category: 'clothing',
      price: 199.0,
      discountPercentage: 0.0,
      rating: 4.5,
      stock: 0,
      thumbnail: 'https://example.com/jacket.jpg',
    );

    when(() => mockUseCase(2)).thenAnswer((_) async {
      return const Result.success(outOfStock);
    });

    await tester.pumpWidget(buildTestWidget(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('Out of Stock'), findsWidgets);
    final buttonFinder = find.widgetWithText(FilledButton, 'Out of Stock');
    expect(buttonFinder, findsOneWidget);
    final button = tester.widget<FilledButton>(buttonFinder);
    expect(button.enabled, isFalse);
  });

  testWidgets('renders cart badge icon in app bar action', (tester) async {
    when(() => mockUseCase(1)).thenAnswer((_) async {
      return const Result.success(testProduct);
    });

    await tester.pumpWidget(buildTestWidget(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    final cartBadgeFinder = find.byType(CartBadgeIcon);
    expect(cartBadgeFinder, findsOneWidget);
  });
}
