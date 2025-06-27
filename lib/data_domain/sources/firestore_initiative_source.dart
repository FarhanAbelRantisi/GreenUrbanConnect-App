import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_urban_connect/data_domain/models/initiative_model.dart';

abstract class FirestoreInitiativeSource {
  Future<List<InitiativeModel>> getInitiatives();
  Future<String> addInitiative(InitiativeModel initiative);
  Future<InitiativeModel?> getInitiativeById(String id);
}

class FirestoreInitiativeSourceImpl implements FirestoreInitiativeSource {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'initiatives';

  FirestoreInitiativeSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _initiativesCollection =>
      _firestore.collection(_collectionPath);

  @override
  Future<List<InitiativeModel>> getInitiatives() async {
    try {
      final querySnapshot = await _initiativesCollection
          .orderBy('createdAt', descending: true)
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
      return docRef.id;
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
}