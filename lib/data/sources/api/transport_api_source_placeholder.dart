import 'package:green_urban_connect/data/models/green_resource_model.dart';

abstract class TransportApiSourcePlaceholder {
  Future<List<GreenResourceModel>> fetchPublicTransportHubs(String city);
}

class TransportApiSourcePlaceholderImpl implements TransportApiSourcePlaceholder {
  @override
  Future<List<GreenResourceModel>> fetchPublicTransportHubs(String city) async {
    // Ini adalah placeholder. Di aplikasi nyata, Anda akan memanggil API GTFS
    // atau API transportasi lokal spesifik untuk kota yang dipilih.
    print("Memanggil TransportApiSourcePlaceholder untuk kota: $city");
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi panggilan API

    if (city.toLowerCase() == 'pekanbaru') {
      return [
        GreenResourceModel(
          id: 'gtfs_pku_terminal_brps',
          name: 'Terminal Bandar Raya Payung Sekaki (BRPS)',
          type: GreenResourceType.publicTransportHub,
          address: 'Jl. Tuanku Tambusai Ujung, Pekanbaru',
          latitude: 0.476, 
          longitude: 101.398,
          description: 'Terminal bus utama di Pekanbaru.',
          source: GreenResourceSource.gtfs, // Anggap saja dari GTFS
          rawData: {'operator': 'Dinas Perhubungan Pekanbaru', 'routes_served': ['AKAP', 'AKDP', 'Trans Metro Pekanbaru']}
        ),
         GreenResourceModel(
          id: 'gtfs_pku_halte_ramayana',
          name: 'Halte Trans Metro Ramayana Sudirman',
          type: GreenResourceType.publicTransportHub,
          address: 'Jl. Jenderal Sudirman (depan Ramayana), Pekanbaru',
          latitude: 0.5204, 
          longitude: 101.4472,
          description: 'Halte bus Trans Metro Pekanbaru.',
          source: GreenResourceSource.gtfs,
          rawData: {'operator': 'Trans Metro Pekanbaru', 'shelter_type': 'elevated'}
        ),
      ];
    }
    // Kembalikan daftar kosong jika kota tidak dikenal atau tidak ada data simulasi
    return [];
  }
}