import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';
import '../models/contact_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class AlertProvider with ChangeNotifier {
  final String userId;
  final FirestoreService _firestore;
  final LocationService _locationService = LocationService();
  List<ContactModel> _contacts = [];
  List<AlertModel> _alerts = [];

  AlertProvider({required this.userId})
      : _firestore = FirestoreService();

  List<ContactModel> get contacts => _contacts;
  List<AlertModel> get alerts => _alerts;

  Future<void> loadContacts() async {
    final service = FirestoreService();
    _contacts = await service.getContacts(userId);
    notifyListeners();
  }

  Future<void> sendAlert() async {
    try {
      // Verificar que haya contactos registrados antes de enviar alerta
      if (_contacts.isEmpty) {
        throw Exception('No hay contactos registrados. Agregue al menos un contacto antes de enviar una alerta.');
      }

      final position = await _locationService.getCurrentLocation();

      final alert = AlertModel(
        id: const Uuid().v4(),
        userId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      final service = FirestoreService();
      await service.addAlert(alert);
      await loadAlerts();

      // Enviar notificaciones a contactos
      await NotificationService.sendAlertNotification(userId, position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error al enviar alerta: $e');
      rethrow;
    }
  }

  Future<void> addContact(ContactModel contact) async {
    final service = FirestoreService();
    await service.addContact(userId, contact);
    await loadContacts();
  }

  Future<void> loadAlerts() async {
    final service = FirestoreService();
    _alerts = await service.getAlerts(userId);
    notifyListeners();
  }

  Future<void> deleteContact(String contactId) async {
    final service = FirestoreService();
    await service.deleteContact(userId, contactId);
    await loadContacts();
  }
}