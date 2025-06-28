import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/data_domain/models/initiative_model.dart';
import 'package:green_urban_connect/viewmodel/auth_viewmodel.dart';
import 'package:green_urban_connect/viewmodel/initiatives_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class InitiativeDetailScreen extends StatefulWidget {
  static const routeName = 'initiative-detail'; // Used for named routes within a shell
  final String initiativeId;

  const InitiativeDetailScreen({super.key, required this.initiativeId});

  @override
  State<InitiativeDetailScreen> createState() => _InitiativeDetailScreenState();
}

class _InitiativeDetailScreenState extends State<InitiativeDetailScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch the specific initiative details when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InitiativesViewModel>(context, listen: false)
          .fetchInitiativeById(widget.initiativeId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check if the widget is still in the tree
        Provider.of<InitiativesViewModel>(context, listen: false).clearSelectedInitiative();
      }
    });
    super.dispose();
  }


  Widget build(BuildContext context) {
    final initiativesViewModel = Provider.of<InitiativesViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final initiative = initiativesViewModel.selectedInitiative;
    final isOrganizer = initiative != null && authViewModel.currentUser?.id == initiative.organizerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(initiative?.title ?? 'Initiative Details'),
        actions: isOrganizer
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.pushNamed('edit-initiative', extra: initiative);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Initiative'),
                        content: const Text('Are you sure you want to delete this initiative?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      final success = await initiativesViewModel.deleteInitiative(initiative!.id!);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Initiative deleted successfully!'), backgroundColor: Colors.green),
                        );
                        context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(initiativesViewModel.errorMessage ?? 'Failed to delete initiative.'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ]
            : null,
      ),
      body: _buildBody(initiativesViewModel, initiative),
    );
  }

  Widget _buildBody(InitiativesViewModel viewModel, InitiativeModel? initiative) {
    if (viewModel.isLoading && initiative == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.status == InitiativesStatus.error || initiative == null) {
      return Center(
        child: Text(viewModel.errorMessage ?? 'Failed to load initiative details.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (initiative.imageUrl != null && initiative.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                initiative.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (initiative.imageUrl != null && initiative.imageUrl!.isNotEmpty)
            const SizedBox(height: 16),
          Text(
            initiative.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(initiative.categoryDisplay),
                backgroundColor: Theme.of(context).primaryColorLight.withOpacity(0.7),
                labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('Status: ${initiative.status.name}'),
                backgroundColor: Colors.orange[100],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(context, Icons.description_outlined, 'Description', initiative.description),
          _buildDetailRow(context, Icons.location_on_outlined, 'Location', initiative.location),
          _buildDetailRow(context, Icons.calendar_today_outlined, 'Date', DateFormat.yMMMMd().add_jm().format(initiative.date)),
          _buildDetailRow(context, Icons.person_outline, 'Organizer', initiative.organizerName ?? initiative.organizerId),
          _buildDetailRow(context, Icons.group_outlined, 'Participants', initiative.participantIds?.length.toString() ?? '0'),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.eco_outlined),
              label: const Text('Join Initiative / Express Interest'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Join functionality coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}