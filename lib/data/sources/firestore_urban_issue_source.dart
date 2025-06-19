import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_urban_connect/data/models/urban_issue_model.dart';

abstract class FirestoreUrbanIssueSource {
  Future<List<UrbanIssueModel>> getUrbanIssues();
  Future<String> addUrbanIssue(UrbanIssueModel issue);
  // Future<UrbanIssueModel?> getUrbanIssueById(String id);
  // Future<void> updateUrbanIssue(UrbanIssueModel issue);
}

class FirestoreUrbanIssueSourceImpl implements FirestoreUrbanIssueSource {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'urban_issues'; // Name of your Firestore collection

  FirestoreUrbanIssueSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _issuesCollection =>
      _firestore.collection(_collectionPath);

  @override
  Future<List<UrbanIssueModel>> getUrbanIssues() async {
    try {
      final querySnapshot = await _issuesCollection
          .orderBy('reportedAt', descending: true) // Order by report date
          .get();
      return querySnapshot.docs
          .map((doc) => UrbanIssueModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching urban issues: $e");
      throw Exception("Failed to fetch urban issues.");
    }
  }

  @override
  Future<String> addUrbanIssue(UrbanIssueModel issue) async {
    try {
      // Ensure imageFile is not part of the data sent to Firestore
      final dataToSave = issue.toFirestore();
      final docRef = await _issuesCollection.add(dataToSave);
      return docRef.id; // Return the ID of the newly created document
    } catch (e) {
      print("Error adding urban issue: $e");
      throw Exception("Failed to add urban issue.");
    }
  }
}