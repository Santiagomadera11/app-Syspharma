import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/api/auth_api.dart';
import 'auth_state.dart';

// Eventos
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();

  @override
  List<Object> get props => [];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApi _authApi;

  AuthBloc({required AuthApi authApi})
      : _authApi = authApi,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    final email = event.email.trim();
    final password = event.password.trim();

    if (email.isEmpty || password.isEmpty) {
      emit(const AuthError('Por favor ingrese correo y contraseña'));
      return;
    }

    emit(AuthLoading());

    try {
      final user = await _authApi.login(email, password);
      emit(Authenticated(user));
    } on AuthException catch (error) {
      emit(AuthError(error.message));
    } catch (e) {
      emit(const AuthError('Error inesperado. Intente de nuevo.'));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = await _authApi.restoreSession();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authApi.logout();
    emit(Unauthenticated());
  }
}