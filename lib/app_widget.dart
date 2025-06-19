import 'package:flutter/material.dart';
import 'package:green_urban_connect/core/theme/app_theme.dart';
import 'package:green_urban_connect/core/navigation/app_router.dart';
import 'package:green_urban_connect/presentation/viewmodels/green_resources_viewmodel.dart';
import 'package:green_urban_connect/presentation/viewmodels/initiatives_viewmodel.dart';
import 'package:green_urban_connect/presentation/viewmodels/urban_issue_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:green_urban_connect/presentation/viewmodels/auth_viewmodel.dart';
import 'package:green_urban_connect/core/service/service_locator.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<InitiativesViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<UrbanIssueViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<GreenResourcesViewModel>()),
        // Add other ViewModels here as you create them
      ],
      child: MaterialApp.router(
        title: 'Green Urban Connect',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}