import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Available sorting options for the catalogue.
enum SortOption {
  none(label: 'Default'),
  priceAsc(label: 'Price: Low to High', field: 'price', order: 'asc'),
  priceDesc(label: 'Price: High to Low', field: 'price', order: 'desc'),
  ratingDesc(label: 'Rating: High to Low', field: 'rating', order: 'desc'),
  titleAsc(label: 'Title: A to Z', field: 'title', order: 'asc');

  final String label;
  final String? field;
  final String? order;

  const SortOption({required this.label, this.field, this.order});

  /// Sorts a list of products in-memory.
  ///
  /// This ensures that sorting search and category results works reliably
  /// without discarding active filters even when backend endpoints lack native sorting.
  List<Product> apply(List<Product> list) {
    final copy = List<Product>.from(list);
    switch (this) {
      case SortOption.priceAsc:
        copy.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
        break;
      case SortOption.priceDesc:
        copy.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
        break;
      case SortOption.ratingDesc:
        copy.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.titleAsc:
        copy.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case SortOption.none:
        break;
    }
    return copy;
  }
}
