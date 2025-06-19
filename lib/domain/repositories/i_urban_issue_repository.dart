import 'dart:io';
import 'package:green_urban_connect/data/models/urban_issue_model.dart';

abstract class IUrbanIssueRepository {
  Future<List<UrbanIssueModel>> getUrbanIssues();
  Future<String> addUrbanIssue(UrbanIssueModel issue, {File? imageFile});
  Future<String?> uploadIssueImage(File imageFile, String issueId);
}