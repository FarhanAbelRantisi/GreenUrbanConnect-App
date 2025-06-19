import 'package:flutter/material.dart';
import 'package:green_urban_connect/data_domain/models/urban_issue_model.dart';
import 'package:green_urban_connect/viewmodel/urban_issue_viewmodel.dart';
import 'package:green_urban_connect/views/widgets/issues/issue_list_item.dart'; // We'll create this
import 'package:provider/provider.dart';

class ViewIssuesScreen extends StatefulWidget {
  static const routeName = '/view-issues';
  const ViewIssuesScreen({super.key});

  @override
  State<ViewIssuesScreen> createState() => _ViewIssuesScreenState();
}

class _ViewIssuesScreenState extends State<ViewIssuesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch issues when the screen is initialized
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<UrbanIssueViewModel>(context, listen: false).fetchUrbanIssues();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final issueViewModel = Provider.of<UrbanIssueViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Urban Issues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => issueViewModel.fetchUrbanIssues(),
            tooltip: 'Refresh Issues',
          ),
        ],
      ),
      body: _buildBody(issueViewModel),
    );
  }

  Widget _buildBody(UrbanIssueViewModel viewModel) {
    if (viewModel.isLoading && viewModel.issues.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.status == UrbanIssuePageStatus.error && viewModel.issues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${viewModel.errorMessage ?? "Could not load issues."}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => viewModel.fetchUrbanIssues(),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (viewModel.issues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No urban issues reported yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to report one if you see something!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchUrbanIssues(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: viewModel.issues.length,
        itemBuilder: (context, index) {
          final issue = viewModel.issues[index];
          return IssueListItem(
            issue: issue,
            onTap: () {
              // TODO: Navigate to Issue Detail Screen if you create one
              // For now, maybe show a dialog with more info.
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(issue.categoryDisplay),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        if (issue.imageUrl != null) 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Image.network(issue.imageUrl!, errorBuilder: (c,e,s) => Text("Could not load image")),
                          ),
                        Text('Description: ${issue.description}'),
                        const SizedBox(height: 8),
                        Text('Location: ${issue.location}'),
                        const SizedBox(height: 8),
                        Text('Status: ${issue.status.name}'),
                        const SizedBox(height: 8),
                        Text('Reported by: ${issue.reporterName ?? 'Anonymous'}'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}