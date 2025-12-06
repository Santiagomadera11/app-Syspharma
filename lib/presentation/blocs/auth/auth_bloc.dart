import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

// Eventos
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

// Estados
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class Unauthenticated extends AuthState {}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>((event, emit) => emit(Unauthenticated()));
  }

  void _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simular red

    // Lógica Mock: "admin" para Admin, cualquier otro para Empleado
    if (event.username.toLowerCase() == 'admin') {
      emit(const Authenticated( UserEntity(
        id: '1', name: 'Ricardo Torres', email: 'admin@syspharma.com', role: UserRole.admin
      )));
    } else {
      emit(const Authenticated( UserEntity(
        id: '2', name: 'Santiago', email: 'emp@syspharma.com', role: UserRole.employee
      )));
    }
  }
}