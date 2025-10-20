import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact_model.dart';

class NotificationService {
  static Future<void> sendAlertNotification(String userId, double latitude, double longitude) async {
    try {
      // Obtener contactos del usuario
      final firestore = FirebaseFirestore.instance;
      final contactsSnapshot = await firestore
          .collection('contacts')
          .where('userId', isEqualTo: userId)
          .get();

      final contacts = contactsSnapshot.docs
          .map((doc) => ContactModel.fromMap(doc.data()..['id'] = doc.id))
          .toList();

      if (contacts.isEmpty) {
        print("No hay contactos registrados para enviar notificaciones.");
        return;
      }

      // Aquí iría la lógica real para enviar notificaciones push/SMS
      // Por ahora, solo imprimimos en consola
      for (final contact in contacts) {
        print("Enviando alerta a ${contact.name} (${contact.phone})");
        print("Ubicación: $latitude, $longitude");
        // TODO: Implementar envío real de SMS o notificación push
      }

      print("Notificación enviada a ${contacts.length} contactos!");
    } catch (e) {
      print("Error al enviar notificación: $e");
      rethrow;
    }
  }
}
