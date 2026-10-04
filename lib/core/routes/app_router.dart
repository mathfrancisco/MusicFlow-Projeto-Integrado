import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/clients/presentation/client_form_screen.dart';
import '../../features/clients/presentation/client_list_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/projects/presentation/project_details_screen.dart';
import '../../features/projects/presentation/project_form_screen.dart';
import '../../features/projects/presentation/project_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/clients', builder: (_, __) => const ClientListScreen()),
      GoRoute(path: '/clients/new', builder: (_, __) => const ClientFormScreen()),
      GoRoute(path: '/clients/:id/edit', builder: (_, state) => ClientFormScreen(clientId: state.pathParameters['id'])),
      GoRoute(path: '/projects', builder: (_, __) => const ProjectListScreen()),
      GoRoute(path: '/projects/new', builder: (_, state) => ProjectFormScreen(preselectedClientId: state.uri.queryParameters['clientId'])),
      GoRoute(path: '/projects/:id/edit', builder: (_, state) => ProjectFormScreen(projectId: state.pathParameters['id'])),
      GoRoute(path: '/projects/:id', builder: (_, state) => ProjectDetailsScreen(projectId: state.pathParameters['id']!)),
      GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
    ],
  );
});
