import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// === PROVEEDORES ===
import 'providers/auth_provider.dart';
import 'providers/alert_provider.dart';
import 'providers/theme_provider.dart';

// === PANTALLAS ===
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, AlertProvider>(
          create: (_) => AlertProvider(userId: ''),
          update: (_, auth, previous) {
            final uid = auth.user?.uid;
            if (uid == null || uid.isEmpty) {
              // Usuario no logueado todavía → evitar Firestore
              return AlertProvider(userId: '');
            }
            // Usuario logueado → cargar contactos/alertas automáticamente
            final provider = AlertProvider(userId: uid);
            provider.loadContacts();
            provider.loadAlerts();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      builder: (context, child) {
        // ✅ Contexto ya tiene todos los providers disponibles
        return const SafeAlertApp();
      },
    ),
  );
}

class SafeAlertApp extends StatelessWidget {
  const SafeAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeAlert',

      // 🌞 Tema claro
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF007AFF),
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1C1C1E)),
          bodyMedium: TextStyle(color: Color(0xFF3C3C43)),
          bodySmall: TextStyle(color: Color(0xFF8E8E93)),
          headlineLarge: TextStyle(color: Color(0xFF1C1C1E)),
          headlineMedium: TextStyle(color: Color(0xFF1C1C1E)),
          headlineSmall: TextStyle(color: Color(0xFF1C1C1E)),
          titleLarge: TextStyle(color: Color(0xFF1C1C1E)),
          titleMedium: TextStyle(color: Color(0xFF1C1C1E)),
          titleSmall: TextStyle(color: Color(0xFF1C1C1E)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2F2F7),
          foregroundColor: Color(0xFF1C1C1E),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF007AFF),
          unselectedItemColor: Color(0xFF8E8E93),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF007AFF),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF007AFF).withOpacity(0.3),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF007AFF),
            side: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF007AFF);
            }
            return Colors.white;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF007AFF).withOpacity(0.3);
            }
            return const Color(0xFF8E8E93).withOpacity(0.3);
          }),
        ),
      ),

      // 🌙 Tema oscuro
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFFFF3B30),
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        cardColor: const Color(0xFF2C2C2E),
        dialogBackgroundColor: const Color(0xFF2C2C2E),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFE5E5EA)),
          bodySmall: TextStyle(color: Color(0xFF8E8E93)),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1C1C1E),
          selectedItemColor: Color(0xFFFF3B30),
          unselectedItemColor: Color(0xFF8E8E93),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF3B30),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3B30),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFFFF3B30).withOpacity(0.3),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFF3B30),
            side: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFFFF3B30);
            }
            return Colors.white;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFFFF3B30).withOpacity(0.3);
            }
            return const Color(0xFF8E8E93).withOpacity(0.3);
          }),
        ),
      ),

      // 🌙 Cambia entre modo claro / oscuro usando ThemeProvider
      themeMode: context.watch<ThemeProvider>().themeMode,

      // Pantalla inicial
      home: const SplashScreen(),

      // Rutas
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigationScreen(),
      },
    );
  }
}
