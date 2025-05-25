import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/presentation/views/auth/login_screen.dart';
import 'package:green_urban_connect/presentation/views/auth/signup_screen.dart';
import 'package:green_urban_connect/presentation/views/dashboard_screen.dart';
import 'package:green_urban_connect/presentation/views/initiatives/initiative_detail_screen.dart';
import 'package:green_urban_connect/presentation/views/initiatives/initiatives_hub_screen.dart';
import 'package:green_urban_connect/presentation/views/initiatives/propose_initiative_screen.dart';
import 'package:green_urban_connect/presentation/views/splash_screen.dart'; // We'll create this
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_urban_connect/core/services/service_locator.dart';


class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // If you have nested navigation (e.g. for a BottomNavigationBar),
  // you might define shellNavigatorKeys here.

  // Auth redirect logic
  static String? _authRedirect(BuildContext context, GoRouterState state) {
    final auth = sl<FirebaseAuth>();
    if (auth.currentUser == null) {
      // If not logged in, redirect to login, preserving the intended location
      return LoginScreen.routeName;
    }
    // If logged in, allow access
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
        routes: [ // Nested routes for initiative details and proposal
          GoRoute(
            path: 'propose', // e.g., /initiatives/propose
            name: ProposeInitiativeScreen.routeName,
            builder: (context, state) => const ProposeInitiativeScreen(),
          ),
          GoRoute(
            path: ':initiativeId', // e.g., /initiatives/some-id-123
            name: InitiativeDetailScreen.routeName,
            builder: (context, state) {
              final initiativeId = state.pathParameters['initiativeId']!;
              return InitiativeDetailScreen(initiativeId: initiativeId);
            },
          ),
        ]
      ),
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