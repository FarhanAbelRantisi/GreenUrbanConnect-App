import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/viewmodel/auth_viewmodel.dart';
import 'package:green_urban_connect/views/screen/auth/login_screen.dart';
import 'package:green_urban_connect/views/screen/green%20resources/green_resources_hub_screen.dart';
import 'package:green_urban_connect/views/screen/initiatives/initiatives_hub_screen.dart';
import 'package:green_urban_connect/views/screen/issues/report_issue_screen.dart';
import 'package:green_urban_connect/views/screen/issues/view_issues_screen.dart';
import 'package:green_urban_connect/views/widgets/common/custom_button.dart';
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
            CustomButton(
              text: 'Report Urban Issue',
              onPressed: () {
                context.push(ReportIssueScreen.routeName);
              },
              icon: Icons.report_problem_outlined,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'View Reported Issues',
              onPressed: () {
                context.push(ViewIssuesScreen.routeName);
              },
              icon: Icons.list_alt_outlined,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Find Green Spaces & Resources',
              onPressed: () {
                context.push(GreenResourcesHubScreen.routeName);
              },
              icon: Icons.park_outlined,
            ),
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