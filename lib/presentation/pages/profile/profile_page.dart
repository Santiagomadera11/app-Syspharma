import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = "Usuario";
        String email = "usuario@syspharma.com";
        String roleText = "Empleado";
        String imagePath = 'assets/images/man_pharmacist.png'; 

        if (state is Authenticated) {
          name = state.user.name;
          email = state.user.email;
          if (state.user.role == UserRole.admin) {
            roleText = "Administrador";
            imagePath = 'assets/images/man_pharmacist.png';
          } else {
            roleText = "Farmacéutico";
            imagePath = 'assets/images/man_pharmacist.png';
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.go('/'),
            ),
            title: Text(
              "Perfil",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                
                Center(
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Icon(
                          Icons.person,
                          size: 60.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  name,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  roleText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),

                SizedBox(height: 40.h),

                _buildProfileOption(
                  text: "Editar Perfil",
                  onTap: () {
                    context.push('/edit-profile'); // NAVEGACIÓN
                  },
                ),
                
                SizedBox(height: 15.h),
                
                _buildProfileOption(
                  text: "Cambiar Contraseña",
                  onTap: () {
                    context.push('/change-password'); // NAVEGACIÓN
                  },
                ),
                
                SizedBox(height: 15.h),
                
                _buildProfileOption(
                  text: "Cerrar Sesión",
                  isDestructive: true,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    required String text,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive 
              ? Colors.red.withValues(alpha: 0.05) 
              : Colors.grey[100], 
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro que deseas salir de SysPharma?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); 
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text("Salir", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}