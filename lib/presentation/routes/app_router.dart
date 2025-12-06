import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Imports corregidos según tu estructura de carpetas:
import '../blocs/auth/auth_bloc.dart';
import '../pages/appointments/appointments_page.dart';
import '../pages/dashboard/dashboard_page.dart';
// Nota cómo ahora entramos a la carpeta específica de cada página:
import '../pages/login/login_page.dart';
import '../pages/products/products_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/reports/reports_page.dart';
import '../widgets/scaffold_with_navbar.dart';
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: StreamListenable(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggingIn = state.uri.toString() == '/login';

      if (authState is! Authenticated && !isLoggingIn) return '/login';
      if (authState is Authenticated && isLoggingIn) return '/';
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // ShellRoute mantiene la BottomNavigationBar
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
          GoRoute(path: '/products', builder: (context, state) => const ProductsPage()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsPage()),
          GoRoute(path: '/appointments', builder: (context, state) => const AppointmentsPage()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
        ],
      ),
    ],
  );
}

// Clase auxiliar para escuchar el Stream del Bloc en GoRouter
class StreamListenable extends ChangeNotifier {
  final Stream stream;
  StreamListenable(this.stream) {
    stream.listen((_) => notifyListeners());
  }
}