// lib/data_domain/sources/api/overpass_api_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';

abstract class OverpassApiSource {
  Future<List<GreenResourceModel>> fetchGreenSpaces(double lat, double lon, {double radius = 5000});
  Future<List<GreenResourceModel>> fetchRecyclingCenters(double lat, double lon, {double radius = 5000});
  Future<List<GreenResourceModel>> fetchBikeSharing(double lat, double lon, {double radius = 5000});
  Future<List<GreenResourceModel>> fetchDrinkingWater(double lat, double lon, {double radius = 5000});
  Future<List<GreenResourceModel>> fetchFromOverpass(String query);
}

class OverpassApiSourceImpl implements OverpassApiSource {
  final http.Client client;
  final String _baseUrl = 'https://overpass-api.de/api/interpreter';

  OverpassApiSourceImpl(this.client);

  @override
  Future<List<GreenResourceModel>> fetchFromOverpass(String query) async {
    print('Executing Overpass query: $query');
    try {
      final response = await client.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<GreenResourceModel> resources = [];
        if (data['elements'] != null) {
          for (var element in data['elements']) {
            final tags = element['tags'];
            if (tags == null) continue;

            String name = tags['name'] ?? 'Unnamed Resource';
            String address = _formatAddress(tags);
            GreenResourceType type = GreenResourceType.other;
            String osmId = '${element['type']}_${element['id']}';

            if (element['type'] == 'node' ||
                element['type'] == 'way' ||
                element['type'] == 'relation') {
              if (tags['leisure'] == 'park' ||
                  tags['leisure'] == 'garden' ||
                  tags['boundary'] == 'national_park' ||
                  tags['boundary'] == 'protected_area') {
                type = GreenResourceType.park;
              } else if (tags['landuse'] == 'allotments' ||
                  (tags['leisure'] == 'garden' && tags['community'] != null)) {
                type = GreenResourceType.communityGarden;
              } else if (tags['amenity'] == 'recycling') {
                type = GreenResourceType.recyclingCenter;
              } else if (tags['amenity'] == 'marketplace' &&
                  (tags['produce'] != null ||
                      tags['organic'] != null ||
                      name.toLowerCase().contains('tani'))) {
                type = GreenResourceType.farmersMarket;
              } else if (tags['amenity'] == 'bicycle_rental' ||
                  tags['amenity'] == 'bicycle_sharing') {
                type = GreenResourceType.bikeSharingStation;
              } else if (tags['amenity'] == 'drinking_water') {
                type = GreenResourceType.waterFountain;
              }
            }

            // Skip resources with invalid coordinates
            final latitude = element['lat'] ??
                (element['center'] != null ? element['center']['lat'] : null);
            final longitude = element['lon'] ??
                (element['center'] != null ? element['center']['lon'] : null);
            if (latitude == null || longitude == null) continue;

            resources.add(GreenResourceModel(
              id: 'osm_$osmId',
              name: name,
              type: type,
              address: address.isNotEmpty ? address : 'Location details unavailable',
              latitude: latitude,
              longitude: longitude,
              source: GreenResourceSource.osm,
              rawData: element,
              description: tags['description'] ?? tags['note'],
              openingHours: tags['opening_hours'],
            ));
          }
        }
        print('Fetched ${resources.length} resources from Overpass API');
        return resources;
      } else {
        print('Overpass API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch data from Overpass API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from Overpass API: $e');
      rethrow;
    }
  }

  String _formatAddress(Map<String, dynamic> tags) {
    List<String> addressParts = [];
    if (tags['addr:street'] != null) addressParts.add(tags['addr:street']);
    if (tags['addr:housenumber'] != null) addressParts.add(tags['addr:housenumber']);
    if (tags['addr:postcode'] != null) addressParts.add(tags['addr:postcode']);
    if (tags['addr:city'] != null) addressParts.add(tags['addr:city']);
    if (tags['addr:suburb'] != null && !addressParts.contains(tags['addr:city'])) {
      addressParts.add(tags['addr:suburb']);
    }

    if (addressParts.isEmpty && tags['name'] != null) {
      if (tags['is_in'] != null) return "${tags['name']}, ${tags['is_in']}";
      return tags['name']!;
    }
    return addressParts.join(', ');
  }

  @override
  Future<List<GreenResourceModel>> fetchGreenSpaces(double lat, double lon, {double radius = 5000}) {
    String around = '(around:$radius,$lat,$lon)';
    String query = """
      [out:json][timeout:25];
      (
        node["leisure"="park"]$around;
        way["leisure"="park"]$around;
        relation["leisure"="park"]$around;
        node["leisure"="garden"]$around;
        way["leisure"="garden"]$around;
        relation["leisure"="garden"]$around;
        node["landuse"="allotments"]$around;
        way["landuse"="allotments"]$around;
        node["boundary"="national_park"]$around;
        way["boundary"="national_park"]$around;
        relation["boundary"="national_park"]$around;
        node["boundary"="protected_area"]$around;
        way["boundary"="protected_area"]$around;
        relation["boundary"="protected_area"]$around;
      );
      out center;
    """;
    return fetchFromOverpass(query);
  }

  @override
  Future<List<GreenResourceModel>> fetchRecyclingCenters(double lat, double lon, {double radius = 5000}) {
    String around = '(around:$radius,$lat,$lon)';
    String query = """
      [out:json][timeout:25];
      (
        node["amenity"="recycling"]$around;
        way["amenity"="recycling"]$around;
      );
      out center;
    """;
    return fetchFromOverpass(query);
  }

  @override
  Future<List<GreenResourceModel>> fetchBikeSharing(double lat, double lon, {double radius = 5000}) {
    String around = '(around:$radius,$lat,$lon)';
    String query = """
      [out:json][timeout:25];
      (
        node["amenity"="bicycle_rental"]$around;
        way["amenity"="bicycle_rental"]$around;
        node["amenity"="bicycle_sharing"]$around;
        way["amenity"="bicycle_sharing"]$around;
      );
      out center;
    """;
    return fetchFromOverpass(query);
  }

  @override
  Future<List<GreenResourceModel>> fetchDrinkingWater(double lat, double lon, {double radius = 5000}) {
    String around = '(around:$radius,$lat,$lon)';
    String query = """
      [out:json][timeout:25];
      (
        node["amenity"="drinking_water"]$around;
      );
      out center;
    """;
    return fetchFromOverpass(query);
  }
}