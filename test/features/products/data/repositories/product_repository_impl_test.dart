import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/category_model.dart';
import 'package:shopsphere/features/products/data/models/paginated_products_model.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';

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
    description: 'High end device',
    category: 'smartphones',
    price: 999.0,
    discountPercentage: 10.0,
    rating: 4.8,
    stock: 12,
    brand: 'Apple',
    thumbnail: 'https://example.com/phone.png',
  );

  const testPaginated = PaginatedProductsModel(
    products: [testProduct],
    total: 100,
    skip: 0,
    limit: 20,
  );

  group('getProducts', () {
    test('returns PaginatedProducts on remote data source success', () async {
      when(
        () => mockRemoteDataSource.getProducts(
          limit: 20,
          skip: 0,
          sortOption: SortOption.none,
        ),
      ).thenAnswer((_) async => testPaginated);

      final result = await repository.getProducts(limit: 20, skip: 0);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.products.length, equals(1));
      expect(result.dataOrNull?.products.first.id, equals(1));
      expect(result.dataOrNull?.total, equals(100));
      expect(result.dataOrNull?.hasMore, isTrue);
    });

    test(
      'returns ServerFailure when remote data source throws ServerException',
      () async {
        when(
          () => mockRemoteDataSource.getProducts(
            limit: 20,
            skip: 0,
            sortOption: SortOption.none,
          ),
        ).thenThrow(
          const ServerException('Internal Server Error', statusCode: 500),
        );

        final result = await repository.getProducts(limit: 20, skip: 0);

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(const ServerFailure('Internal Server Error', 500)),
        );
      },
    );

    test(
      'returns NetworkFailure when remote data source throws NetworkException',
      () async {
        when(
          () => mockRemoteDataSource.getProducts(
            limit: 20,
            skip: 0,
            sortOption: SortOption.none,
          ),
        ).thenThrow(const NetworkException('No internet connection'));

        final result = await repository.getProducts(limit: 20, skip: 0);

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(const NetworkFailure('No internet connection')),
        );
      },
    );
  });

  group('searchProducts', () {
    test('returns filtered products on search success', () async {
      when(
        () => mockRemoteDataSource.searchProducts(
          query: 'phone',
          limit: 20,
          skip: 0,
          sortOption: SortOption.none,
        ),
      ).thenAnswer((_) async => testPaginated);

      final result = await repository.searchProducts(query: 'phone');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.products.first.title, equals('Phone Pro'));
    });
  });

  group('getCategories', () {
    test('returns list of categories on remote data source success', () async {
      const testCategories = [
        CategoryModel(slug: 'smartphones', name: 'Smartphones'),
        CategoryModel(slug: 'laptops', name: 'Laptops'),
      ];

      when(
        () => mockRemoteDataSource.getCategories(),
      ).thenAnswer((_) async => testCategories);

      final result = await repository.getCategories();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.length, equals(2));
      expect(result.dataOrNull?.first.slug, equals('smartphones'));
    });
  });
}
