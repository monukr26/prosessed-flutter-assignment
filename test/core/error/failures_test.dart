import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/failures.dart';

void main() {
  group('Failures', () {
    test('ServerFailure supports value equality via Equatable', () {
      const failure1 = ServerFailure('Internal error', 500);
      const failure2 = ServerFailure('Internal error', 500);
      const failure3 = ServerFailure('Not found', 404);

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('NetworkFailure provides default user-friendly message', () {
      const failure = NetworkFailure();

      expect(
        failure.message,
        'No internet connection. Please check your network and retry.',
      );
    });
  });
}
