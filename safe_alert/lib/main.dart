import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// === PROVEEDORES ===
import 'providers/auth_provider.dart';
import 'providers/alert_provider.dart';

// === PANTALLAS ===
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SafeAlertApp());
}

class SafeAlertApp extends StatelessWidget {
  const SafeAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, AlertProvider>(
          create: (_) => AlertProvider(userId: ''),
          update: (_, auth, alert) => AlertProvider(userId: auth.user?.uid ?? ''),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SafeAlert',
        theme: ThemeData(
          colorSchemeSeed: Colors.red,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.red,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,

        // 🔹 Pantalla inicial
        home: const SplashScreen(),

        // 🔹 Rutas globales de la app
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/contacts': (context) => ContactsScreen(),
          '/alerts': (context) => const AlertsScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
