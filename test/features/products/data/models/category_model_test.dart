import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    test('correctly parses category object from DummyJSON', () {
      const json = {
        'slug': 'smartphones',
        'name': 'Smartphones',
        'url': 'https://dummyjson.com/products/category/smartphones',
      };

      final model = CategoryModel.fromJson(json);

      expect(model.slug, equals('smartphones'));
      expect(model.name, equals('Smartphones'));
      expect(
        model.url,
        equals('https://dummyjson.com/products/category/smartphones'),
      );
    });

    test(
      'correctly parses category string and formats human-readable name',
      () {
        final model = CategoryModel.fromDynamic('home-decoration');

        expect(model.slug, equals('home-decoration'));
        expect(model.name, equals('Home Decoration'));
      },
    );
  });
}
