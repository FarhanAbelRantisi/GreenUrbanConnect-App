import 'package:cloud_firestore/cloud_firestore.dart';

enum InitiativeStatus { proposed, approved, ongoing, completed, rejected }
enum InitiativeCategory { wasteReduction, greening, education, cleanUp, renewableEnergy, waterConservation, sustainableTransport, communityGarden, other }


class InitiativeModel {
  final String? id; // Nullable for creation, non-null when fetched
  final String title;
  final String description;
  final String location; // Could be an address or lat/lng string
  final DateTime date; // For events, or start date for ongoing initiatives
  final String organizerId; // User ID of the proposer/organizer
  final String? organizerName; // Denormalized for easy display
  final InitiativeCategory category;
  final InitiativeStatus status;
  final Timestamp createdAt;
  final String? imageUrl; // Optional image for the initiative
  final List<String>? participantIds; // List of user IDs who joined

  InitiativeModel({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.organizerId,
    this.organizerName,
    required this.category,
    this.status = InitiativeStatus.proposed, // Default status
    Timestamp? createdAt,
    this.imageUrl,
    this.participantIds,
  }) : createdAt = createdAt ?? Timestamp.now();


  factory InitiativeModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return InitiativeModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No Description',
      location: data['location'] ?? 'No Location',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'],
      category: InitiativeCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => InitiativeCategory.other,
      ),
      status: InitiativeStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => InitiativeStatus.proposed,
      ),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      imageUrl: data['imageUrl'],
      participantIds: List<String>.from(data['participantIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'organizerId': organizerId,
      'organizerName': organizerName,
      'category': category.toString(),
      'status': status.toString(),
      'createdAt': createdAt,
      'imageUrl': imageUrl,
      'participantIds': participantIds,
    };
  }

  // Helper to get a display string for category
  String get categoryDisplay {
    switch (category) {
      case InitiativeCategory.wasteReduction: return 'Waste Reduction';
      case InitiativeCategory.greening: return 'Greening Project';
      case InitiativeCategory.education: return 'Educational Program';
      case InitiativeCategory.cleanUp: return 'Clean-Up Drive';
      case InitiativeCategory.renewableEnergy: return 'Renewable Energy';
      case InitiativeCategory.waterConservation: return 'Water Conservation';
      case InitiativeCategory.sustainableTransport: return 'Sustainable Transport';
      case InitiativeCategory.communityGarden: return 'Community Garden';
      default: return 'Other';
    }
  }
}