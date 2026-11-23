import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../time/lima_time.dart';
import '../widgets/main_scaffold.dart';
import '../../features/week/week_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/day/day_screen.dart';
import '../../features/editor/editor_screen.dart';
import '../../features/review/review_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Configuración de rutas de Wigt con StatefulShellRoute y GoRouter.
/// Navegación principal de 3 pestañas: Semana · Calendario · Ajustes
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/week',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 1. Rama Semana (inicio de la app)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/week',
              name: 'week',
              builder: (context, state) => const WeekScreen(),
            ),
          ],
        ),
        // 2. Rama Calendario
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              name: 'calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        // 3. Rama Ajustes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Redirección para /today hacia el día actual en Lima
    GoRoute(
      path: '/today',
      redirect: (context, state) => '/day/${LimaTime.todayLima()}',
    ),

    // Rutas directas (en el root navigator para superponerse a la barra)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/day/:date',
      name: 'day',
      builder: (context, state) {
        final date = state.pathParameters['date'] ?? LimaTime.todayLima();
        return DayScreen(date: date);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/editor',
      name: 'editor',
      builder: (context, state) {
        final taskId = state.uri.queryParameters['taskId'];
        final date = state.uri.queryParameters['date'];
        return EditorScreen(taskId: taskId, initialDate: date);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/review/:weekStart',
      name: 'review',
      builder: (context, state) {
        final weekStart = state.pathParameters['weekStart'] ??
            LimaTime.startOfWeek(LimaTime.todayLima());
        return ReviewScreen(weekStart: weekStart);
      },
    ),
  ],
);
