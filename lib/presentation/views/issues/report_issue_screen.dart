import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_urban_connect/data/models/urban_issue_model.dart';
import 'package:green_urban_connect/presentation/viewmodels/urban_issue_viewmodel.dart';
import 'package:green_urban_connect/presentation/widgets/common/custom_button.dart';
import 'package:green_urban_connect/presentation/widgets/common/custom_textfield.dart';
import 'package:green_urban_connect/presentation/widgets/issues/image_upload_widget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class ReportIssueScreen extends StatefulWidget {
  static const routeName = '/report-issue';
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  UrbanIssueCategory _selectedCategory = UrbanIssueCategory.other;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    // It's good practice to clear the picked image in the ViewModel when the screen is disposed
    // if it's not automatically handled by navigation or successful submission.
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if(mounted) {
        Provider.of<UrbanIssueViewModel>(context, listen: false).clearPickedImage();
       }
    });
    super.dispose();
  }

  void _submitForm(UrbanIssueViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      // Location can be more sophisticated (e.g., using geolocator)
      // For now, it's a manual text input.
      final success = await viewModel.addUrbanIssue(
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        location: _locationController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Issue reported successfully!'), backgroundColor: Colors.green),
          );
          context.pop(); // Go back
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? 'Failed to report issue.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final issueViewModel = Provider.of<UrbanIssueViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Urban Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Help improve our city by reporting issues.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Issue Description',
                hintText: 'e.g., Overflowing bin at park entrance',
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please describe the issue' : null,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 16),
              // Category Picker
              DropdownButtonFormField<UrbanIssueCategory>(
                decoration: InputDecoration(
                  labelText: 'Issue Category',
                  prefixIcon: Icon(Icons.category_outlined, color: Theme.of(context).primaryColorLight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                value: _selectedCategory,
                items: UrbanIssueCategory.values.map((UrbanIssueCategory category) {
                  return DropdownMenuItem<UrbanIssueCategory>(
                    value: category,
                    child: Text(category.name.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trimLeft()),
                  );
                }).toList(),
                onChanged: (UrbanIssueCategory? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                labelText: 'Location Details',
                hintText: 'e.g., Near the big oak tree, Central Park',
                validator: (value) => value == null || value.isEmpty ? 'Please provide location details' : null,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              // Image Upload Widget
              ImageUploadWidget(
                pickedImageFile: issueViewModel.pickedImageFile,
                onPickImage: (source) => issueViewModel.pickImage(source),
                onClearImage: () => issueViewModel.clearPickedImage(),
              ),
              const SizedBox(height: 24),
              if (issueViewModel.isUploadingImage)
                const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(children: [CircularProgressIndicator(), SizedBox(height: 8), Text("Uploading image...")]),
                )),
              if (issueViewModel.isSubmitting && !issueViewModel.isUploadingImage)
                const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(children: [CircularProgressIndicator(), SizedBox(height: 8), Text("Submitting issue...")]),
                )),
              if (!issueViewModel.isSubmitting && !issueViewModel.isUploadingImage)
                CustomButton(
                  text: 'Submit Report',
                  onPressed: () => _submitForm(issueViewModel),
                  icon: Icons.send_outlined,
                ),
            ],
          ),
        ),
      ),
    );
  }
}