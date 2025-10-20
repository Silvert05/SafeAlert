import 'package:latlong2/latlong.dart';

class AlertModel {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  AlertModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'],
      userId: map['userId'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  // Getters adicionales para compatibilidad
  String get date => timestamp.toLocal().toString().split(' ')[0];
  String get time => timestamp.toLocal().toString().split(' ')[1].substring(0, 5);
  bool get sent => true; // Asumiendo que todas las alertas guardadas fueron enviadas
  String get location => '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}