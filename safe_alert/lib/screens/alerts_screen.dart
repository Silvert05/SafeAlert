import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alert_model.dart';
import '../models/contact_model.dart';
import '../providers/alert_provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Colores del patrón de diseño
  static const Color backgroundColor = Color(0xFF1C1C1E);
  static const Color secondaryBackground = Color(0xFF2C2C2E);
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color cardBackground = Color(0xFF2C2C2E);

  @override
  void initState() {
    super.initState();
    final alerts = Provider.of<AlertProvider>(context, listen: false);
    alerts.loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = Provider.of<AlertProvider>(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Historial de Alertas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, secondaryBackground, backgroundColor],
          ),
        ),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: alerts.alerts.length,
          itemBuilder: (_, index) {
            final AlertModel a = alerts.alerts[index];
            return _buildAlertCard(a);
          },
        ),
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    final provider = Provider.of<AlertProvider>(context, listen: false);

    // Determinar icono y color según tipo
    IconData alertIcon;
    Color iconColor;
    String alertTitle;
    Color statusColor;
    String statusText;

    if (alert.type == 'Emergencia') {
      alertIcon = Icons.sos_rounded;
      iconColor = primaryRed;
      alertTitle = 'Alerta de emergencia';
    } else {
      alertIcon = Icons.warning_amber_rounded;
      iconColor = accentOrange;
      alertTitle = 'Alerta automática';
    }

    // Estado basado en receipts (más lógico)
    final totalContacts = provider.contacts.length;
    final deliveredCount = alert.contactReceipts.values.where((delivered) => delivered).length;

    if (deliveredCount == totalContacts && totalContacts > 0) {
      statusColor = const Color(0xFF34C759); // Verde
      statusText = 'Entregada a todos';
    } else if (deliveredCount > 0) {
      statusColor = accentOrange;
      statusText = 'Entregada a $deliveredCount/$totalContacts';
    } else if (alert.sent) {
      statusColor = accentOrange;
      statusText = 'Enviada';
    } else {
      statusColor = Colors.red;
      statusText = 'Fallida';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono SOS o advertencia
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(alertIcon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),

          // Información de la alerta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha y hora
                Text(
                  '${alert.date}  ${alert.time}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),

                // Título
                Text(
                  alertTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Ubicación
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        alert.location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Estado (enviada o pendiente) con detalles expandibles
          GestureDetector(
            onTap: () => _showAlertDetails(context, alert, provider.contacts),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: statusColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertDetails(BuildContext context, AlertModel alert, List<ContactModel> contacts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalles de Recepción',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Alerta enviada el ${alert.date} a las ${alert.time}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Estado por contacto:',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...contacts.map((contact) {
                final received = alert.isReceivedBy(contact.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: received ? const Color(0xFF34C759) : accentOrange,
                        child: Icon(
                          received ? Icons.check : Icons.schedule,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              contact.phone,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        received ? 'Entregada' : 'Pendiente',
                        style: TextStyle(
                          color: received ? const Color(0xFF34C759) : accentOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
