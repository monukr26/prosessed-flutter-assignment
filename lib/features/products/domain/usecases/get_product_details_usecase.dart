import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

class GetProductDetailsUseCase {
  final ProductRepository _repository;

  const GetProductDetailsUseCase(this._repository);

  Future<Result<Product>> call(int id) {
    return _repository.getProductDetails(id);
  }
}
