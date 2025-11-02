import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';
import '../models/contact_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // === CONTACTOS ===
  Future<void> addContact(String userId, ContactModel contact) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(contact.id)
        .set(contact.toMap());
  }

  Future<List<ContactModel>> getContacts(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .get();

    return snapshot.docs
        .map((doc) => ContactModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> deleteContact(String userId, String contactId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(contactId)
        .delete();
  }

  // === ALERTAS ===
  Future<void> addAlert(AlertModel alert) async {
    await _db
        .collection('alerts') // ✅ Colección principal (no dentro del user)
        .doc(alert.id)
        .set(alert.toMap());
  }

  Future<List<AlertModel>> getAlerts(String userId) async {
    final snapshot = await _db
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AlertModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateAlertReceipt(
      String alertId, String contactId, bool received) async {
    await _db.collection('alerts').doc(alertId).update({
      'contactReceipts.$contactId': received,
    });
  }

  Future<void> updateAlertStatus(String alertId, AlertStatus status) async {
    await _db.collection('alerts').doc(alertId).update({
      'status': status.name,
    });
  }
}
