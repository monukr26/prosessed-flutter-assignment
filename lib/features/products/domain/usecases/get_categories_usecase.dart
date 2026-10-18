import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

class GetCategoriesUseCase {
  final ProductRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<Result<List<Category>>> call() {
    return _repository.getCategories();
  }
}
