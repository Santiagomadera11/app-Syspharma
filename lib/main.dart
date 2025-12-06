import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';


import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/routes/app_router.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(const SysPharmaApp());
}

class SysPharmaApp extends StatelessWidget {
  const SysPharmaApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Tamaño base (iPhone X)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {

        return BlocProvider(
          create: (context) => AuthBloc(),
          child: const AppView(),
        );
      },
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Obtenemos el Bloc para pasárselo al Router
    final authBloc = context.read<AuthBloc>();
    
    // 4. Creamos la configuración de navegación
    final router = createRouter(authBloc);

    return MaterialApp.router(
      title: 'SysPharma',
      debugShowCheckedModeBanner: false,
      
      // Tema Global
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        // Usamos Google Fonts para que se vea moderno
        textTheme: GoogleFonts.poppinsTextTheme(), 
        scaffoldBackgroundColor: AppColors.background,
      ),
      
      // Conexión con GoRouter
      routerConfig: router,
    );
  }
}