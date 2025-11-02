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

  // Cargar contactos del usuario
  Future<void> loadContacts() async {
    if (userId.isEmpty) return; // ✅ Evita error si userId aún no está disponible
    final service = FirestoreService();
    _contacts = await service.getContacts(userId);
    notifyListeners();
  }

  // Enviar alerta de emergencia
  Future<void> sendAlert({String type = 'Emergencia'}) async {
    if (userId.isEmpty) return; // ✅ Evita error si userId no está disponible

    try {
      // Verificar que haya contactos registrados antes de enviar alerta
      if (_contacts.isEmpty) {
        throw Exception(
          'No hay contactos registrados. Agregue al menos un contacto antes de enviar una alerta.',
        );
      }

      // Simular posibilidad de fallo (20% de probabilidad)
      if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
        throw Exception(
          'Error de conexión. Verifique su conexión a internet e intente nuevamente.',
        );
      }

      final position = await _locationService.getCurrentLocation();

      final alert = AlertModel(
        id: const Uuid().v4(),
        userId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        type: type,
        status: AlertStatus.sending, // Iniciar con estado "enviando"
      );

      // Agregar alerta localmente primero para feedback inmediato
      _alerts.insert(0, alert);
      notifyListeners();

      final service = FirestoreService();
      await service.addAlert(alert);

      // Enviar notificaciones a contactos
      await NotificationService.sendAlertNotification(
        userId,
        position.latitude,
        position.longitude,
        alert.id,
      );

      // Actualizar estado a "enviado" cuando se complete exitosamente
      final sentAlert = alert.copyWith(status: AlertStatus.sent);
      await service.updateAlertStatus(alert.id, AlertStatus.sent);

      // Actualizar la alerta en la lista local
      final index = _alerts.indexWhere((a) => a.id == alert.id);
      if (index != -1) {
        _alerts[index] = sentAlert;
        notifyListeners();
      }

    } catch (e) {
      debugPrint('Error al enviar alerta: $e');

      // Si hay error, marcar como fallido
      final failedAlert = _alerts.firstWhere((a) => a.status == AlertStatus.sending);
      final updatedAlert = failedAlert.copyWith(status: AlertStatus.failed);
      await FirestoreService().updateAlertStatus(failedAlert.id, AlertStatus.failed);

      final index = _alerts.indexWhere((a) => a.id == failedAlert.id);
      if (index != -1) {
        _alerts[index] = updatedAlert;
        notifyListeners();
      }

      rethrow;
    }
  }

  // Agregar nuevo contacto
  Future<void> addContact(ContactModel contact) async {
    if (userId.isEmpty) return; // ✅ Evita error si userId no está disponible
    final service = FirestoreService();
    await service.addContact(userId, contact);
    await loadContacts();
  }

  // Cargar alertas del usuario
  Future<void> loadAlerts() async {
    if (userId.isEmpty) return; // ✅ Evita error si userId no está disponible
    final service = FirestoreService();
    _alerts = await service.getAlerts(userId);
    notifyListeners();
  }

  // Actualizar el estado de recepción de una alerta
  Future<void> updateAlertReceipt(
      String alertId, String contactId, bool received) async {
    if (userId.isEmpty) return; // ✅ Evita error si userId no está disponible

    try {
      final service = FirestoreService();
      await service.updateAlertReceipt(alertId, contactId, received);
      await loadAlerts(); // Recargar alertas para reflejar cambios
    } catch (e) {
      debugPrint('Error al actualizar receipt: $e');
      rethrow;
    }
  }

  // Eliminar contacto
  Future<void> deleteContact(String contactId) async {
    if (userId.isEmpty) return; // ✅ Evita error si userId no está disponible
    final service = FirestoreService();
    await service.deleteContact(userId, contactId);
    await loadContacts();
  }
}
