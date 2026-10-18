import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/di/service_locator.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/usecases/get_categories_usecase.dart';

/// Riverpod AsyncNotifier fetching product categories from API.
class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final useCase = sl<GetCategoriesUseCase>();
    final result = await useCase();
    return result.when(
      success: (categories) => categories,
      failure: (failure) => throw failure,
    );
  }

  Future<void> retry() async {
    ref.invalidateSelf();
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
      CategoriesNotifier.new,
    );
