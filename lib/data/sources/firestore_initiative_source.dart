import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_urban_connect/data/models/initiative_model.dart';

abstract class FirestoreInitiativeSource {
  Future<List<InitiativeModel>> getInitiatives();
  Future<String> addInitiative(InitiativeModel initiative);
  Future<InitiativeModel?> getInitiativeById(String id);
  // Future<void> updateInitiative(InitiativeModel initiative);
  // Future<void> deleteInitiative(String id);
}

class FirestoreInitiativeSourceImpl implements FirestoreInitiativeSource {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'initiatives'; // Name of your Firestore collection

  FirestoreInitiativeSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _initiativesCollection =>
      _firestore.collection(_collectionPath);

  @override
  Future<List<InitiativeModel>> getInitiatives() async {
    try {
      final querySnapshot = await _initiativesCollection
          .orderBy('createdAt', descending: true) // Example: order by creation date
          .get();
      return querySnapshot.docs
          .map((doc) => InitiativeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching initiatives: $e");
      throw Exception("Failed to fetch initiatives.");
    }
  }

  @override
  Future<String> addInitiative(InitiativeModel initiative) async {
    try {
      final docRef = await _initiativesCollection.add(initiative.toFirestore());
      return docRef.id; // Return the ID of the newly created document
    } catch (e) {
      print("Error adding initiative: $e");
      throw Exception("Failed to add initiative.");
    }
  }

  @override
  Future<InitiativeModel?> getInitiativeById(String id) async {
    try {
      final docSnapshot = await _initiativesCollection.doc(id).get();
      if (docSnapshot.exists) {
        return InitiativeModel.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    } catch (e) {
      print("Error fetching initiative by ID ($id): $e");
      throw Exception("Failed to fetch initiative details.");
    }
  }

  // Implement update and delete methods as needed
  // @override
  // Future<void> updateInitiative(InitiativeModel initiative) async {
  //   try {
  //     await _initiativesCollection.doc(initiative.id).update(initiative.toFirestore());
  //   } catch (e) {
  //     print("Error updating initiative: $e");
  //     throw Exception("Failed to update initiative.");
  //   }
  // }

  // @override
  // Future<void> deleteInitiative(String id) async {
  //   try {
  //     await _initiativesCollection.doc(id).delete();
  //   } catch (e) {
  //     print("Error deleting initiative: $e");
  //     throw Exception("Failed to delete initiative.");
  //   }
  // }
}