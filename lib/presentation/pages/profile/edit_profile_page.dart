import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: "Jairo Sanchez");
    final emailController = TextEditingController(text: "admin@syspharma.com");
    final phoneController = TextEditingController(text: "+57 300 123 4567");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Editar Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/man_pharmacist.png'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.grey.shade200, width: 3),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18.sp),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 30.h),

            _buildLabel("Nombre Completo"),
            _buildInput(nameController),
            SizedBox(height: 20.h),

            _buildLabel("Correo Electrónico"),
            _buildInput(emailController),
            SizedBox(height: 20.h),

            _buildLabel("Teléfono"),
            _buildInput(phoneController),

            SizedBox(height: 40.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Perfil actualizado correctamente")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text(text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      ),
    );
  }
}