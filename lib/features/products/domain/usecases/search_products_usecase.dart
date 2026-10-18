import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository _repository;

  const SearchProductsUseCase(this._repository);

  Future<Result<PaginatedProducts>> call({
    required String query,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  }) {
    return _repository.searchProducts(
      query: query,
      limit: limit,
      skip: skip,
      sortOption: sortOption,
    );
  }
}
