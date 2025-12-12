import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import 'auth_state.dart'; // Asegúrate de importar el state

// Eventos (Se mantienen igual)
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  const LoginRequested(this.username, this.password);
}

class LogoutRequested extends AuthEvent {}

// BLoC (Con lógica de validación)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>((event, emit) => emit(Unauthenticated()));
  }

  void _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    // 1. Validar campos vacíos (Por seguridad extra)
    if (event.username.trim().isEmpty || event.password.trim().isEmpty) {
      emit(const AuthError("Por favor ingrese usuario y contraseña"));
      return;
    }

    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simular carga

    // 2. VALIDACIÓN DE CREDENCIALES REALES
    
    // CASO ADMINISTRADOR (Usuario: admin / Clave: 123)
    if (event.username.trim() == 'admin' && event.password.trim() == '123') {
      emit(const Authenticated(UserEntity(
        id: '1', 
        name: 'Jairo Sanchez', 
        email: 'admin@syspharma.com', 
        role: UserRole.admin
      )));
    } 
    // CASO EMPLEADO (Usuario: santiago / Clave: 123)
    else if (event.username.trim() == 'santiago' && event.password.trim() == '123') {
      emit(const Authenticated(UserEntity(
        id: '2', 
        name: 'Santiago', 
        email: 'empleado@syspharma.com', 
        role: UserRole.employee
      )));
    } 
    // CASO CREDENCIALES INCORRECTAS
    else {
      emit(const AuthError("Usuario o contraseña incorrectos"));
      // Importante: Volver a estado inicial para permitir otro intento
      emit(AuthInitial()); 
    }
  }
}