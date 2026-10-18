import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/cart/data/datasources/checkout_remote_data_source.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late CheckoutRemoteDataSourceImpl dataSource;

  const testProduct1 = Product(
    id: 144,
    title: 'Product 144',
    description: 'Desc',
    category: 'electronics',
    price: 99.0,
    discountPercentage: 10.0,
    rating: 4.5,
    stock: 5,
    thumbnail: 'https://example.com/144.jpg',
  );

  const testProduct2 = Product(
    id: 145,
    title: 'Product 145',
    description: 'Desc',
    category: 'electronics',
    price: 50.0,
    discountPercentage: 0.0,
    rating: 4.2,
    stock: 10,
    thumbnail: 'https://example.com/145.jpg',
  );

  setUp(() {
    mockDio = MockDio();
    dataSource = CheckoutRemoteDataSourceImpl(mockDio);
  });

  group('CheckoutRemoteDataSourceImpl', () {
    const items = [
      CartItem(product: testProduct1, quantity: 2),
      CartItem(product: testProduct2, quantity: 1),
    ];

    test('correctly maps request payload and parses 201 response', () async {
      final responseData = {
        'id': 209,
        'products': [
          {
            'id': 144,
            'title': 'Product 144',
            'price': 99.0,
            'quantity': 2,
            'total': 198.0,
            'discountPercentage': 10.0,
            'discountedPrice': 178.2,
            'thumbnail': 'https://example.com/144.jpg',
          },
          {
            'id': 145,
            'title': 'Product 145',
            'price': 50.0,
            'quantity': 1,
            'total': 50.0,
            'discountPercentage': 0.0,
            'discountedPrice': 50.0,
            'thumbnail': 'https://example.com/145.jpg',
          },
        ],
        'total': 248.0,
        'discountedTotal': 228.2,
        'userId': 5,
        'totalProducts': 2,
        'totalQuantity': 3,
      };

      when(
        () => mockDio.post(ApiEndpoints.addCart, data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.addCart),
          statusCode: 201,
          data: responseData,
        ),
      );

      final order = await dataSource.checkout(userId: 5, items: items);

      expect(order.id, 209);
      expect(order.userId, 5);
      expect(order.products.length, 2);
      expect(order.totalQuantity, 3);
      expect(order.discountedTotal, 228.2);

      // Verify request payload matches DummyJSON contract
      verify(
        () => mockDio.post(
          ApiEndpoints.addCart,
          data: {
            'userId': 5,
            'products': [
              {'id': 144, 'quantity': 2},
              {'id': 145, 'quantity': 1},
            ],
          },
        ),
      ).called(1);
    });

    test('throws NetworkException on connection timeout', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.addCart),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => dataSource.checkout(userId: 1, items: items),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws ServerException on 500 error response', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.addCart),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.addCart),
            statusCode: 500,
            data: {'message': 'Internal Server Error'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.checkout(userId: 1, items: items),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
