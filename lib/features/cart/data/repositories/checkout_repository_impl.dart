import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/data/datasources/checkout_remote_data_source.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_order.dart';
import 'package:shopsphere/features/cart/domain/repositories/checkout_repository.dart';

/// Concrete implementation of [CheckoutRepository] invoking DummyJSON cart endpoint.
class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  const CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<CheckoutOrder>> checkout({
    required int userId,
    required List<CartItem> items,
  }) async {
    try {
      final orderModel = await remoteDataSource.checkout(
        userId: userId,
        items: items,
      );
      return Result.success(orderModel);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.failure(
        ServerFailure('Unexpected error submitting checkout: $e'),
      );
    }
  }
}
