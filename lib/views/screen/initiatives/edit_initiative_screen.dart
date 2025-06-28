import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/data_domain/models/initiative_model.dart';
import 'package:green_urban_connect/viewmodel/initiatives_viewmodel.dart';
import 'package:green_urban_connect/views/widgets/common/custom_button.dart';
import 'package:green_urban_connect/views/widgets/common/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditInitiativeScreen extends StatefulWidget {
  static const routeName = 'edit-initiative';
  final InitiativeModel initiative;

  const EditInitiativeScreen({super.key, required this.initiative});

  @override
  State<EditInitiativeScreen> createState() => _EditInitiativeScreenState();
}

class _EditInitiativeScreenState extends State<EditInitiativeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  File? _selectedImage;
  String? _existingImageUrl;

  DateTime _selectedDate = DateTime.now();
  InitiativeCategory _selectedCategory = InitiativeCategory.other;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initiative.title;
    _descriptionController.text = widget.initiative.description;
    _locationController.text = widget.initiative.location;
    _selectedDate = widget.initiative.date;
    _selectedCategory = widget.initiative.category;
    _existingImageUrl = widget.initiative.imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _existingImageUrl;
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('initiatives/${widget.initiative.organizerId}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(_selectedImage!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return _existingImageUrl;
    }
  }

  void _submitForm(InitiativesViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final updatedInitiative = InitiativeModel(
        id: widget.initiative.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate,
        category: _selectedCategory,
        organizerId: widget.initiative.organizerId,
        organizerName: widget.initiative.organizerName,
        status: widget.initiative.status,
        createdAt: widget.initiative.createdAt,
        imageUrl: await _uploadImage(),
        participantIds: widget.initiative.participantIds,
      );

      final success = await viewModel.updateInitiative(updatedInitiative);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Initiative updated successfully!'), backgroundColor: Colors.green),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to update initiative.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ... Rest of the code similar to ProposeInitiativeScreen for date picker, build method, etc.
  @override
  Widget build(BuildContext context) {
    final initiativesViewModel = Provider.of<InitiativesViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Initiative')),
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
                  : _existingImageUrl != null
                      ? Image.network(_existingImageUrl!, height: 150, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(child: Text('Image not available')),
                        ))
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
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text('Date & Time: ${DateFormat.yMMMMd().add_jm().format(_selectedDate)}'),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () => _pickDate(context),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
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
                    child: Text(category.name.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trimLeft()),
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
                      text: 'Update Initiative',
                      onPressed: () => _submitForm(initiativesViewModel),
                      icon: Icons.update,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != _selectedDate) {
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}