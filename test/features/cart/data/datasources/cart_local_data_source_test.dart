import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late CartLocalDataSourceImpl dataSource;

  const testProduct = Product(
    id: 1,
    title: 'Test Perfume',
    description: 'Floral aroma perfume',
    category: 'fragrances',
    price: 39.99,
    discountPercentage: 15.0,
    rating: 4.7,
    stock: 20,
    thumbnail: 'https://example.com/perfume.jpg',
  );

  setUp(() {
    mockPrefs = MockSharedPreferences();
    dataSource = CartLocalDataSourceImpl(mockPrefs);
  });

  group('CartLocalDataSourceImpl', () {
    test('returns empty list when no cached cart string exists', () async {
      when(
        () => mockPrefs.getString(CartLocalDataSourceImpl.cartStorageKey),
      ).thenReturn(null);

      final result = await dataSource.getCartItems();

      expect(result, isEmpty);
      verify(
        () => mockPrefs.getString(CartLocalDataSourceImpl.cartStorageKey),
      ).called(1);
    });

    test('returns empty list when cached string is empty whitespace', () async {
      when(
        () => mockPrefs.getString(CartLocalDataSourceImpl.cartStorageKey),
      ).thenReturn('   ');

      final result = await dataSource.getCartItems();

      expect(result, isEmpty);
    });

    test('correctly deserializes valid cached JSON array', () async {
      const validJson = '''
      [
        {
          "quantity": 2,
          "product": {
            "id": 1,
            "title": "Test Perfume",
            "description": "Floral aroma perfume",
            "category": "fragrances",
            "price": 39.99,
            "discountPercentage": 15.0,
            "rating": 4.7,
            "stock": 20,
            "thumbnail": "https://example.com/perfume.jpg"
          }
        }
      ]
      ''';

      when(
        () => mockPrefs.getString(CartLocalDataSourceImpl.cartStorageKey),
      ).thenReturn(validJson);

      final result = await dataSource.getCartItems();

      expect(result.length, 1);
      expect(result.first.quantity, 2);
      expect(result.first.product.id, 1);
      expect(result.first.product.title, 'Test Perfume');
    });

    test(
      'safely recovers and returns valid items when some cached entries are malformed',
      () async {
        const mixedJson = '''
      [
        {
          "quantity": 3,
          "product": {
            "id": 1,
            "title": "Valid Item",
            "price": 10.0,
            "stock": 5,
            "thumbnail": "https://example.com/valid.jpg"
          }
        },
        "not_a_valid_json_object",
        {
          "quantity": "invalid_quantity_type",
          "product": "invalid"
        }
      ]
      ''';

        when(
          () => mockPrefs.getString(CartLocalDataSourceImpl.cartStorageKey),
        ).thenReturn(mixedJson);

        final result = await dataSource.getCartItems();

        expect(result.isNotEmpty, true);
        expect(result.first.product.title, 'Valid Item');
      },
    );

    test('saves serialized items to SharedPreferences', () async {
      const items = [CartItemModel(product: testProduct, quantity: 2)];

      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      await dataSource.saveCartItems(items);

      verify(
        () => mockPrefs.setString(
          CartLocalDataSourceImpl.cartStorageKey,
          any(that: contains('Test Perfume')),
        ),
      ).called(1);
    });

    test('clears cart storage key in SharedPreferences', () async {
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

      await dataSource.clearCart();

      verify(
        () => mockPrefs.remove(CartLocalDataSourceImpl.cartStorageKey),
      ).called(1);
    });
  });
}
