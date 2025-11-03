# Firebase Functions - Configuración de Twilio

## Configuración Inicial

### 1. Instalar Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login en Firebase
```bash
firebase login
```

### 3. Configurar Twilio
Obtén tus credenciales de Twilio desde [twilio.com/console](https://twilio.com/console)

### 4. Configurar Variables de Entorno
Ejecuta estos comandos para configurar las variables de entorno:

```bash
firebase functions:config:set twilio.sid="TU_ACCOUNT_SID"
firebase functions:config:set twilio.token="TU_AUTH_TOKEN"
firebase functions:config:set twilio.number="+TU_NUMERO_TWILIO"
```

### 5. Instalar dependencias
```bash
cd functions
npm install
```

### 6. Desplegar las funciones
```bash
firebase deploy --only functions
```

## Verificación

Para verificar que las funciones están desplegadas correctamente:
```bash
firebase functions:list
```

## Uso de la Función sendSMS

La función `sendSMS` acepta los siguientes parámetros:
- `phone`: Número de teléfono del destinatario (requerido)
- `message`: Mensaje a enviar (requerido)
- `alertId`: ID de la alerta (opcional, para actualizar estado)
- `contactId`: ID del contacto (opcional, para actualizar estado)

## Solución de Problemas

### Error: "Configuración de Twilio no encontrada"
Asegúrate de haber ejecutado los comandos de configuración de variables de entorno.

### Error: "Usuario no autenticado"
La función requiere que el usuario esté autenticado en Firebase Auth.

### Error: "Teléfono y mensaje son requeridos"
Verifica que estés enviando los parámetros requeridos desde tu app Flutter.