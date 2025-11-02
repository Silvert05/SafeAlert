import 'package:latlong2/latlong.dart'; // TODO: Remove if not used

enum AlertStatus { pending, sending, sent, failed }

class AlertModel {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? type; // 'Emergencia' o 'Automática'
  final Map<String, bool> contactReceipts; // ID del contacto -> recibido (true/false)
  final AlertStatus status; // Estado de la alerta

  AlertModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.type = 'Emergencia',
    this.contactReceipts = const {},
    this.status = AlertStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'contactReceipts': contactReceipts,
      'status': status.name, // Guardar como string
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'],
      userId: map['userId'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
      type: map['type'] ?? 'Emergencia',
      contactReceipts: Map<String, bool>.from(map['contactReceipts'] ?? {}),
      status: AlertStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AlertStatus.pending,
      ),
    );
  }

  // Getters adicionales para compatibilidad
  String get date => timestamp.toLocal().toString().split(' ')[0];
  String get time => timestamp.toLocal().toString().split(' ')[1].substring(0, 5);
  bool get sent => status == AlertStatus.sent; // Ahora se basa en el estado
  String get location => '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  // Método para crear una copia con nuevo estado
  AlertModel copyWith({AlertStatus? status}) {
    return AlertModel(
      id: id,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      type: type,
      contactReceipts: contactReceipts,
      status: status ?? this.status,
    );
  }

  // Método para obtener el estado de recepción de un contacto específico
  bool isReceivedBy(String contactId) => contactReceipts[contactId] ?? false;

  // Método para marcar como recibido por un contacto
  AlertModel markAsReceived(String contactId) {
    final updatedReceipts = Map<String, bool>.from(contactReceipts);
    updatedReceipts[contactId] = true;
    return AlertModel(
      id: id,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      type: type,
      contactReceipts: updatedReceipts,
    );
  }
}