import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/models/login_response_model.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';

void main() {
  group('LoginResponseModel', () {
    const jsonMap = {
      'id': 1,
      'username': 'emilys',
      'email': 'emily.johnson@x.dummyjson.com',
      'firstName': 'Emily',
      'lastName': 'Johnson',
      'gender': 'female',
      'image': 'https://dummyjson.com/icon/emilys/128',
      'accessToken': 'test_access_token_xyz',
      'refreshToken': 'test_refresh_token_abc',
    };

    test('should correctly parse full JSON response from DummyJSON', () {
      final model = LoginResponseModel.fromJson(jsonMap);

      expect(model.accessToken, equals('test_access_token_xyz'));
      expect(model.refreshToken, equals('test_refresh_token_abc'));
      expect(model.user.id, equals(1));
      expect(model.user.username, equals('emilys'));
      expect(model.user.email, equals('emily.johnson@x.dummyjson.com'));
      expect(model.user.firstName, equals('Emily'));
      expect(model.user.lastName, equals('Johnson'));
      expect(model.user.fullName, equals('Emily Johnson'));
      expect(model.user.gender, equals('female'));
      expect(model.user.image, equals('https://dummyjson.com/icon/emilys/128'));
    });

    test('should fallback gracefully when nullable fields are absent', () {
      const minimalJson = {
        'id': 2,
        'username': 'minimal_user',
        'email': 'minimal@example.com',
        'firstName': 'Minimal',
        'lastName': 'User',
        'token': 'fallback_token',
      };

      final model = LoginResponseModel.fromJson(minimalJson);

      expect(model.accessToken, equals('fallback_token'));
      expect(model.refreshToken, isEmpty);
      expect(model.user.gender, isNull);
      expect(model.user.image, isNull);
    });

    test('toJson produces expected structure', () {
      final model = LoginResponseModel.fromJson(jsonMap);
      final serialized = model.toJson();

      expect(serialized['accessToken'], equals('test_access_token_xyz'));
      expect(serialized['refreshToken'], equals('test_refresh_token_abc'));
      expect(serialized['username'], equals('emilys'));
    });
  });

  group('UserModel', () {
    test('converts from entity and preserves equality', () {
      const model1 = UserModel(
        id: 1,
        username: 'emilys',
        email: 'emily@example.com',
        firstName: 'Emily',
        lastName: 'Johnson',
      );
      const model2 = UserModel(
        id: 1,
        username: 'emilys',
        email: 'emily@example.com',
        firstName: 'Emily',
        lastName: 'Johnson',
      );

      expect(model1, equals(model2));
    });
  });
}
