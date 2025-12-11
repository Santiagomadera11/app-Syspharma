import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// IMPORTS NUEVOS PARA EL IDIOMA
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; 

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/routes/app_router.dart';
import 'core/constants/app_colors.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  

  await initializeDateFormatting();

  runApp(const SysPharmaApp());
}

class SysPharmaApp extends StatelessWidget {
  const SysPharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
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
    final authBloc = context.read<AuthBloc>();
    final router = createRouter(authBloc);

    return MaterialApp.router(
      title: 'SysPharma',
      debugShowCheckedModeBanner: false,
      

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), 
      ],
      locale: const Locale('es'), 

      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(), 
        scaffoldBackgroundColor: AppColors.background,
      ),
      routerConfig: router,
    );
  }
}