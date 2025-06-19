import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/presentation/viewmodels/auth_viewmodel.dart';
import 'package:green_urban_connect/presentation/views/auth/login_screen.dart';
import 'package:green_urban_connect/presentation/views/dashboard_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Give some time for Firebase to initialize and auth state to be clear
    await Future.delayed(const Duration(seconds: 2));
    
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    // Listen to the auth state stream to determine navigation
    // This ensures we react to auth changes correctly
    authViewModel.userStream.listen((user) {
      if (mounted) { // Check if the widget is still in the tree
        if (user != null) {
          context.go(DashboardScreen.routeName);
        } else {
          context.go(LoginScreen.routeName);
        }
      }
    }).onError((error) {
      if (mounted) {
        // Handle error, perhaps navigate to login or show an error message
        print("Error in auth stream: $error");
        context.go(LoginScreen.routeName);
      }
    });

    // Initial check, in case the stream takes a moment
    if (authViewModel.currentUser != null && mounted) {
      context.go(DashboardScreen.routeName);
    } else if (mounted && authViewModel.currentUser == null && !authViewModel.isLoading) {
      // If not loading and no user, go to login.
      // This handles the case where the stream might not have emitted yet but initial check is done.
      // However, the stream listener above is the more robust way.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 100, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text(
              'Green Urban Connect',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).primaryColor
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}