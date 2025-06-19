import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io'; // For File type if used with image_picker

enum UrbanIssueStatus { reported, underReview, inProgress, resolved, rejected }
enum UrbanIssueCategory {
  illegalDumping,
  brokenAmenity,
  roadDamage,
  fallenTree,
  poorLighting,
  waterLeakage,
  airPollution,
  noisePollution,
  other
}

class UrbanIssueModel {
  final String? id; // Nullable for creation
  final String description;
  final UrbanIssueCategory category;
  final String location; // Could be address or GeoPoint string
  final String? imageUrl; // URL after upload to Firebase Storage
  final String reporterId;
  final String? reporterName; // Denormalized
  final UrbanIssueStatus status;
  final Timestamp reportedAt;
  final String? aiSuggestedCategory; // For the AI feature
  final double? aiConfidence; // For the AI feature

  // Not stored in Firestore, used for image upload
  final File? imageFile;

  UrbanIssueModel({
    this.id,
    required this.description,
    required this.category,
    required this.location,
    this.imageUrl,
    required this.reporterId,
    this.reporterName,
    this.status = UrbanIssueStatus.reported,
    Timestamp? reportedAt,
    this.aiSuggestedCategory,
    this.aiConfidence,
    this.imageFile, // For local handling before upload
  }) : reportedAt = reportedAt ?? Timestamp.now();

  factory UrbanIssueModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UrbanIssueModel(
      id: doc.id,
      description: data['description'] ?? 'No Description',
      category: UrbanIssueCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => UrbanIssueCategory.other,
      ),
      location: data['location'] ?? 'Unknown Location',
      imageUrl: data['imageUrl'],
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'],
      status: UrbanIssueStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => UrbanIssueStatus.reported,
      ),
      reportedAt: data['reportedAt'] ?? Timestamp.now(),
      aiSuggestedCategory: data['aiSuggestedCategory'],
      aiConfidence: (data['aiConfidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'category': category.toString(),
      'location': location,
      'imageUrl': imageUrl,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'status': status.toString(),
      'reportedAt': reportedAt,
      'aiSuggestedCategory': aiSuggestedCategory,
      'aiConfidence': aiConfidence,
    };
  }

  // Helper for display
  String get categoryDisplay {
    switch (category) {
      case UrbanIssueCategory.illegalDumping: return 'Illegal Dumping';
      case UrbanIssueCategory.brokenAmenity: return 'Broken Amenity';
      case UrbanIssueCategory.roadDamage: return 'Road Damage';
      case UrbanIssueCategory.fallenTree: return 'Fallen Tree';
      case UrbanIssueCategory.poorLighting: return 'Poor Lighting';
      case UrbanIssueCategory.waterLeakage: return 'Water Leakage';
      case UrbanIssueCategory.airPollution: return 'Air Pollution';
      case UrbanIssueCategory.noisePollution: return 'Noise Pollution';
      default: return 'Other';
    }
  }
}