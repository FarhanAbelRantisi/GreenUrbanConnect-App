import 'dart:io';
import 'package:green_urban_connect/data/models/urban_issue_model.dart';
import 'package:green_urban_connect/domain/repositories/i_urban_issue_repository.dart';

class GetUrbanIssuesUseCase {
  final IUrbanIssueRepository repository;
  GetUrbanIssuesUseCase(this.repository);

  Future<List<UrbanIssueModel>> call() {
    return repository.getUrbanIssues();
  }
}

class AddUrbanIssueUseCase {
  final IUrbanIssueRepository repository;
  AddUrbanIssueUseCase(this.repository);

  Future<String> call(UrbanIssueModel issue, {File? imageFile}) {
    return repository.addUrbanIssue(issue, imageFile: imageFile);
  }
}

class UploadIssueImageUseCase {
  final IUrbanIssueRepository repository;
  UploadIssueImageUseCase(this.repository);

  Future<String?> call(File imageFile, String reporterId) {
    return repository.uploadIssueImage(imageFile, reporterId);
  }
}

// Potentially add AI related use cases later
// class ClassifyIssueImageUseCase { ... }