import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:okanehoshi/core/network/api_exceptions.dart';
import 'package:okanehoshi/core/network/session_expired_event.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<void> _sessionExpiredSubscription;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);

    _sessionExpiredSubscription = SessionExpiredEvent.stream.listen((_) {
      add(SessionExpired());
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        emit(Unauthenticated());
        return;
      }

      final response = await _authRepository.getProfile();
      if (response.success && response.data != null) {
        emit(Authenticated(response.data!));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (response.success && response.data != null) {
        emit(Authenticated(response.data!));
      } else {
        emit(AuthFailure(response.message ?? 'Login gagal.'));
      }
    } on ValidationException catch (e) {
      emit(AuthFailure(e.message, errors: e.errors));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Terjadi kesalahan tidak terduga: $e'));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );

      if (response.success && response.data != null) {
        emit(Authenticated(response.data!));
      } else {
        emit(AuthFailure(response.message ?? 'Registrasi gagal.'));
      }
    } on ValidationException catch (e) {
      emit(AuthFailure(e.message, errors: e.errors));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Terjadi kesalahan tidak terduga: $e'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
    } catch (_) {
      // Even if network logout fails, local state is cleaned up
    } finally {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSessionExpired(SessionExpired event, Emitter<AuthState> emit) async {
    await _authRepository.deleteToken();
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _sessionExpiredSubscription.cancel();
    return super.close();
  }
}
