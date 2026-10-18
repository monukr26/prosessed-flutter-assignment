import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:shopsphere/features/products/presentation/providers/product_details_notifier.dart';
import 'package:shopsphere/features/products/presentation/providers/product_details_state.dart';

class MockGetProductDetailsUseCase extends Mock
    implements GetProductDetailsUseCase {}

void main() {
  late MockGetProductDetailsUseCase mockUseCase;
  late ProviderContainer container;

  const inStockProduct = Product(
    id: 1,
    title: 'Flagship Phone',
    description: 'High performance device',
    category: 'smartphones',
    price: 799.0,
    discountPercentage: 10.0,
    rating: 4.8,
    stock: 3, // Max stock = 3
    thumbnail: 'https://example.com/p1.png',
  );

  const outOfStockProduct = Product(
    id: 2,
    title: 'Soldout Headphones',
    description: 'Out of stock audio device',
    category: 'audio',
    price: 199.0,
    discountPercentage: 0,
    rating: 4.2,
    stock: 0, // Out of stock
    thumbnail: 'https://example.com/p2.png',
  );

  setUp(() {
    mockUseCase = MockGetProductDetailsUseCase();

    container = ProviderContainer(
      overrides: [
        productDetailsNotifierProvider.overrideWith2(
          (id) => ProductDetailsNotifier(id, mockUseCase),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('loadProductDetails', () {
    test('emits [loading, success] with quantity 1 when in stock', () async {
      when(
        () => mockUseCase(1),
      ).thenAnswer((_) async => const Result.success(inStockProduct));

      final notifier = container.read(
        productDetailsNotifierProvider(1).notifier,
      );
      await notifier.loadProduct(1);

      final state = container.read(productDetailsNotifierProvider(1));
      expect(state.status, equals(ProductDetailsStatus.success));
      expect(state.product, equals(inStockProduct));
      expect(state.quantity, equals(1));
      expect(state.isOutOfStock, isFalse);
    });

    test(
      'emits [loading, notFound] when product does not exist (ID 9999)',
      () async {
        when(() => mockUseCase(9999)).thenAnswer(
          (_) async =>
              const Result.failure(NotFoundFailure('Product not found', 404)),
        );

        final notifier = container.read(
          productDetailsNotifierProvider(9999).notifier,
        );
        await notifier.loadProduct(9999);

        final state = container.read(productDetailsNotifierProvider(9999));
        expect(state.status, equals(ProductDetailsStatus.notFound));
        expect(state.isNotFound, isTrue);
        expect(state.product, isNull);
      },
    );

    test('emits [loading, error] on server failure', () async {
      when(() => mockUseCase(1)).thenAnswer(
        (_) async =>
            const Result.failure(ServerFailure('Internal Server Error', 500)),
      );

      final notifier = container.read(
        productDetailsNotifierProvider(1).notifier,
      );
      await notifier.loadProduct(1);

      final state = container.read(productDetailsNotifierProvider(1));
      expect(state.status, equals(ProductDetailsStatus.error));
      expect(state.isError, isTrue);
      expect(state.errorMessage, equals('Internal Server Error'));
    });
  });

  group('quantity controls and out of stock behaviour', () {
    test('increments quantity up to available stock limit', () async {
      when(
        () => mockUseCase(1),
      ).thenAnswer((_) async => const Result.success(inStockProduct));

      final notifier = container.read(
        productDetailsNotifierProvider(1).notifier,
      );
      await notifier.loadProduct(1);

      expect(
        container.read(productDetailsNotifierProvider(1)).quantity,
        equals(1),
      );

      // Increment to 2
      notifier.incrementQuantity();
      expect(
        container.read(productDetailsNotifierProvider(1)).quantity,
        equals(2),
      );

      // Increment to 3 (max stock = 3)
      notifier.incrementQuantity();
      expect(
        container.read(productDetailsNotifierProvider(1)).quantity,
        equals(3),
      );

      // Try increment beyond stock (should remain 3)
      notifier.incrementQuantity();
      expect(
        container.read(productDetailsNotifierProvider(1)).quantity,
        equals(3),
      );
    });

    test('decrements quantity down to minimum of 1', () async {
      when(
        () => mockUseCase(1),
      ).thenAnswer((_) async => const Result.success(inStockProduct));

      final notifier = container.read(
        productDetailsNotifierProvider(1).notifier,
      );
      await notifier.loadProduct(1);

      // Increment to 2
      notifier.incrementQuantity();
      expect(
        container.read(productDetailsNotifierProvider(1)).quantity,
        equals(2),
      );

      // Decrement back to 1
      notifier.decrementQuantity();
      expect(
        container.read(productDetailsNotifierProvider(1)).quantity,
        equals(1),
      );

      // Decrement below 1 should be prevented
      notifier.decrementQuantity();
      expect(
        container.read(productDetailsNotifierProvider(1)).quantity,
        equals(1),
      );
    });

    test(
      'out of stock product initializes with quantity 0 and ignores increment',
      () async {
        when(
          () => mockUseCase(2),
        ).thenAnswer((_) async => const Result.success(outOfStockProduct));

        final notifier = container.read(
          productDetailsNotifierProvider(2).notifier,
        );
        await notifier.loadProduct(2);

        final state = container.read(productDetailsNotifierProvider(2));
        expect(state.isOutOfStock, isTrue);
        expect(state.quantity, equals(0));

        notifier.incrementQuantity();
        expect(
          container.read(productDetailsNotifierProvider(2)).quantity,
          equals(0),
        );
      },
    );
  });
}
