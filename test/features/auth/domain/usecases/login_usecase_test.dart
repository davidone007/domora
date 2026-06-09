import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';
import 'package:domora/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthResult = AuthResult(
    userId: '1',
    email: tEmail,
    role: 'client',
    onboardingCompleted: true,
  );

  test('should return AuthResult when login is successful', () async {
    // arrange
    when(() => mockAuthRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Right(tAuthResult));

    // act
    final result = await useCase(const LoginParams(email: tEmail, password: tPassword));

    // assert
    expect(result, const Right(tAuthResult));
    verify(() => mockAuthRepository.signIn(email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when login fails', () async {
    // arrange
    const tFailure = AuthFailure('Invalid credentials');
    when(() => mockAuthRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await useCase(const LoginParams(email: tEmail, password: tPassword));

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.signIn(email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
