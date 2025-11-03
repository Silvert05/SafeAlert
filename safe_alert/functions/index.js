const functions = require("firebase-functions");
const admin = require("firebase-admin");
const twilio = require("twilio");

// Inicializar Firebase Admin
admin.initializeApp();

// Función para enviar SMS con Twilio
exports.sendSMS = functions.https.onCall(async (data, context) => {
  // Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Usuario no autenticado"
    );
  }

  const { phone, message, alertId, contactId } = data;

  // Validar datos requeridos
  if (!phone || !message) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Teléfono y mensaje son requeridos"
    );
  }

  try {
    // Obtener configuración de Twilio desde Firebase Config
    const twilioConfig = functions.config().twilio;

    if (!twilioConfig || !twilioConfig.sid || !twilioConfig.token || !twilioConfig.number) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Configuración de Twilio no encontrada. Configura las variables de entorno."
      );
    }

    // Crear cliente de Twilio
    const client = twilio(twilioConfig.sid, twilioConfig.token);

    // Enviar SMS
    const result = await client.messages.create({
      body: message,
      from: twilioConfig.number,
      to: phone,
    });

    // Actualizar estado de recepción en Firestore si se proporciona alertId y contactId
    if (alertId && contactId) {
      const alertRef = admin.firestore().collection('alerts').doc(alertId);
      await alertRef.update({
        [`contactReceipts.${contactId}`]: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    console.log(`SMS enviado exitosamente a ${phone}. SID: ${result.sid}`);

    return {
      success: true,
      sid: result.sid,
      status: result.status
    };

  } catch (error) {
    console.error("Error enviando SMS:", error);

    // Actualizar estado de recepción como fallido si se proporciona alertId y contactId
    if (data.alertId && data.contactId) {
      try {
        const alertRef = admin.firestore().collection('alerts').doc(data.alertId);
        await alertRef.update({
          [`contactReceipts.${data.contactId}`]: false,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      } catch (updateError) {
        console.error("Error actualizando estado de recepción:", updateError);
      }
    }

    throw new functions.https.HttpsError(
      "internal",
      `Error enviando SMS: ${error.message}`
    );
  }
});
