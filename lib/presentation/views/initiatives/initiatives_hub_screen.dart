import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/data/models/initiative_model.dart';
import 'package:green_urban_connect/presentation/viewmodels/initiatives_viewmodel.dart';
import 'package:green_urban_connect/presentation/views/initiatives/initiative_detail_screen.dart';
import 'package:green_urban_connect/presentation/views/initiatives/propose_initiative_screen.dart';
import 'package:green_urban_connect/presentation/widgets/initiatives/initiative_list_item.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class InitiativesHubScreen extends StatefulWidget {
  static const routeName = '/initiatives';
  const InitiativesHubScreen({super.key});

  @override
  State<InitiativesHubScreen> createState() => _InitiativesHubScreenState();
}

class _InitiativesHubScreenState extends State<InitiativesHubScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initiatives when the screen is initialized if not already loaded
    // Or you can rely on the ViewModel's constructor to do this.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<InitiativesViewModel>(context, listen: false).fetchInitiatives();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final initiativesViewModel = Provider.of<InitiativesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Initiatives'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => initiativesViewModel.fetchInitiatives(),
            tooltip: 'Refresh Initiatives',
          )
        ],
      ),
      body: _buildBody(initiativesViewModel),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(ProposeInitiativeScreen.routeName);
        },
        icon: const Icon(Icons.add),
        label: const Text('Propose Initiative'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildBody(InitiativesViewModel viewModel) {
    if (viewModel.isLoading && viewModel.initiatives.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.status == InitiativesStatus.error && viewModel.initiatives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${viewModel.errorMessage ?? "Could not load initiatives."}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => viewModel.fetchInitiatives(),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (viewModel.initiatives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No initiatives found yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to propose one!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchInitiatives(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: viewModel.initiatives.length,
        itemBuilder: (context, index) {
          final initiative = viewModel.initiatives[index];
          return InitiativeListItem(
            initiative: initiative,
            onTap: () {
              if (initiative.id != null) {
                 // Ensure the ViewModel clears any previously selected initiative
                //  viewModel.clearSelectedInitiative(); // Or handle in detail screen's initState
                context.pushNamed(
                  InitiativeDetailScreen.routeName,
                  pathParameters: {'initiativeId': initiative.id!},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error: Initiative ID is missing.'))
                );
              }
            },
          );
        },
      ),
    );
  }
}