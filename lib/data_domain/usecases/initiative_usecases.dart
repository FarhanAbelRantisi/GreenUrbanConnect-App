import 'package:green_urban_connect/data_domain/models/initiative_model.dart';
import 'package:green_urban_connect/data_domain/repositories/initiative_repository.dart';

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

class UpdateInitiativeUseCase {
  final IInitiativeRepository repository;
  UpdateInitiativeUseCase(this.repository);

  Future<void> call(InitiativeModel initiative) {
    return repository.updateInitiative(initiative);
  }
}

class DeleteInitiativeUseCase {
  final IInitiativeRepository repository;
  DeleteInitiativeUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteInitiative(id);
  }
}