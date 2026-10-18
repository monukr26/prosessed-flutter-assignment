import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

class GetProductsByCategoryUseCase {
  final ProductRepository _repository;

  const GetProductsByCategoryUseCase(this._repository);

  Future<Result<PaginatedProducts>> call({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  }) {
    return _repository.getProductsByCategory(
      categorySlug: categorySlug,
      limit: limit,
      skip: skip,
      sortOption: sortOption,
    );
  }
}
