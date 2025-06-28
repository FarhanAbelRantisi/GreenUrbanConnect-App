import 'package:flutter/material.dart';
import 'package:green_urban_connect/data_domain/models/initiative_model.dart';
import 'package:green_urban_connect/viewmodel/initiatives_viewmodel.dart';
import 'package:green_urban_connect/views/widgets/common/custom_button.dart';
import 'package:green_urban_connect/views/widgets/common/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProposeInitiativeScreen extends StatefulWidget {
  static const routeName = 'propose-initiative';
  const ProposeInitiativeScreen({super.key});

  @override
  State<ProposeInitiativeScreen> createState() => _ProposeInitiativeScreenState();
}

class _ProposeInitiativeScreenState extends State<ProposeInitiativeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  InitiativeCategory _selectedCategory = InitiativeCategory.other;

  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(InitiativeModel initiative) async {
    if (_selectedImage == null) return null;
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('initiatives/${initiative.organizerId}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(_selectedImage!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != _selectedDate) {
      // Combine with time if needed, or just use the date
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm(InitiativesViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final newInitiative = InitiativeModel(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate,
        category: _selectedCategory,
        organizerId: '', // Will be set in ViewModel
      );

      final imageUrl = await _uploadImage(newInitiative);
      final initiativeWithImage = InitiativeModel(
        title: newInitiative.title,
        description: newInitiative.description,
        location: newInitiative.location,
        date: newInitiative.date,
        category: newInitiative.category,
        organizerId: newInitiative.organizerId,
        imageUrl: imageUrl,
      );

      final success = await viewModel.addInitiative(initiativeWithImage);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Initiative proposed successfully!'), backgroundColor: Colors.green),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to propose initiative.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initiativesViewModel = Provider.of<InitiativesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Propose New Initiative'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomTextField(
                controller: _titleController,
                labelText: 'Initiative Title',
                hintText: 'e.g., Community Park Clean-up',
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Detailed information about the initiative',
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                labelText: 'Location',
                hintText: 'e.g., Central Park, Main Street',
                validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
                prefixIcon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 16),

              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150, fit: BoxFit.cover)
                  : Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(child: Text('No image selected')),
                    ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.image_outlined),
                label: const Text('Pick Image from Gallery'),
                onPressed: _pickImage,
              ),

              const SizedBox(height: 16),
              
              // Date Picker
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text('Date & Time: ${DateFormat.yMMMMd().add_jm().format(_selectedDate)}'),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () => _pickDate(context),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              // Category Picker
              DropdownButtonFormField<InitiativeCategory>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined, color: Theme.of(context).primaryColorLight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                value: _selectedCategory,
                items: InitiativeCategory.values.map((InitiativeCategory category) {
                  return DropdownMenuItem<InitiativeCategory>(
                    value: category,
                    child: Text(category.name.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trimLeft()), // Format name
                  );
                }).toList(),
                onChanged: (InitiativeCategory? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 24),
              initiativesViewModel.isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Submit Proposal',
                      onPressed: () => _submitForm(initiativesViewModel),
                      icon: Icons.send_outlined,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}