import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';
import '../models/contact_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addAlert(AlertModel alert) async {
    await _db.collection('alerts').doc(alert.id).set(alert.toMap());
  }

  Future<List<AlertModel>> getAlerts(String userId) async {
    final snapshot = await _db
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => AlertModel.fromMap(doc.data())).toList();
  }

  Future<void> addContact(String userId, ContactModel contact) async {
    await _db.collection('contacts').doc(contact.id).set(contact.toMap()..['userId'] = userId);
  }

  Future<List<ContactModel>> getContacts(String userId) async {
    final snapshot = await _db.collection('contacts').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => ContactModel.fromMap(doc.data()..['id'] = doc.id)).toList();
  }

  Future<void> deleteContact(String userId, String contactId) async {
    await _db.collection('contacts').doc(contactId).delete();
  }

  Future<void> updateUser(String userId, String name, int alertTime) async {
    await _db.collection('users').doc(userId).update({
      'name': name,
      'alertTime': alertTime,
    });
  }

  Future<void> updateAlertReceipt(String alertId, String contactId, bool received) async {
    final alertRef = _db.collection('alerts').doc(alertId);
    final alertDoc = await alertRef.get();

    if (alertDoc.exists) {
      final data = alertDoc.data()!;
      final currentReceipts = Map<String, bool>.from(data['contactReceipts'] ?? {});
      currentReceipts[contactId] = received;

      await alertRef.update({'contactReceipts': currentReceipts});
    }
  }

  // Métodos estáticos eliminados para evitar conflictos
}