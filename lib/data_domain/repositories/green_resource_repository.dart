// lib/data_domain/repositories/green_resource_repository.dart
import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';
import 'package:green_urban_connect/data_domain/sources/api/open_charge_map_api_source.dart';
import 'package:green_urban_connect/data_domain/sources/api/overpass_api_source.dart';
import 'package:green_urban_connect/data_domain/sources/api/transport_api_source_placeholder.dart';

abstract class IGreenResourceRepository {
  Future<List<GreenResourceModel>> getGreenResources(double lat, double lon, {List<GreenResourceType>? typesToFetch});
  Future<GreenResourceModel?> getGreenResourceById(String id, GreenResourceSource source);
}

class GreenResourceRepositoryImpl implements IGreenResourceRepository {
  final OverpassApiSource _overpassApiSource;
  final OpenChargeMapApiSource _openChargeMapApiSource;
  final TransportApiSource _transportApiSource;

  GreenResourceRepositoryImpl({
    required OverpassApiSource overpassApiSource,
    required OpenChargeMapApiSource openChargeMapApiSource,
    required TransportApiSource transportApiSource,
  })  : _overpassApiSource = overpassApiSource,
        _openChargeMapApiSource = openChargeMapApiSource,
        _transportApiSource = transportApiSource;

  @override
  Future<List<GreenResourceModel>> getGreenResources(double lat, double lon, {List<GreenResourceType>? typesToFetch}) async {
    final List<GreenResourceModel> allResources = [];
    final fetchAll = typesToFetch == null || typesToFetch.isEmpty;
    final errors = <String>[];

    try {
      if (fetchAll || typesToFetch!.contains(GreenResourceType.park) || typesToFetch.contains(GreenResourceType.communityGarden)) {
        try {
          final greenSpaces = await _overpassApiSource.fetchGreenSpaces(lat, lon);
          allResources.addAll(greenSpaces.where((r) => r.type == GreenResourceType.park || r.type == GreenResourceType.communityGarden));
        } catch (e) {
          errors.add('Failed to fetch green spaces: $e');
        }
      }
      if (fetchAll || typesToFetch!.contains(GreenResourceType.recyclingCenter)) {
        try {
          allResources.addAll(await _overpassApiSource.fetchRecyclingCenters(lat, lon));
        } catch (e) {
          errors.add('Failed to fetch recycling centers: $e');
        }
      }
      if (fetchAll || typesToFetch!.contains(GreenResourceType.bikeSharingStation)) {
        try {
          allResources.addAll(await _overpassApiSource.fetchBikeSharing(lat, lon));
        } catch (e) {
          errors.add('Failed to fetch bike sharing stations: $e');
        }
      }
      if (fetchAll || typesToFetch!.contains(GreenResourceType.waterFountain)) {
        try {
          allResources.addAll(await _overpassApiSource.fetchDrinkingWater(lat, lon));
        } catch (e) {
          errors.add('Failed to fetch water fountains: $e');
        }
      }
      if (fetchAll || typesToFetch!.contains(GreenResourceType.evChargingStation)) {
        try {
          allResources.addAll(await _openChargeMapApiSource.fetchEVChargingStations(latitude: lat, longitude: lon));
        } catch (e) {
          errors.add('Failed to fetch EV charging stations: $e');
        }
      }
      if (fetchAll || typesToFetch!.contains(GreenResourceType.publicTransportHub)) {
        try {
          allResources.addAll(await _transportApiSource.fetchPublicTransportHubs(lat, lon));
        } catch (e) {
          errors.add('Failed to fetch transport hubs: $e');
        }
      }
    } catch (e) {
      errors.add('Unexpected error in getGreenResources: $e');
    }

    if (errors.isNotEmpty) {
      print('Errors in getGreenResources: $errors');
      throw Exception('Failed to fetch some resources: ${errors.join('; ')}');
    }

    if (typesToFetch != null && typesToFetch.isNotEmpty) {
      return allResources.where((res) => typesToFetch.contains(res.type)).toList();
    }
    return allResources;
  }

  @override
  Future<GreenResourceModel?> getGreenResourceById(String id, GreenResourceSource source) async {
    try {
      switch (source) {
        case GreenResourceSource.openChargeMap:
          // Fetch from OpenChargeMap API if needed
          return null; // Implement if API supports fetching by ID
        case GreenResourceSource.osm:
          // Fetch from Overpass API - sekarang method ini tersedia di abstract class
          final osmId = id.replaceFirst('osm_', ''); // Remove 'osm_' prefix if present
          final parts = osmId.split('_');
          if (parts.length < 2) {
            print('Invalid OSM ID format: $id');
            return null;
          }
          
          final elementType = parts[0]; // node, way, or relation
          final elementId = parts[1];
          
          final query = """
            [out:json][timeout:25];
            (
              $elementType(id:$elementId);
            );
            out center;
          """;
          final resources = await _overpassApiSource.fetchFromOverpass(query);
          return resources.isNotEmpty ? resources.first : null;
        case GreenResourceSource.gtfs:
          // Placeholder for GTFS-based fetching
          return null;
        default:
          return null;
      }
    } catch (e) {
      print('Error fetching resource by ID ($id): $e');
      return null;
    }
  }
}