import 'package:equatable/equatable.dart';

/// Domain entity representing a product category.
class Category extends Equatable {
  final String slug;
  final String name;
  final String? url;

  const Category({required this.slug, required this.name, this.url});

  @override
  List<Object?> get props => [slug, name, url];
}
