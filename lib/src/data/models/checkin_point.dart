import 'package:cloud_firestore/cloud_firestore.dart';

class CheckinPoint {
  final String id;
  final String name;
  final String creator;
  final double lat;
  final double lng;
  final double radiusMeters;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  CheckinPoint({
    required this.id,
    required this.name,
    required this.creator,
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    required this.active,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  factory CheckinPoint.fromMap(String id, Map<String, dynamic> data) {
    return CheckinPoint(
      id: id,
      name: data['name'] ?? '',
      creator: data['creator'] ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: (data['radiusMeters'] as num?)?.toDouble() ?? 50.0,
      active: data['active'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'creator': creator,
      'lat': lat,
      'lng': lng,
      'radiusMeters': radiusMeters,
      'active': active,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }

  CheckinPoint copyWith({
    String? id,
    String? name,
    String? creator,
    double? lat,
    double? lng,
    double? radiusMeters,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return CheckinPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      creator: creator ?? this.creator,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}