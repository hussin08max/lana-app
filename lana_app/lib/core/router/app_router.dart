import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/agent/presentation/screens/add_case_update_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/cases/presentation/screens/case_details_screen.dart';
import '../../core/shell/main_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/case-details/:id',
      name: 'caseDetails',
      builder: (context, state) {
        final caseId = state.pathParameters['id']!;
        return CaseDetailsScreen(caseId: caseId);
      },
    ),
    GoRoute(
      path: '/add-update/:caseId',
      name: 'addCaseUpdate',
      builder: (context, state) {
        final caseId = state.pathParameters['caseId']!;
        return AddCaseUpdateScreen(caseId: caseId);
      },
    ),
  ],
);
