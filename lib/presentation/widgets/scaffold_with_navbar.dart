import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/user.dart'; // OJO: Asegúrate que este path sea correcto hacia tu entidad User
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

        return Scaffold(
          body: child,
          bottomNavigationBar: _buildBottomNav(context, role),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context, UserRole role) {
    int currentIndex = _calculateSelectedIndex(context, role);
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (int index) => _onItemTapped(index, context, role),
      items: _getNavItems(role),
    );
  }

  List<BottomNavigationBarItem> _getNavItems(UserRole role) {
    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
    ];

    if (role == UserRole.admin) {
      items.add(const BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), label: 'Productos'));
    }
    
    items.add(const BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Reportes'));
    items.add(const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Citas'));
    items.add(const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'));

    return items;
  }

  void _onItemTapped(int index, BuildContext context, UserRole role) {
    if (role == UserRole.admin) {
      switch (index) {
        case 0: context.go('/'); break;
        case 1: context.go('/products'); break;
        case 2: context.go('/reports'); break;
        case 3: context.go('/appointments'); break;
        case 4: context.go('/profile'); break;
      }
    } else {
      switch (index) {
        case 0: context.go('/'); break;
        case 1: context.go('/reports'); break;
        case 2: context.go('/appointments'); break;
        case 3: context.go('/profile'); break;
      }
    }
  }

  int _calculateSelectedIndex(BuildContext context, UserRole role) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == '/') return 0;
    
    if (role == UserRole.admin) {
      if (location.startsWith('/products')) return 1;
      if (location.startsWith('/reports')) return 2;
      if (location.startsWith('/appointments')) return 3;
      if (location.startsWith('/profile')) return 4;
    } else {
      if (location.startsWith('/reports')) return 1;
      if (location.startsWith('/appointments')) return 2;
      if (location.startsWith('/profile')) return 3;
    }
    return 0;
  }
}