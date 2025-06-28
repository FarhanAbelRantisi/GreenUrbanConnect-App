import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/data_domain/models/initiative_model.dart';
import 'package:green_urban_connect/views/screen/auth/login_screen.dart';
import 'package:green_urban_connect/views/screen/auth/signup_screen.dart';
import 'package:green_urban_connect/views/dashboard_screen.dart';
import 'package:green_urban_connect/views/screen/green%20resources/green_resource_detail_screen.dart';
import 'package:green_urban_connect/views/screen/green%20resources/green_resources_hub_screen.dart';
import 'package:green_urban_connect/views/screen/initiatives/edit_initiative_screen.dart';
import 'package:green_urban_connect/views/screen/initiatives/initiative_detail_screen.dart';
import 'package:green_urban_connect/views/screen/initiatives/initiatives_hub_screen.dart';
import 'package:green_urban_connect/views/screen/initiatives/propose_initiative_screen.dart';
import 'package:green_urban_connect/views/screen/issues/report_issue_screen.dart';
import 'package:green_urban_connect/views/screen/issues/view_issues_screen.dart';
import 'package:green_urban_connect/views/screen/auth/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_urban_connect/data_domain/di/dependency_injection.dart';


class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static String? _authRedirect(BuildContext context, GoRouterState state) {
    final auth = sl<FirebaseAuth>();
    if (auth.currentUser == null) {
      return LoginScreen.routeName;
    }
    return null;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: SplashScreen.routeName,
    routes: [
      GoRoute(
        path: SplashScreen.routeName,
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: LoginScreen.routeName,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: SignupScreen.routeName,
        name: SignupScreen.routeName,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: DashboardScreen.routeName,
        name: DashboardScreen.routeName,
        builder: (context, state) => const DashboardScreen(),
        redirect: _authRedirect,
      ),
      GoRoute(
          path: InitiativesHubScreen.routeName,
          name: InitiativesHubScreen.routeName,
          builder: (context, state) => const InitiativesHubScreen(),
          redirect: _authRedirect,
          routes: [
            GoRoute(
              path: 'propose',
              name: ProposeInitiativeScreen.routeName,
              builder: (context, state) => const ProposeInitiativeScreen(),
            ),
            GoRoute(
              path: '/edit-initiative',
              name: EditInitiativeScreen.routeName,
              builder: (context, state) => EditInitiativeScreen(initiative: state.extra as InitiativeModel),
            ),
            GoRoute(
                path: ':initiativeId',
                name: InitiativeDetailScreen.routeName,
                builder: (context, state) {
                  final initiativeId = state.pathParameters['initiativeId']!;
                  return InitiativeDetailScreen(initiativeId: initiativeId);
                }),
          ]),
      GoRoute(
        path: ReportIssueScreen.routeName,
        name: ReportIssueScreen.routeName,
        builder: (context, state) => const ReportIssueScreen(),
        redirect: _authRedirect,
      ),
      GoRoute(
        path: ViewIssuesScreen.routeName,
        name: ViewIssuesScreen.routeName,
        builder: (context, state) => const ViewIssuesScreen(),
        redirect: _authRedirect,
      ),
      GoRoute(
          path: GreenResourcesHubScreen.routeName,
          name: GreenResourcesHubScreen.routeName,
          builder: (context, state) => const GreenResourcesHubScreen(),
          redirect: _authRedirect,
          routes: [
            GoRoute(
              path: ':resourceId', // e.g., /green-resources/some-id-123
              name: GreenResourceDetailScreen.routeName,
              builder: (context, state) {
                final resourceId = state.pathParameters['resourceId']!;
                return GreenResourceDetailScreen(resourceId: resourceId);
              },
            ),
          ]),
      // Add other routes here
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('Error: ${state.error?.message ?? "Page not found"}'),
      ),
    ),
  );
}