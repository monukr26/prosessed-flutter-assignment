import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

void main() {
  late MockProductRemoteDataSource mockRemoteDataSource;
  late ProductRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const testProduct = ProductModel(
    id: 1,
    title: 'Phone Pro',
    description: 'Detailed description',
    category: 'smartphones',
    price: 999.0,
    discountPercentage: 10.0,
    rating: 4.8,
    stock: 8,
    brand: 'Apple',
    thumbnail: 'https://example.com/phone.png',
  );

  group('getProductDetails', () {
    test('returns Product on remote success', () async {
      when(
        () => mockRemoteDataSource.getProductDetails(1),
      ).thenAnswer((_) async => testProduct);

      final result = await repository.getProductDetails(1);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.id, equals(1));
      expect(result.dataOrNull?.title, equals('Phone Pro'));
    });

    test(
      'returns NotFoundFailure when remote throws NotFoundException 404',
      () async {
        when(() => mockRemoteDataSource.getProductDetails(9999)).thenThrow(
          const NotFoundException('Product not found', statusCode: 404),
        );

        final result = await repository.getProductDetails(9999);

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(const NotFoundFailure('Product not found', 404)),
        );
      },
    );

    test(
      'returns ServerFailure when remote throws ServerException 500',
      () async {
        when(
          () => mockRemoteDataSource.getProductDetails(1),
        ).thenThrow(const ServerException('Server error', statusCode: 500));

        final result = await repository.getProductDetails(1);

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(const ServerFailure('Server error', 500)),
        );
      },
    );

    test(
      'returns NetworkFailure when remote throws NetworkException',
      () async {
        when(
          () => mockRemoteDataSource.getProductDetails(1),
        ).thenThrow(const NetworkException('No internet'));

        final result = await repository.getProductDetails(1);

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(const NetworkFailure('No internet')),
        );
      },
    );
  });
}
