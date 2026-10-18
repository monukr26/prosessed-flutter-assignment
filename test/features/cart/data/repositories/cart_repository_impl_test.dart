import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';
import 'package:shopsphere/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

void main() {
  late MockCartLocalDataSource mockLocalDataSource;
  late CartRepositoryImpl repository;

  const testProduct = Product(
    id: 1,
    title: 'Item 1',
    description: 'Desc',
    category: 'cat',
    price: 20.0,
    discountPercentage: 0.0,
    rating: 4.0,
    stock: 5,
    thumbnail: 'https://example.com/thumb.jpg',
  );

  setUp(() {
    mockLocalDataSource = MockCartLocalDataSource();
    repository = CartRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  group('CartRepositoryImpl', () {
    test(
      'getCart returns Success with items when local data source succeeds',
      () async {
        const items = [CartItemModel(product: testProduct, quantity: 2)];
        when(
          () => mockLocalDataSource.getCartItems(),
        ).thenAnswer((_) async => items);

        final result = await repository.getCart();

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.length, 1);
        expect(result.dataOrNull?.first.quantity, 2);
      },
    );

    test(
      'getCart returns CacheFailure when local data source throws CacheException',
      () async {
        when(
          () => mockLocalDataSource.getCartItems(),
        ).thenThrow(const CacheException('Cache corrupted'));

        final result = await repository.getCart();

        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<CacheFailure>());
        expect(result.failureOrNull?.message, 'Cache corrupted');
      },
    );

    test('saveCart persists items and returns Success', () async {
      const items = [CartItem(product: testProduct, quantity: 1)];
      when(
        () => mockLocalDataSource.saveCartItems(any()),
      ).thenAnswer((_) async {});

      final result = await repository.saveCart(items);

      expect(result.isSuccess, true);
      verify(() => mockLocalDataSource.saveCartItems(any())).called(1);
    });

    test(
      'clearCart delegates to local data source and returns Success',
      () async {
        when(() => mockLocalDataSource.clearCart()).thenAnswer((_) async {});

        final result = await repository.clearCart();

        expect(result.isSuccess, true);
        verify(() => mockLocalDataSource.clearCart()).called(1);
      },
    );
  });
}
