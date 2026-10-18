import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_details_usecase.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;
  late GetProductDetailsUseCase useCase;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductDetailsUseCase(mockRepository);
  });

  const testProduct = Product(
    id: 1,
    title: 'Phone Pro',
    description: 'A test phone',
    category: 'smartphones',
    price: 800.0,
    discountPercentage: 10.0,
    rating: 4.5,
    stock: 5,
    thumbnail: 'https://example.com/thumb.png',
  );

  test('returns Product on repository success', () async {
    when(
      () => mockRepository.getProductDetails(1),
    ).thenAnswer((_) async => const Result.success(testProduct));

    final result = await useCase(1);

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, equals(testProduct));
    verify(() => mockRepository.getProductDetails(1)).called(1);
  });

  test(
    'returns NotFoundFailure when product does not exist (e.g. ID 9999)',
    () async {
      when(() => mockRepository.getProductDetails(9999)).thenAnswer(
        (_) async =>
            const Result.failure(NotFoundFailure('Product not found', 404)),
      );

      final result = await useCase(9999);

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(const NotFoundFailure('Product not found', 404)),
      );
    },
  );

  test('returns ServerFailure on remote server error', () async {
    when(() => mockRepository.getProductDetails(1)).thenAnswer(
      (_) async =>
          const Result.failure(ServerFailure('Internal Server Error', 500)),
    );

    final result = await useCase(1);

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull,
      equals(const ServerFailure('Internal Server Error', 500)),
    );
  });
}
