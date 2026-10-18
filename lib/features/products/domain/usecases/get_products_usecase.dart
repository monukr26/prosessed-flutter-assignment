import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repository;

  const GetProductsUseCase(this._repository);

  Future<Result<PaginatedProducts>> call({
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  }) {
    return _repository.getProducts(
      limit: limit,
      skip: skip,
      sortOption: sortOption,
    );
  }
}
