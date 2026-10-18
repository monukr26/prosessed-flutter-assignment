import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const testUser = User(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    firstName: 'Emily',
    lastName: 'Johnson',
  );

  test('should return User upon successful credentials validation', () async {
    when(
      () => mockRepository.login(username: 'emilys', password: 'emilyspass'),
    ).thenAnswer((_) async => const Result.success(testUser));

    final result = await useCase(username: 'emilys', password: 'emilyspass');

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, equals(testUser));
    verify(
      () => mockRepository.login(username: 'emilys', password: 'emilyspass'),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return AuthFailure when credentials are invalid', () async {
    when(
      () => mockRepository.login(username: 'emilys', password: 'wrongpassword'),
    ).thenAnswer(
      (_) async => const Result.failure(
        AuthFailure('Invalid username or password', 400),
      ),
    );

    final result = await useCase(username: 'emilys', password: 'wrongpassword');

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull,
      equals(const AuthFailure('Invalid username or password', 400)),
    );
    verify(
      () => mockRepository.login(username: 'emilys', password: 'wrongpassword'),
    ).called(1);
  });
}
