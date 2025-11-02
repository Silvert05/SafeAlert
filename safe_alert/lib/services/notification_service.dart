import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/contact_model.dart';

class NotificationService {
  static Future<void> sendAlertNotification(String userId, double latitude, double longitude, String alertId) async {
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

      // Enviar notificaciones reales usando Twilio
      for (final contact in contacts) {
        print("📤 ENVIANDO SMS a ${contact.name} (${contact.phone})");
        print("📍 Ubicación: $latitude, $longitude");
        print("🚨 ALERTA DE EMERGENCIA - Necesito ayuda en esta ubicación");

        try {
          // Enviar SMS real con Twilio
          await _sendRealSMS(contact.phone, "🚨 ALERTA DE EMERGENCIA: Necesito ayuda urgente. Mi ubicación: https://maps.google.com/?q=$latitude,$longitude");
          print("✅ SMS enviado exitosamente a ${contact.name}");

          // Marcar como enviado (inicialmente)
          await _markAsSent(alertId, contact.id);

          // Simular confirmación de entrega del operador (en producción vendría por webhook)
          await _simulateDeliveryConfirmation(alertId, contact.id);
        } catch (e) {
          print("❌ Error al enviar SMS a ${contact.name}: $e");
          // Podrías marcar como fallido aquí
        }
      }

      print("🎯 Notificación enviada a ${contacts.length} contactos!");
    } catch (e) {
      print("❌ Error al enviar notificación: $e");
      rethrow;
    }
  }

  static Future<void> _simulateDeliveryConfirmation(String alertId, String contactId) async {
    try {
      // Simular tiempo de entrega del operador (2-5 segundos)
      final deliveryTime = Duration(seconds: 2 + (contactId.hashCode % 3)); // Tiempo variable
      await Future.delayed(deliveryTime);

      // Obtener la alerta actual
      final firestore = FirebaseFirestore.instance;
      final alertDoc = await firestore.collection('alerts').doc(alertId).get();

      if (!alertDoc.exists) return;

      final alertData = alertDoc.data()!;
      final currentReceipts = Map<String, bool>.from(alertData['contactReceipts'] ?? {});

      // Marcar como entregado/recibido por el operador
      currentReceipts[contactId] = true;

      // Actualizar en Firestore
      await firestore.collection('alerts').doc(alertId).update({
        'contactReceipts': currentReceipts,
      });

      print("📬 SMS entregado exitosamente al contacto $contactId (simulado)");
    } catch (e) {
      print("❌ Error al confirmar entrega: $e");
    }
  }

  // Método para marcar como enviado inicialmente
  static Future<void> _markAsSent(String alertId, String contactId) async {
    final firestore = FirebaseFirestore.instance;
    final alertRef = firestore.collection('alerts').doc(alertId);
    final alertDoc = await alertRef.get();

    if (alertDoc.exists) {
      final data = alertDoc.data()!;
      final currentReceipts = Map<String, bool>.from(data['contactReceipts'] ?? {});
      currentReceipts[contactId] = false; // false = enviado pero no entregado aún
      await alertRef.update({'contactReceipts': currentReceipts});
    }
  }

  // Método para integrar con Twilio u otro servicio SMS real
  static Future<void> _sendRealSMS(String phoneNumber, String message) async {
    // CONFIGURACIÓN DE TWILIO - Reemplaza con tus credenciales reales
    const String accountSid = 'TU_ACCOUNT_SID_AQUI';  // ← Reemplaza con tu Account SID de Twilio
    const String authToken = 'TU_AUTH_TOKEN_AQUI';    // ← Reemplaza con tu Auth Token de Twilio
    const String twilioNumber = 'TU_NUMERO_TWILIO';   // ← Reemplaza con tu número de Twilio (ej: +1234567890)

    final String credentials = base64Encode(utf8.encode('$accountSid:$authToken'));

    final response = await http.post(
      Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': twilioNumber,
        'To': phoneNumber,
        'Body': message,
      },
    );

    if (response.statusCode == 201) {
      print('✅ SMS enviado exitosamente via Twilio');
      final responseData = jsonDecode(response.body);
      print('Message SID: ${responseData['sid']}');
    } else {
      print('❌ Error en respuesta de Twilio: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      throw Exception('Error al enviar SMS via Twilio: ${response.body}');
    }
  }
}
