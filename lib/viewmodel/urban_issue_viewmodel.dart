import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_urban_connect/data_domain/models/urban_issue_model.dart';
import 'package:green_urban_connect/data_domain/usecases/urban_issue_usecases.dart';
import 'package:green_urban_connect/viewmodel/auth_viewmodel.dart';
import 'package:image_picker/image_picker.dart'; // For XFile

enum UrbanIssuePageStatus { initial, loading, loaded, error, submitting, submitted, uploadingImage }

class UrbanIssueViewModel extends ChangeNotifier {
  final GetUrbanIssuesUseCase _getUrbanIssuesUseCase;
  final AddUrbanIssueUseCase _addUrbanIssueUseCase;
  final UploadIssueImageUseCase _uploadIssueImageUseCase; // For image upload
  final AuthViewModel _authViewModel;

  UrbanIssueViewModel({
    required GetUrbanIssuesUseCase getUrbanIssuesUseCase,
    required AddUrbanIssueUseCase addUrbanIssueUseCase,
    required UploadIssueImageUseCase uploadIssueImageUseCase,
    required AuthViewModel authViewModel,
  })  : _getUrbanIssuesUseCase = getUrbanIssuesUseCase,
        _addUrbanIssueUseCase = addUrbanIssueUseCase,
        _uploadIssueImageUseCase = uploadIssueImageUseCase,
        _authViewModel = authViewModel {
    fetchUrbanIssues();
  }

  UrbanIssuePageStatus _status = UrbanIssuePageStatus.initial;
  List<UrbanIssueModel> _issues = [];
  String? _errorMessage;
  File? _pickedImageFile; // To hold the picked image file

  UrbanIssuePageStatus get status => _status;
  List<UrbanIssueModel> get issues => _issues;
  String? get errorMessage => _errorMessage;
  File? get pickedImageFile => _pickedImageFile;

  bool get isLoading => _status == UrbanIssuePageStatus.loading;
  bool get isSubmitting => _status == UrbanIssuePageStatus.submitting;
  bool get isUploadingImage => _status == UrbanIssuePageStatus.uploadingImage;


  Future<void> fetchUrbanIssues() async {
    _status = UrbanIssuePageStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _issues = await _getUrbanIssuesUseCase();
      _status = UrbanIssuePageStatus.loaded;
    } catch (e) {
      _status = UrbanIssuePageStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedXFile = await picker.pickImage(source: source, imageQuality: 70, maxWidth: 1024);
      if (pickedXFile != null) {
        _pickedImageFile = File(pickedXFile.path);
        // Optionally, you could trigger AI classification here if _pickedImageFile is set
        // await _classifyImage(_pickedImageFile!);
      } else {
        _pickedImageFile = null; // User cancelled picker
      }
    } catch (e) {
      _errorMessage = "Failed to pick image: $e";
      _pickedImageFile = null;
    }
    notifyListeners(); // Update UI to show picked image or error
  }

  void clearPickedImage() {
    _pickedImageFile = null;
    notifyListeners();
  }

  // Placeholder for AI classification
  // Future<void> _classifyImage(File imageFile) async {
  //   // This is where you would integrate your AI model (on-device or cloud)
  //   // For now, it's a placeholder.
  //   print("AI Classification would happen here for image: ${imageFile.path}");
  //   // Example:
  //   // final classificationResult = await _aiModelService.classify(imageFile);
  //   // _aiSuggestedCategory = classificationResult.category;
  //   // _aiConfidence = classificationResult.confidence;
  //   // notifyListeners();
  // }

  Future<bool> addUrbanIssue({
    required String description,
    required UrbanIssueCategory category,
    required String location,
    // aiSuggestedCategory and aiConfidence can be added if AI is implemented
  }) async {
    _status = UrbanIssuePageStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    final currentUser = _authViewModel.currentUser;
    if (currentUser == null) {
      _status = UrbanIssuePageStatus.error;
      _errorMessage = "User not authenticated. Please log in to report an issue.";
      notifyListeners();
      return false;
    }

    // Create the issue model without the image URL first
    UrbanIssueModel issueToSubmit = UrbanIssueModel(
      description: description,
      category: category,
      location: location,
      reporterId: currentUser.id,
      reporterName: currentUser.displayName ?? currentUser.email,
      // imageFile is handled by the repository if present
    );

    try {
      // The repository will handle image upload if _pickedImageFile is present
      await _addUrbanIssueUseCase(issueToSubmit, imageFile: _pickedImageFile);
      
      _status = UrbanIssuePageStatus.submitted;
      _pickedImageFile = null; // Clear image after successful submission
      await fetchUrbanIssues(); // Refresh the list of issues
      notifyListeners();
      return true;
    } catch (e) {
      _status = UrbanIssuePageStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}