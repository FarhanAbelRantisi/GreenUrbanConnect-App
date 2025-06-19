import 'package:green_urban_connect/data_domain/models/initiative_model.dart';
import 'package:green_urban_connect/data_domain/sources/firestore_initiative_source.dart';

abstract class IInitiativeRepository{
Future<List<InitiativeModel>> getInitiatives();
Future<String> addInitiative(InitiativeModel initiative);
Future<InitiativeModel?> getInitiativeById(String id);
}

class InitiativeRepositoryImpl implements IInitiativeRepository {
  final FirestoreInitiativeSource _firestoreInitiativeSource;

  InitiativeRepositoryImpl(this._firestoreInitiativeSource);

  @override
  Future<List<InitiativeModel>> getInitiatives() {
    return _firestoreInitiativeSource.getInitiatives();
  }

  @override
  Future<String> addInitiative(InitiativeModel initiative) {
    return _firestoreInitiativeSource.addInitiative(initiative);
  }

  @override
  Future<InitiativeModel?> getInitiativeById(String id) {
    return _firestoreInitiativeSource.getInitiativeById(id);
  }

  // Implement update and delete if FirestoreInitiativeSource supports them
  // @override
  // Future<void> updateInitiative(InitiativeModel initiative) {
  //   return _firestoreInitiativeSource.updateInitiative(initiative);
  // }

  // @override
  // Future<void> deleteInitiative(String id) {
  //   return _firestoreInitiativeSource.deleteInitiative(id);
  // }
}