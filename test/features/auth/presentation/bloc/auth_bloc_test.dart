import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:okanehoshi/core/models/base_response.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import 'package:okanehoshi/features/auth/domain/entities/user.dart';
import 'package:okanehoshi/features/auth/domain/repositories/auth_repository.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_event.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  final dummyUser = User(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    phone: '08123456789',
    balance: 100000,
    createdAt: DateTime.parse('2026-06-04T00:00:00Z'),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  group('AppStarted', () {
    test('emits [Unauthenticated] when no token is stored', () async {
      when(() => mockAuthRepository.getToken()).thenAnswer((_) async => null);

      final expectedStates = [
        isA<Unauthenticated>(),
      ];

      final future = expectLater(authBloc.stream, emitsInOrder(expectedStates));
      authBloc.add(AppStarted());
      await future;
    });

    test('emits [Authenticated] when token is valid and profile fetch is successful', () async {
      when(() => mockAuthRepository.getToken()).thenAnswer((_) async => 'valid_token');
      when(() => mockAuthRepository.getProfile()).thenAnswer(
        (_) async => BaseResponse<User>(
          success: true,
          message: 'Berhasil',
          data: dummyUser,
        ),
      );

      final expectedStates = [
        isA<Authenticated>().having((s) => s.user, 'user', dummyUser),
      ];

      final future = expectLater(authBloc.stream, emitsInOrder(expectedStates));
      authBloc.add(AppStarted());
      await future;
    });

    test('emits [Unauthenticated] when profile fetch fails', () async {
      when(() => mockAuthRepository.getToken()).thenAnswer((_) async => 'invalid_token');
      when(() => mockAuthRepository.getProfile()).thenThrow(UnauthorizedException());

      final expectedStates = [
        isA<Unauthenticated>(),
      ];

      final future = expectLater(authBloc.stream, emitsInOrder(expectedStates));
      authBloc.add(AppStarted());
      await future;
    });
  });

  group('LoginSubmitted', () {
    const email = 'test@example.com';
    const password = 'password';

    test('emits [AuthLoading, Authenticated] when login is successful', () async {
      when(() => mockAuthRepository.login(email: email, password: password)).thenAnswer(
        (_) async => BaseResponse<User>(
          success: true,
          message: 'Login Berhasil',
          data: dummyUser,
        ),
      );

      final expectedStates = [
        isA<AuthLoading>(),
        isA<Authenticated>().having((s) => s.user, 'user', dummyUser),
      ];

      final future = expectLater(authBloc.stream, emitsInOrder(expectedStates));
      authBloc.add(const LoginSubmitted(email: email, password: password));
      await future;
    });

    test('emits [AuthLoading, AuthFailure] when repository returns success=false', () async {
      when(() => mockAuthRepository.login(email: email, password: password)).thenAnswer(
        (_) async => BaseResponse<User>(
          success: false,
          message: 'Email atau password salah',
        ),
      );

      final expectedStates = [
        isA<AuthLoading>(),
        isA<AuthFailure>().having((s) => s.message, 'message', 'Email atau password salah'),
      ];

      final future = expectLater(authBloc.stream, emitsInOrder(expectedStates));
      authBloc.add(const LoginSubmitted(email: email, password: password));
      await future;
    });

    test('emits [AuthLoading, AuthFailure] with errors validation on ValidationException', () async {
      final validationErrors = {
        'email': ['Format email tidak valid']
      };
      when(() => mockAuthRepository.login(email: email, password: password)).thenThrow(
        ValidationException(validationErrors, 'Data tidak valid'),
      );

      final expectedStates = [
        isA<AuthLoading>(),
        isA<AuthFailure>()
            .having((s) => s.message, 'message', 'Data tidak valid')
            .having((s) => s.errors, 'errors', validationErrors),
      ];

      final future = expectLater(authBloc.stream, emitsInOrder(expectedStates));
      authBloc.add(const LoginSubmitted(email: email, password: password));
      await future;
    });
  });

  group('RegisterSubmitted', () {
    const name = 'Test User';
    const email = 'test@example.com';
    const phone = '08123456789';
    const password = 'password';
    const passwordConfirmation = 'password';

    test('emits [AuthLoading, Authenticated] when registration is successful', () async {
      when(() => mockAuthRepository.register(
            name: name,
            email: email,
            phone: phone,
            password: password,
            passwordConfirmation: passwordConfirmation,
          )).thenAnswer(
        (_) async => BaseResponse<User>(
          success: true,
          message: 'Registrasi Berhasil',
          data: dummyUser,
        ),
      );

      final expectedStates = [
        isA<AuthLoading>(),
        isA<Authenticated>().having((s) => s.user, 'user', dummyUser),
      ];

      final future = expectLater(authBloc.stream, emitsInOrder(expectedStates));
      authBloc.add(const RegisterSubmitted(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ));
      await future;
    });
  });

  group('LogoutRequested', () {
    test('emits [AuthLoading, Unauthenticated] and deletes token', () async {
      when(() => mockAuthRepository.logout()).thenAnswer(
        (_) async => BaseResponse<void>(success: true, message: 'Logout Berhasil'),
      );

      final expectedStates = [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ];

      final future = expectLater(authBloc.stream, emitsInOrder(expectedStates));
      authBloc.add(LogoutRequested());
      await future;
    });
  });

  group('SessionExpired', () {
    test('emits [Unauthenticated] and deletes token locally', () async {
      when(() => mockAuthRepository.deleteToken()).thenAnswer((_) async {});

      final expectedStates = [
        isA<Unauthenticated>(),
      ];

      final future = expectLater(authBloc.stream, emitsInOrder(expectedStates));
      authBloc.add(SessionExpired());
      await future;

      verify(() => mockAuthRepository.deleteToken()).called(1);
    });
  });
}
