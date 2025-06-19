import 'package:green_urban_connect/data/models/green_resource_model.dart';

abstract class IGreenResourceRepository {
  Future<List<GreenResourceModel>> getGreenResources(double lat, double lon, {List<GreenResourceType>? typesToFetch});
  Future<GreenResourceModel?> getGreenResourceById(String id, GreenResourceSource source); // Perlu sumber untuk tahu cara mengambil detail
}