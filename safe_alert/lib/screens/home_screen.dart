import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/alert_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animación pulsante para botón SOS
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation =
        Tween<double>(begin: 1.0, end: 1.1).animate(_controller)..addListener(() {
          setState(() {});
        });
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendSOS() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final alerts = Provider.of<AlertProvider>(context, listen: false);

    try {
      await alerts.sendAlert();

      // Mostrar feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerta enviada a tus contactos'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar alerta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: _animation.value,
              child: ElevatedButton(
                onPressed: _sendSOS,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(80),
                  backgroundColor: const Color(0xFFFF3B30),
                ),
                child: const Icon(Icons.warning, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons.contacts, 'Contactos', '/contacts'),
                _actionButton(Icons.history, 'Historial', '/alerts'),
                _actionButton(Icons.person, 'Perfil', '/profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, String route) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: const Color(0xFF007AFF), size: 36),
          onPressed: () => Navigator.pushNamed(context, route),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
      ],
    );
  }
}
