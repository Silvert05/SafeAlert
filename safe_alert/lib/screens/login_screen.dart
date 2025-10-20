import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(_email.text, _password.text);

    setState(() => _loading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _error = "Correo o contraseña incorrectos";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('SafeAlert',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _email,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email, color: Colors.white),
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF007AFF))),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, color: Colors.white),
                labelText: 'Contraseña',
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF007AFF))),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Color(0xFFFF3B30))),
            ],
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Iniciar Sesión',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
            TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Registrar nuevo usuario',
                    style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
