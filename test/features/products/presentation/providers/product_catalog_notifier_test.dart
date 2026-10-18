import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_by_category_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/search_products_usecase.dart';
import 'package:shopsphere/features/products/presentation/providers/product_catalog_notifier.dart';
import 'package:shopsphere/features/products/presentation/providers/product_catalog_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

class MockGetProductsByCategoryUseCase extends Mock
    implements GetProductsByCategoryUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockSearchProductsUseCase mockSearchProductsUseCase;
  late MockGetProductsByCategoryUseCase mockGetProductsByCategoryUseCase;
  late ProviderContainer container;

  const product1 = Product(
    id: 1,
    title: 'Alpha Phone',
    description: 'First test product',
    category: 'smartphones',
    price: 500.0,
    discountPercentage: 0,
    rating: 4.5,
    stock: 10,
    thumbnail: 'https://example.com/p1.png',
  );

  const product2 = Product(
    id: 2,
    title: 'Beta Laptop',
    description: 'Second test product',
    category: 'laptops',
    price: 1200.0,
    discountPercentage: 10,
    rating: 4.8,
    stock: 5,
    thumbnail: 'https://example.com/p2.png',
  );

  setUpAll(() {
    registerFallbackValue(SortOption.none);
  });

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockSearchProductsUseCase = MockSearchProductsUseCase();
    mockGetProductsByCategoryUseCase = MockGetProductsByCategoryUseCase();

    container = ProviderContainer(
      overrides: [
        productCatalogNotifierProvider.overrideWith(
          () => ProductCatalogNotifier(
            getProductsUseCase: mockGetProductsUseCase,
            searchProductsUseCase: mockSearchProductsUseCase,
            getProductsByCategoryUseCase: mockGetProductsByCategoryUseCase,
          ),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('loadInitial', () {
    test('emits [loading, success] on successful fetch', () async {
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortOption: any(named: 'sortOption'),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          PaginatedProducts(
            products: [product1],
            total: 10,
            skip: 0,
            limit: 20,
          ),
        ),
      );

      final notifier = container.read(productCatalogNotifierProvider.notifier);
      await notifier.loadInitial();

      final state = container.read(productCatalogNotifierProvider);
      expect(state.status, equals(ProductStatus.success));
      expect(state.products.length, equals(1));
      expect(state.hasMore, isTrue);
    });

    test(
      'emits [loading, empty] when response returns zero products',
      () async {
        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            sortOption: any(named: 'sortOption'),
          ),
        ).thenAnswer(
          (_) async => const Result.success(
            PaginatedProducts(products: [], total: 0, skip: 0, limit: 20),
          ),
        );

        final notifier = container.read(
          productCatalogNotifierProvider.notifier,
        );
        await notifier.loadInitial();

        final state = container.read(productCatalogNotifierProvider);
        expect(state.status, equals(ProductStatus.empty));
        expect(state.products, isEmpty);
      },
    );

    test('emits [loading, error] on failure', () async {
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortOption: any(named: 'sortOption'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          ServerFailure('Failed to connect to server', 500),
        ),
      );

      final notifier = container.read(productCatalogNotifierProvider.notifier);
      await notifier.loadInitial();

      final state = container.read(productCatalogNotifierProvider);
      expect(state.status, equals(ProductStatus.error));
      expect(state.errorMessage, equals('Failed to connect to server'));
    });
  });

  group('pagination and loadMore', () {
    test('appends newly loaded items and updates hasMore flag', () async {
      // First page
      when(
        () => mockGetProductsUseCase(
          limit: 20,
          skip: 0,
          sortOption: any(named: 'sortOption'),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          PaginatedProducts(products: [product1], total: 2, skip: 0, limit: 20),
        ),
      );

      // Second page
      when(
        () => mockGetProductsUseCase(
          limit: 20,
          skip: 1,
          sortOption: any(named: 'sortOption'),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          PaginatedProducts(products: [product2], total: 2, skip: 1, limit: 20),
        ),
      );

      final notifier = container.read(productCatalogNotifierProvider.notifier);
      await notifier.loadInitial();

      expect(container.read(productCatalogNotifierProvider).hasMore, isTrue);

      await notifier.loadMore();

      final state = container.read(productCatalogNotifierProvider);
      expect(state.products.length, equals(2));
      expect(state.products[0], equals(product1));
      expect(state.products[1], equals(product2));
      expect(state.hasMore, isFalse);
    });

    test('ignores duplicate pagination calls if hasMore is false', () async {
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortOption: any(named: 'sortOption'),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          PaginatedProducts(products: [product1], total: 1, skip: 0, limit: 20),
        ),
      );

      final notifier = container.read(productCatalogNotifierProvider.notifier);
      await notifier.loadInitial();

      // hasMore is false because 1 == total
      expect(container.read(productCatalogNotifierProvider).hasMore, isFalse);

      await notifier.loadMore();

      // Verify getProducts was only called once for loadInitial
      verify(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: 0,
          sortOption: any(named: 'sortOption'),
        ),
      ).called(1);
      verifyNoMoreInteractions(mockGetProductsUseCase);
    });
  });

  group('filters and search reset', () {
    test(
      'selectCategory updates category, clears search and resets skip to 0',
      () async {
        const category = Category(slug: 'smartphones', name: 'Smartphones');

        when(
          () => mockGetProductsByCategoryUseCase(
            categorySlug: 'smartphones',
            limit: any(named: 'limit'),
            skip: 0,
            sortOption: any(named: 'sortOption'),
          ),
        ).thenAnswer(
          (_) async => const Result.success(
            PaginatedProducts(
              products: [product1],
              total: 1,
              skip: 0,
              limit: 20,
            ),
          ),
        );

        final notifier = container.read(
          productCatalogNotifierProvider.notifier,
        );
        notifier.selectCategory(category);

        final state = container.read(productCatalogNotifierProvider);
        expect(state.selectedCategory, equals(category));
        expect(state.searchQuery, isEmpty);
      },
    );

    test(
      'setSearchQuery updates search, clears category and resets skip to 0',
      () async {
        when(
          () => mockSearchProductsUseCase(
            query: 'phone',
            limit: any(named: 'limit'),
            skip: 0,
            sortOption: any(named: 'sortOption'),
          ),
        ).thenAnswer(
          (_) async => const Result.success(
            PaginatedProducts(
              products: [product1],
              total: 1,
              skip: 0,
              limit: 20,
            ),
          ),
        );

        final notifier = container.read(
          productCatalogNotifierProvider.notifier,
        );
        notifier.setSearchQuery('phone');

        final state = container.read(productCatalogNotifierProvider);
        expect(state.searchQuery, equals('phone'));
        expect(state.selectedCategory, isNull);
      },
    );
  });

  group('sorting', () {
    test('setSortOption sorts loaded products in-memory', () async {
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortOption: any(named: 'sortOption'),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          PaginatedProducts(
            products: [product2, product1], // product2: 1080$, product1: 500$
            total: 2,
            skip: 0,
            limit: 20,
          ),
        ),
      );

      final notifier = container.read(productCatalogNotifierProvider.notifier);
      await notifier.loadInitial();

      // Apply price ascending
      notifier.setSortOption(SortOption.priceAsc);

      final state = container.read(productCatalogNotifierProvider);
      expect(state.sortOption, equals(SortOption.priceAsc));
      expect(state.products.first.id, equals(1)); // 500$ first
      expect(state.products.last.id, equals(2)); // 1080$ second
    });
  });
}
