import 'package:shopsphere/features/products/domain/entities/category.dart';

/// Data Transfer Object for [Category] entity.
class CategoryModel extends Category {
  const CategoryModel({required super.slug, required super.name, super.url});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final slug = json['slug'] as String? ?? '';
    final name = json['name'] as String? ?? _formatSlug(slug);
    final url = json['url'] as String?;

    return CategoryModel(slug: slug, name: name, url: url);
  }

  /// Parses either Map or string items returned by DummyJSON category endpoints.
  factory CategoryModel.fromDynamic(dynamic item) {
    if (item is Map<String, dynamic>) {
      return CategoryModel.fromJson(item);
    } else if (item is String) {
      return CategoryModel(slug: item, name: _formatSlug(item));
    }
    return const CategoryModel(slug: '', name: '');
  }

  static String _formatSlug(String slug) {
    if (slug.isEmpty) return '';
    final words = slug.split('-');
    return words
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Map<String, dynamic> toJson() {
    return {'slug': slug, 'name': name, if (url != null) 'url': url};
  }
}
