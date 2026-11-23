import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';

/// Shell principal con barra de navegación inferior de 3 pestañas:
/// Semana · Calendario · Ajustes
class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outline, width: AppDimens.borderWidth),
          ),
        ),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: NavigationBar(
          height: AppDimens.navBarHeight,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onItemTapped,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.view_week_outlined, color: AppColors.onMuted),
              selectedIcon: Icon(Icons.view_week, color: AppColors.primaryLight),
              label: 'Semana',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: AppColors.onMuted),
              selectedIcon: Icon(Icons.calendar_month, color: AppColors.primaryLight),
              label: 'Calendario',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined, color: AppColors.onMuted),
              selectedIcon: Icon(Icons.tune, color: AppColors.primaryLight),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
