import 'package:green_urban_connect/data/models/initiative_model.dart';
import 'package:green_urban_connect/data/sources/firestore_initiative_source.dart';
import 'package:green_urban_connect/domain/repositories/i_initiative_repository.dart';

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