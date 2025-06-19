import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';
import 'package:green_urban_connect/data_domain/repositories/green_resource_repository.dart';

class GetGreenResourcesUseCase {
  final IGreenResourceRepository repository;
  GetGreenResourcesUseCase(this.repository);

  Future<List<GreenResourceModel>> call(double lat, double lon, {List<GreenResourceType>? typesToFetch}) {
    return repository.getGreenResources(lat, lon, typesToFetch: typesToFetch);
  }
}

class GetGreenResourceByIdUseCase {
  final IGreenResourceRepository repository;
  GetGreenResourceByIdUseCase(this.repository);

  Future<GreenResourceModel?> call(String id, GreenResourceSource source) {
    return repository.getGreenResourceById(id, source);
  }
}