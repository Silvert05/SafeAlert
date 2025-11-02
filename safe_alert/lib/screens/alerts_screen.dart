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

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Colores Modo Oscuro
  static const Color darkBg = Color(0xFF1C1C1E);
  static const Color darkSecondary = Color(0xFF2C2C2E);
  static const Color darkCard = Color(0xFF2C2C2E);

  // Colores Modo Claro
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color lightSecondary = Color(0xFFE8E8EB);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Colores principales
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentBlue = Color(0xFF00A8FF);
  static const Color accentPurple = Color(0xFF9F3FFF);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();

    final alerts = Provider.of<AlertProvider>(context, listen: false);
    alerts.loadAlerts();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = Provider.of<AlertProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? darkBg : lightBg;
    final secondaryColor = isDark ? darkSecondary : lightSecondary;
    final cardBg = isDark ? darkCard : lightCard;
    final textColor = isDark ? Colors.white : Color(0xFF1C1C1E);
    final secondaryText = isDark ? Colors.white70 : Color(0xFF666666);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [darkBg, darkSecondary.withOpacity(0.8), darkBg]
                : [lightBg, Color(0xFFEFF5FF), lightBg],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header mejorado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial de Alertas',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestiona tus alertas de emergencia',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de alertas
                Expanded(
                  child: alerts.alerts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      accentBlue.withOpacity(isDark ? 0.3 : 0.2),
                                      accentPurple.withOpacity(isDark ? 0.3 : 0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.history_outlined,
                                  size: 50,
                                  color: isDark ? accentBlue : accentBlue.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Sin alertas aún',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tus alertas de emergencia aparecerán aquí',
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: alerts.alerts.length,
                          itemBuilder: (_, index) {
                            final AlertModel a = alerts.alerts[index];
                            return _buildAlertCard(a, index, isDark, cardBg, textColor, secondaryText);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  

               Widget _buildAlertCard(
  AlertModel alert,
  int index,
  bool isDark,
  Color cardBg,
  Color textColor,
  Color secondaryText,
) {
  final provider = Provider.of<AlertProvider>(context, listen: false);

  // Determinar icono y color según tipo
  IconData alertIcon;
  Color iconColor;
  String alertTitle;

  if (alert.type == 'Emergencia') {
    alertIcon = Icons.sos_rounded;
    iconColor = primaryRed;
    alertTitle = 'Alerta de emergencia';
  } else {
    alertIcon = Icons.warning_amber_rounded;
    iconColor = accentOrange;
    alertTitle = 'Alerta automática';
  }

  // Estado basado en el nuevo sistema de estados
  late Color statusColor;
  late String statusText;
  late IconData statusIcon;

  switch (alert.status) {
    case AlertStatus.sending:
      statusColor = accentOrange;
      statusText = 'Enviando...';
      statusIcon = Icons.send;
      break;
    case AlertStatus.sent:
      statusColor = accentGreen;
      statusText = 'Enviada';
      statusIcon = Icons.check_circle;
      break;
    case AlertStatus.failed:
      statusColor = primaryRed;
      statusText = 'Fallida';
      statusIcon = Icons.error;
      break;
    default: // AlertStatus.pending
      statusColor = accentOrange;
      statusText = 'Pendiente';
      statusIcon = Icons.schedule;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAlertDetails(context, alert, provider.contacts, isDark, cardBg, textColor, secondaryText),
        borderRadius: BorderRadius.circular(20),
        splashColor: isDark ? primaryRed.withOpacity(0.1) : accentBlue.withOpacity(0.1),
        highlightColor: isDark ? primaryRed.withOpacity(0.05) : accentBlue.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Color(0xFFEEEEEE),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(isDark ? 0.15 : 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono animado
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [iconColor, iconColor.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(alertIcon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha y hora
                    Text(
                      '${alert.date} • ${alert.time}',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Título
                    Text(
                      alertTitle,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Ubicación
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: secondaryText.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            alert.location,
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Estado con badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(isDark ? 0.15 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withOpacity(isDark ? 0.3 : 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: statusColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  void _showAlertDetails(
    BuildContext context,
    AlertModel alert,
    List<ContactModel> contacts,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color secondaryText,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [darkBg, darkSecondary.withOpacity(0.8)]
                    : [lightCard, Color(0xFFF8FAFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con cerrar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detalles de Recepción',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Color(0xFFEEEEEE),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: textColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alerta enviada el ${alert.date} a las ${alert.time}',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Estado por contacto:',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista de contactos - scrollable
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: contacts.asMap().entries.map((entry) {
                              int idx = entry.key;
                              ContactModel contact = entry.value;
                              // Si la alerta está enviada, marcar todos los contactos como entregados
                              final received = alert.status == AlertStatus.sent || alert.isReceivedBy(contact.id);

                              return Container(
                                margin: EdgeInsets.only(bottom: idx == contacts.length - 1 ? 0 : 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? darkSecondary.withOpacity(0.6)
                                      : Color(0xFFF8F8FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: received
                                        ? accentGreen.withOpacity(isDark ? 0.2 : 0.15)
                                        : accentOrange.withOpacity(isDark ? 0.2 : 0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: received
                                          ? accentGreen.withOpacity(isDark ? 0.2 : 0.15)
                                          : accentOrange.withOpacity(isDark ? 0.2 : 0.15),
                                      child: Icon(
                                        received ? Icons.check_circle : Icons.schedule,
                                        color: received ? accentGreen : accentOrange,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contact.name,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            contact.phone,
                                            style: TextStyle(
                                              color: secondaryText,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: received
                                            ? accentGreen.withOpacity(isDark ? 0.15 : 0.12)
                                            : accentOrange.withOpacity(isDark ? 0.15 : 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: received
                                              ? accentGreen.withOpacity(isDark ? 0.3 : 0.25)
                                              : accentOrange.withOpacity(isDark ? 0.3 : 0.25),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        received ? 'Entregada' : 'Pendiente',
                                        style: TextStyle(
                                          color: received ? accentGreen : accentOrange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}