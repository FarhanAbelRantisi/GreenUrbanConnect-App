import 'package:green_urban_connect/data/models/initiative_model.dart';
import 'package:green_urban_connect/domain/repositories/i_initiative_repository.dart';

class GetInitiativesUseCase {
  final IInitiativeRepository repository;
  GetInitiativesUseCase(this.repository);

  Future<List<InitiativeModel>> call() {
    return repository.getInitiatives();
  }
}

class AddInitiativeUseCase {
  final IInitiativeRepository repository;
  AddInitiativeUseCase(this.repository);

  Future<String> call(InitiativeModel initiative) {
    return repository.addInitiative(initiative);
  }
}

class GetInitiativeByIdUseCase {
  final IInitiativeRepository repository;
  GetInitiativeByIdUseCase(this.repository);

  Future<InitiativeModel?> call(String id) {
    return repository.getInitiativeById(id);
  }
}

// Add use cases for update and delete if needed
// class UpdateInitiativeUseCase { ... }
// class DeleteInitiativeUseCase { ... }