import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alert_model.dart';
import '../providers/auth_provider.dart';
import '../providers/alert_provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final alerts = Provider.of<AlertProvider>(context, listen: false);
    alerts.loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = Provider.of<AlertProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(title: const Text('Historial de Alertas')),
      body: ListView.builder(
        itemCount: alerts.alerts.length,
        itemBuilder: (_, index) {
          final a = alerts.alerts[index];
          return Card(
            color: const Color(0xFF2C2C2E),
            child: ListTile(
              title: Text(
                  "${a.date} - ${a.time}",
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(a.location, style: const TextStyle(color: Colors.white70)),
              trailing: Icon(
                  a.sent ? Icons.check_circle : Icons.error,
                  color: a.sent ? Colors.green : Colors.redAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}
