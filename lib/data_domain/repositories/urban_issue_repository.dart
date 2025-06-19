import 'dart:io';
import 'package:green_urban_connect/data_domain/models/urban_issue_model.dart';
import 'package:green_urban_connect/data_domain/sources/firestore_urban_issue_source.dart';
import 'package:green_urban_connect/data_domain/sources/firebase_storage_source.dart';
import 'package:path/path.dart' as p;

abstract class IUrbanIssueRepository {
  Future<List<UrbanIssueModel>> getUrbanIssues();
  Future<String> addUrbanIssue(UrbanIssueModel issue, {File? imageFile});
  Future<String?> uploadIssueImage(File imageFile, String issueId);
}

class UrbanIssueRepositoryImpl implements IUrbanIssueRepository {
  final FirestoreUrbanIssueSource _firestoreSource;
  final FirebaseStorageSource _storageSource;

  UrbanIssueRepositoryImpl(this._firestoreSource, this._storageSource);

  @override
  Future<List<UrbanIssueModel>> getUrbanIssues() {
    return _firestoreSource.getUrbanIssues();
  }

  @override
  Future<String?> uploadIssueImage(File imageFile, String reporterId) async {
    // Create a unique file name for the image in Firebase Storage.
    // Example: 'issue_images/userId_timestamp.jpg'
    final fileName = '${reporterId}_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
    final filePath = 'issue_images/$fileName';
    try {
      final downloadUrl = await _storageSource.uploadFile(imageFile, filePath);
      return downloadUrl;
    } catch (e) {
      print("Error uploading issue image in repository: $e");
      return null; // Or rethrow the exception
    }
  }


  @override
  Future<String> addUrbanIssue(UrbanIssueModel issue, {File? imageFile}) async {
    String? imageUrl;
    if (imageFile != null) {
      // Upload image first
      final fileName = '${issue.reporterId}_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
      final filePath = 'issue_images/$fileName';
      imageUrl = await _storageSource.uploadFile(imageFile, filePath);
    }

    // Create a new UrbanIssueModel instance with the imageUrl
    final issueWithImage = UrbanIssueModel(
      id: issue.id,
      description: issue.description,
      category: issue.category,
      location: issue.location,
      imageUrl: imageUrl, // Use the uploaded image URL
      reporterId: issue.reporterId,
      reporterName: issue.reporterName,
      status: issue.status,
      reportedAt: issue.reportedAt,
      aiSuggestedCategory: issue.aiSuggestedCategory,
      aiConfidence: issue.aiConfidence,
      // imageFile is not part of this model for Firestore
    );

    return _firestoreSource.addUrbanIssue(issueWithImage);
  }
}