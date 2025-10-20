import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  int alertTime = 5;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _name.text = auth.user?.displayName ?? '';
    _email.text = auth.user?.email ?? '';
  }

  void _saveChanges() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final service = FirestoreService();
    await service.updateUser(auth.user!.uid, _name.text, alertTime);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados')));
  }

  void _logout() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF007AFF)))),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Tiempo alerta automática (min)',
                    style: TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: alertTime,
                  dropdownColor: const Color(0xFF2C2C2E),
                  items: [5, 10, 15, 30]
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toString(),
                              style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (v) => setState(() => alertTime = v!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Guardar cambios'),
              ),
            ),
            TextButton(
                onPressed: _logout,
                child: const Text('Cerrar sesión',
                    style: TextStyle(color: Color(0xFFFF3B30)))),
          ],
        ),
      ),
    );
  }
}
