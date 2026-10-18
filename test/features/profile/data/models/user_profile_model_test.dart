import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel Profile JSON Parsing', () {
    const fullProfileJson = {
      'id': 1,
      'firstName': 'Emily',
      'lastName': 'Johnson',
      'username': 'emilys',
      'email': 'emily.johnson@x.dummyjson.com',
      'phone': '+81 965-431-3024',
      'gender': 'female',
      'image': 'https://dummyjson.com/icon/emilys/128',
    };

    test(
      'successfully parses full profile JSON from GET /auth/me including phone and avatar',
      () {
        final user = UserModel.fromJson(fullProfileJson);

        expect(user.id, 1);
        expect(user.firstName, 'Emily');
        expect(user.lastName, 'Johnson');
        expect(user.fullName, 'Emily Johnson');
        expect(user.username, 'emilys');
        expect(user.email, 'emily.johnson@x.dummyjson.com');
        expect(user.phone, '+81 965-431-3024');
        expect(user.gender, 'female');
        expect(user.image, 'https://dummyjson.com/icon/emilys/128');
      },
    );

    test(
      'safely handles missing or null optional fields (phone, image, gender)',
      () {
        const minimalProfileJson = {
          'id': 2,
          'firstName': 'Alex',
          'lastName': 'Rivera',
          'username': 'alexr',
          'email': 'alex@example.com',
          'phone': null,
          'gender': null,
          'image': null,
        };

        final user = UserModel.fromJson(minimalProfileJson);

        expect(user.id, 2);
        expect(user.firstName, 'Alex');
        expect(user.lastName, 'Rivera');
        expect(user.fullName, 'Alex Rivera');
        expect(user.username, 'alexr');
        expect(user.email, 'alex@example.com');
        expect(user.phone, isNull);
        expect(user.gender, isNull);
        expect(user.image, isNull);
      },
    );

    test('converts from domain User entity and serializes back to JSON', () {
      const entity = User(
        id: 3,
        username: 'johndoe',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '+1 555-0199',
        image: 'https://example.com/avatar.jpg',
      );

      final model = UserModel.fromEntity(entity);
      expect(model.id, 3);
      expect(model.phone, '+1 555-0199');
      expect(model.fullName, 'John Doe');

      final json = model.toJson();
      expect(json['id'], 3);
      expect(json['phone'], '+1 555-0199');
      expect(json['username'], 'johndoe');
    });
  });
}
