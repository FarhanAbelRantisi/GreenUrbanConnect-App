import 'package:green_urban_connect/data/models/initiative_model.dart';

abstract class IInitiativeRepository {
  Future<List<InitiativeModel>> getInitiatives();
  Future<String> addInitiative(InitiativeModel initiative);
  Future<InitiativeModel?> getInitiativeById(String id);
  // Future<void> updateInitiative(InitiativeModel initiative);
  // Future<void> deleteInitiative(String id);
}