import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';

/// Concrete implementation of [CartRepository] backed by local persistent storage.
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  const CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<List<CartItem>>> getCart() async {
    try {
      final items = await localDataSource.getCartItems();
      return Result.success(items);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(
        CacheFailure('Unexpected error loading cart items: $e'),
      );
    }
  }

  @override
  Future<Result<void>> saveCart(List<CartItem> items) async {
    try {
      final models = items.map(CartItemModel.fromEntity).toList();
      await localDataSource.saveCartItems(models);
      return const Result.success(null);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(
        CacheFailure('Unexpected error persisting cart items: $e'),
      );
    }
  }

  @override
  Future<Result<void>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return const Result.success(null);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(
        CacheFailure('Unexpected error clearing cart items: $e'),
      );
    }
  }
}
