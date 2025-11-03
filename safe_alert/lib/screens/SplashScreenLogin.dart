import 'package:flutter/material.dart';
import '../screens/main_navigation_screen.dart'; // 👈 Importa aquí

class SplashScreenLogin extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreenLogin({
    super.key,
    required this.nextScreen,
  });

  @override
  State<SplashScreenLogin> createState() => _SplashScreenLoginState();
}

class _SplashScreenLoginState extends State<SplashScreenLogin>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Colores
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color darkBg = Color(0xFF1C1C1E);
  static const Color darkSecondary = Color(0xFF2C2C2E);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animación de pulso
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animación de escala
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.1),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Animación de fade
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInCubic),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _pulseController.repeat();
    await _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    await _fadeController.forward();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
          settings: const RouteSettings(name: '/home'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [darkBg, darkSecondary.withOpacity(0.8), darkBg],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo principal con animación de latido
                AnimatedBuilder(
                  animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value * (0.9 + _pulseAnimation.value * 0.1),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryRed, accentOrange],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryRed.withOpacity(0.5 * _pulseAnimation.value),
                              blurRadius: 25 * _pulseAnimation.value,
                              spreadRadius: 5 * _pulseAnimation.value,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_open_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),

                // Texto animado
                FadeTransition(
                  opacity: _scaleAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Verificando credenciales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Accediendo a tu cuenta...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Línea de progreso animada
                FadeTransition(
                  opacity: _scaleAnimation,
                  child: Container(
                    width: 200,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _pulseController.value,
                            minHeight: 3,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryRed.withOpacity(0.8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}