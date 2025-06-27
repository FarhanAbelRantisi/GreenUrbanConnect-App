import 'package:flutter/material.dart';

enum GreenResourceType {
  park, // OSM: leisure=park, leisure=garden
  communityGarden, // OSM: landuse=allotments, leisure=garden (dengan tag community)
  recyclingCenter, // OSM: amenity=recycling
  farmersMarket, // OSM: amenity=marketplace (dengan tag produce/farmers)
  publicTransportHub, // GTFS, OSM: amenity=bus_station, railway=station
  bikeSharingStation, // OSM: amenity=bicycle_rental
  waterFountain, // OSM: amenity=drinking_water
  evChargingStation, // OpenChargeMap
  other
}

// Sumber data untuk resource, membantu membuat ID unik dan mengetahui asal data
enum GreenResourceSource { osm, openChargeMap, gtfs, manual, other }

class GreenResourceModel {
  final String id; // ID unik, bisa berupa "osm_node_12345", "ocm_67890"
  final String name;
  final GreenResourceType type;
  final String address;
  final double? latitude; // Dari API
  final double? longitude; // Dari API
  final String? description;
  final String? openingHours;
  final String? imageUrl; // Bisa dari API atau placeholder
  final String? contactInfo;
  final GreenResourceSource source; // Sumber data
  final Map<String, dynamic>? rawData; // Data mentah dari API, untuk detail lebih lanjut

  GreenResourceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.openingHours,
    this.imageUrl,
    this.contactInfo,
    required this.source,
    this.rawData,
  });

  // Helper untuk tampilan tipe
  String get typeDisplay {
    switch (type) {
      case GreenResourceType.park: return 'Taman Kota/Area Hijau';
      case GreenResourceType.communityGarden: return 'Kebun Komunitas';
      case GreenResourceType.recyclingCenter: return 'Pusat Daur Ulang';
      case GreenResourceType.farmersMarket: return 'Pasar Tani';
      case GreenResourceType.publicTransportHub: return 'Hub Transportasi Publik';
      case GreenResourceType.bikeSharingStation: return 'Stasiun Berbagi Sepeda';
      case GreenResourceType.waterFountain: return 'Fasilitas Air Minum';
      case GreenResourceType.evChargingStation: return 'Stasiun Pengisian EV';
      default: return 'Sumber Daya Lain';
    }
  }

  // Helper untuk ikon tipe
  IconData get typeIcon {
    switch (type) {
      case GreenResourceType.park: return Icons.park_outlined;
      case GreenResourceType.communityGarden: return Icons.local_florist_outlined;
      case GreenResourceType.recyclingCenter: return Icons.recycling_outlined;
      case GreenResourceType.farmersMarket: return Icons.storefront_outlined;
      case GreenResourceType.publicTransportHub: return Icons.directions_bus_filled_outlined;
      case GreenResourceType.bikeSharingStation: return Icons.directions_bike_outlined;
      case GreenResourceType.waterFountain: return Icons.water_drop_outlined;
      case GreenResourceType.evChargingStation: return Icons.ev_station_outlined;
      default: return Icons.place_outlined;
    }
  }

  // Catatan: fromFirestore dan toFirestore mungkin tidak lagi menjadi fokus utama
  // jika data sepenuhnya berasal dari API, kecuali untuk cache atau data manual.
  // Untuk saat ini, kita biarkan dulu.
}