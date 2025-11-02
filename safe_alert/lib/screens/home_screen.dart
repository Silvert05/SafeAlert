import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/alert_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  // Colores
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color accentOrange = Color(0xFFFF9500);

  // Colores modo oscuro
  static const Color darkBg = Color(0xFF1C1C1E);
  static const Color darkSecondary = Color(0xFF2C2C2E);
  static const Color darkCard = Color(0xFF2C2C2E);

  // Colores modo claro
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color lightSecondary = Color(0xFFE8E8EB);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Colores principales
  static const Color accentBlue = Color(0xFF00A8FF);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentPurple = Color(0xFF9F3FFF);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.8), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.3), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 20.0, end: 50.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 50.0, end: 20.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showAutoAlertDialog({
    required String title,
    required String message,
    required Color color,
    IconData icon = Icons.info_outlined,
    bool isDark = true,
    int durationSeconds = 2,
  }) {
    final cardBg = isDark ? darkCard : lightCard;
    final textColor = isDark ? Colors.white : Color(0xFF1C1C1E);
    final secondaryText = isDark ? Colors.white70 : Color(0xFF666666);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [darkCard, darkCard.withOpacity(0.95)]
                  : [lightCard, lightCard.withOpacity(0.95)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con fondo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(isDark ? 0.2 : 0.15),
                  border: Border.all(
                    color: color.withOpacity(isDark ? 0.3 : 0.25),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Mensaje
              Text(
                message,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    // Cierra automáticamente después del tiempo especificado
    Future.delayed(Duration(seconds: durationSeconds), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _sendSOS() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alerts = Provider.of<AlertProvider>(context, listen: false);

    // Mostrar feedback inmediato
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? darkCard : lightCard,
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [darkCard, darkCard.withOpacity(0.95)]
                    : [lightCard, lightCard.withOpacity(0.95)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentOrange.withOpacity(isDark ? 0.2 : 0.15),
                    border: Border.all(
                      color: accentOrange.withOpacity(isDark ? 0.3 : 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.send,
                    color: accentOrange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Enviando Alerta...',
                  style: TextStyle(
                    color: isDark ? Colors.white : Color(0xFF1C1C1E),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '🚨 Procesando tu alerta de emergencia. Por favor espera...',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Color(0xFF666666),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await alerts.sendAlert();

      if (mounted) {
        // Cerrar el diálogo anterior y mostrar éxito
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) Navigator.of(context).pop();
            });
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? darkCard : lightCard,
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [darkCard, darkCard.withOpacity(0.95)]
                        : [lightCard, lightCard.withOpacity(0.95)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentGreen.withOpacity(isDark ? 0.2 : 0.15),
                        border: Border.all(
                          color: accentGreen.withOpacity(isDark ? 0.3 : 0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: accentGreen,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '¡Alerta Enviada!',
                      style: TextStyle(
                        color: isDark ? Colors.white : Color(0xFF1C1C1E),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '🚨 Tu alerta de emergencia ha sido enviada exitosamente a tus contactos.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Color(0xFF666666),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // Cerrar el diálogo anterior y mostrar error
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) Navigator.of(context).pop();
            });
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? darkCard : lightCard,
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [darkCard, darkCard.withOpacity(0.95)]
                        : [lightCard, lightCard.withOpacity(0.95)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryRed.withOpacity(isDark ? 0.2 : 0.15),
                        border: Border.all(
                          color: primaryRed.withOpacity(isDark ? 0.3 : 0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: primaryRed,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Error al Enviar',
                      style: TextStyle(
                        color: isDark ? Colors.white : Color(0xFF1C1C1E),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No pudimos enviar tu alerta de emergencia. Intenta de nuevo.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Color(0xFF666666),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? darkBg : lightBg;
    final secondaryColor = isDark ? darkSecondary : lightSecondary;
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
                : [
                    lightBg,
                    lightSecondary.withOpacity(0.8),
                    Color(0xFFEFF5FF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header simplificado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SafeZone',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    // Elemento decorativo en modo claro
                    if (!isDark)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [accentBlue.withOpacity(0.2), accentPurple.withOpacity(0.2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: accentBlue,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),

              // Botón SOS con animaciones
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _pulseAnimation,
                          _glowAnimation,
                          _scaleAnimation,
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryRed,
                                    accentOrange,
                                    primaryRed,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryRed.withOpacity(0.6 * _pulseAnimation.value),
                                    blurRadius: _glowAnimation.value * 1.5,
                                    spreadRadius: _glowAnimation.value * 0.5,
                                    offset: const Offset(0, 0),
                                  ),
                                  BoxShadow(
                                    color: primaryRed.withOpacity(0.4 * _pulseAnimation.value),
                                    blurRadius: _glowAnimation.value * 2,
                                    spreadRadius: _glowAnimation.value,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: accentOrange.withOpacity(0.3 * _pulseAnimation.value),
                                    blurRadius: _glowAnimation.value * 1.5,
                                    spreadRadius: _glowAnimation.value * 0.3,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _sendSOS,
                                  borderRadius: BorderRadius.circular(110),
                                  splashColor: Colors.white.withOpacity(0.3),
                                  highlightColor: Colors.white.withOpacity(0.2),
                                  child: Center(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Colors.white.withOpacity(0.85),
                                            ],
                                          ).createShader(bounds),
                                      child: const Text(
                                        'SOS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 64,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Presiona para enviar alerta de emergencia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                     
                    ],
                  ),
                ),
              ),

              // Spacer para balance visual
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}