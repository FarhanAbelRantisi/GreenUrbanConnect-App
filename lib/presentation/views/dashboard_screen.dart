import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/presentation/viewmodels/auth_viewmodel.dart';
import 'package:green_urban_connect/presentation/views/auth/login_screen.dart';
import 'package:green_urban_connect/presentation/views/initiatives/initiatives_hub_screen.dart';
import 'package:green_urban_connect/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.signOut();
              if (context.mounted) {
                context.go(LoginScreen.routeName);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome, ${user?.displayName ?? user?.email ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Explore and contribute to a greener city.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'View Local Initiatives',
              onPressed: () {
                context.push(InitiativesHubScreen.routeName);
              },
              icon: Icons.eco_outlined,
            ),
            const SizedBox(height: 16),
            // Add more buttons for other features here
            // CustomButton(
            //   text: 'Report Urban Issue',
            //   onPressed: () { /* Navigate to Report Issue Screen */ },
            //   icon: Icons.report_problem_outlined,
            // ),
            // const SizedBox(height: 16),
            // CustomButton(
            //   text: 'Find Green Spaces',
            //   onPressed: () { /* Navigate to Green Spaces Screen */ },
            //   icon: Icons.park_outlined,
            // ),
            const Expanded(
              child: Center(
                child: Text(
                  'More features coming soon!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}