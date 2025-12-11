import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/user.dart';
import '../blocs/auth/auth_bloc.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {

        UserRole role = UserRole.employee;
        if (state is Authenticated) {
          role = state.user.role;
        }


        int currentIndex = _calculateSelectedIndex(context, role);

        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.all(
                TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              backgroundColor: Colors.white,
              elevation: 10,
              

              onTap: (int index) => _onItemTapped(index, context, role),
              
            
              items: _getNavItems(role),
            ),
          ),
        );
      },
    );
  }


  List<BottomNavigationBarItem> _getNavItems(UserRole role) {

    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Inicio',
      ),
    ];


    if (role == UserRole.admin) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.medication_outlined),
        activeIcon: Icon(Icons.medication),
        label: 'Productos',
      ));
    }

  
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: 'Reportes',
    ));
    
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined),
      activeIcon: Icon(Icons.calendar_month),
      label: 'Citas',
    ));
    
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ));

    return items;
  }


  void _onItemTapped(int index, BuildContext context, UserRole role) {
    if (role == UserRole.admin) {

      switch (index) {
        case 0: context.go('/'); break;             // Inicio
        case 1: context.go('/products'); break;     // Productos
        case 2: context.go('/reports'); break;      // Reportes
        case 3: context.go('/appointments'); break; // Citas
        case 4: context.go('/profile'); break;      // Perfil
      }
    } else {

      switch (index) {
        case 0: context.go('/'); break;             // Inicio

        case 1: context.go('/reports'); break;      
        case 2: context.go('/appointments'); break; // Citas
        case 3: context.go('/profile'); break;      // Perfil
      }
    }
  }


  int _calculateSelectedIndex(BuildContext context, UserRole role) {
    final String location = GoRouterState.of(context).uri.toString();
    
    // Inicio siempre es 0
    if (location == '/' || location == '') return 0;
    
    if (role == UserRole.admin) {
      // Mapeo para Admin
      if (location.startsWith('/products')) return 1;
      if (location.startsWith('/reports')) return 2;
      if (location.startsWith('/appointments')) return 3;
      if (location.startsWith('/profile')) return 4;
    } else {
      // Mapeo para Empleado

      if (location.startsWith('/reports')) return 1;
      if (location.startsWith('/appointments')) return 2;
      if (location.startsWith('/profile')) return 3;
    }
    return 0; // Por defecto
  }
}