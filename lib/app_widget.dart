import 'package:flutter/material.dart';
import 'package:green_urban_connect/core/theme/app_theme.dart';
import 'package:green_urban_connect/navigation/app_router.dart';
import 'package:green_urban_connect/presentation/viewmodels/initiatives_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:green_urban_connect/presentation/viewmodels/auth_viewmodel.dart';
import 'package:green_urban_connect/core/services/service_locator.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<InitiativesViewModel>()),
        // Add other ViewModels here as you create them
        // ChangeNotifierProvider(create: (_) => sl<DashboardViewModel>()),
      ],
      child: MaterialApp.router(
        title: 'Green Urban Connect',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme, // Optional: if you want a dark theme
        themeMode: ThemeMode.system, // Or ThemeMode.light / ThemeMode.dark
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}