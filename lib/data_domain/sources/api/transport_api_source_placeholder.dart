import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class TransportApiSource {
  Future<List<GreenResourceModel>> fetchPublicTransportHubs(double lat, double lon, {double radius = 5000});
}

class TransportApiSourceImpl implements TransportApiSource {
  final http.Client client;
  final String _baseUrl = 'https://overpass-api.de/api/interpreter';

  TransportApiSourceImpl(this.client);

  @override
  Future<List<GreenResourceModel>> fetchPublicTransportHubs(double lat, double lon, {double radius = 5000}) async {
    String around = '(around:$radius,$lat,$lon)';
    String query = """
      [out:json][timeout:25];
      (
        node["amenity"="bus_station"]$around;
        way["amenity"="bus_station"]$around;
        node["railway"="station"]$around;
        way["railway"="station"]$around;
      );
      out center;
    """;

    print('Fetching transport hubs from Overpass API: $query');
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

            String name = tags['name'] ?? 'Unnamed Transport Hub';
            String address = _formatAddress(tags);
            String osmId = '${element['type']}_${element['id']}';
            final latitude = element['lat'] ??
                (element['center'] != null ? element['center']['lat'] : null);
            final longitude = element['lon'] ??
                (element['center'] != null ? element['center']['lon'] : null);
            if (latitude == null || longitude == null) continue;

            resources.add(GreenResourceModel(
              id: 'osm_$osmId',
              name: name,
              type: GreenResourceType.publicTransportHub,
              address: address.isNotEmpty ? address : 'Location details unavailable',
              latitude: latitude,
              longitude: longitude,
              description: tags['description'] ?? 'Public transport hub',
              openingHours: tags['opening_hours'],
              source: GreenResourceSource.osm,
              rawData: element,
            ));
          }
        }
        print('Fetched ${resources.length} transport hubs');
        return resources;
      } else {
        print('Overpass API Error for transport hubs: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch transport hubs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching transport hubs: $e');
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
}