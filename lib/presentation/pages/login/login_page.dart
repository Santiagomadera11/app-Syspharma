import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart'; // Importante importar el state

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    // 1. Usamos BlocListener para escuchar errores y mostrar alertas
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          // Mostrar SnackBar Rojo si hay error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is Authenticated) {
          // Si entra correctamente, GoRouter se encarga, pero podemos mostrar éxito
          ScaffoldMessenger.of(context).clearSnackBars();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60.h),
                
                // LOGO
                SizedBox(
                  height: 120.h,
                  width: 120.w,
                  child: Image.asset(
                    'assets/images/Farmacenter la 10.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Center(
                        child: Icon(Icons.local_pharmacy, size: 60.w, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                Text("Iniciar Sesión", style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 30.h),

                // CAMPO USUARIO
                _buildTextField(controller: _userController, hint: 'Usuario / Correo', icon: null),
                SizedBox(height: 16.h),
                
                // CAMPO CONTRASEÑA
                _buildTextField(controller: _passController, hint: 'Contraseña', isPassword: true),
                SizedBox(height: 10.h),

                // RECORDARME
                Row(
                  children: [
                    SizedBox(
                      height: 24.h,
                      width: 24.w,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _rememberMe = v!),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text("Recordarme", style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
                
                SizedBox(height: 24.h),

                // BOTÓN CON VALIDACIÓN
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      // Si está cargando, mostramos un circulito
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      
                      return ElevatedButton(
                        onPressed: () {
                          // 2. VALIDACIÓN VISUAL: Si los campos están vacíos, no enviamos nada
                          if (_userController.text.isEmpty || _passController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Por favor ingrese usuario y contraseña"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Si hay texto, enviamos al Bloc para verificar credenciales
                          context.read<AuthBloc>().add(
                            LoginRequested(_userController.text, _passController.text)
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: Text("Iniciar Sesión", style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                      );
                    },
                  ),
                ),

                SizedBox(height: 40.h),
                Text("o conecta con", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                SizedBox(height: 20.h),

                // BOTONES REDES SOCIALES
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(FontAwesomeIcons.google, Colors.red),
                    SizedBox(width: 20.w),
                    _socialButton(FontAwesomeIcons.apple, Colors.black),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool isPassword = false, IconData? icon}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF0F5F5), 
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppColors.primary)),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            )
          : null,
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      width: 50.w, 
      height: 50.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,5))]
      ),
      child: Center(child: Icon(icon, color: color)),
    );
  }
}