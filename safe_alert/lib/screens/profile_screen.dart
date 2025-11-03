import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'dart:math' as math;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _logoutController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeOutAnimation;

  bool _isLoggingOut = false;

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
  static const Color accentBlue = Color(0xFF00A8FF);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentPurple = Color(0xFF9F3FFF);

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Animación de escala (crece y luego desaparece)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _logoutController,
      curve: Curves.easeInOut,
    ));

    // Animación de rotación
    _rotateAnimation = Tween<double>(begin: 0.0, end: 4 * math.pi).animate(
      CurvedAnimation(parent: _logoutController, curve: Curves.easeInOut),
    );

    // Animación de fade out
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoutController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _fadeController.forward();
    _loadUser();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _logoutController.dispose();
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _loadUser() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _name.text = auth.user?.displayName ?? '';
    _email.text = auth.user?.email ?? '';
  }

  void _performLogoutAnimation() async {
    setState(() => _isLoggingOut = true);
    
    // Iniciar animación
    await _logoutController.forward();
    
    // Cerrar sesión y navegar
    if (mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? darkCard : lightCard;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF666666);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con animación de pulso
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryRed.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: primaryRed.withOpacity(0.3 * value),
                            blurRadius: 20 * value,
                            spreadRadius: 5 * value,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: primaryRed,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '¿Estás seguro de que deseas cerrar sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : const Color(0xFFDDDDDD),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: secondaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryRed, accentOrange],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryRed.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _performLogoutAnimation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sí, Cerrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? darkBg : lightBg;
    final cardBg = isDark ? darkCard : lightCard;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF666666);

    final auth = Provider.of<AuthProvider>(context);
    final userInitial = auth.user?.email?.isNotEmpty ?? false
        ? auth.user!.email![0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Contenido principal
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [darkBg, darkSecondary.withOpacity(0.8), darkBg]
                    : [lightBg, const Color(0xFFEFF5FF), lightBg],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Mi Perfil',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu información de cuenta',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tarjeta de usuario
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : const Color(0xFFEEEEEE),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentBlue.withOpacity(isDark ? 0.15 : 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Avatar grande
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [accentBlue, accentPurple],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentBlue.withOpacity(0.3),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    userInitial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _name.text.isNotEmpty ? _name.text : 'Usuario',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _email.text,
                                      style: TextStyle(
                                        color: secondaryText,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: accentBlue.withOpacity(isDark ? 0.2 : 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: accentBlue.withOpacity(isDark ? 0.3 : 0.25),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: const Text(
                                        'Cuenta Activa',
                                        style: TextStyle(
                                          color: accentBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Sección Información (solo lectura)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información de Cuenta',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Campo Nombre (solo lectura)
                            _buildReadOnlyField(
                              value: _name.text.isNotEmpty ? _name.text : 'Usuario',
                              label: 'Nombre',
                              icon: Icons.person_outline,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 14),

                            // Campo Email (solo lectura)
                            _buildReadOnlyField(
                              value: _email.text,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              isDark: isDark,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Sección Apariencia
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Apariencia',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Toggle de tema
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.08)
                                      : const Color(0xFFEEEEEE),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    context.watch<ThemeProvider>().isDarkMode
                                        ? Icons.dark_mode_rounded
                                        : Icons.light_mode_rounded,
                                    color: isDark ? accentOrange : accentBlue,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Tema oscuro',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: context.watch<ThemeProvider>().isDarkMode,
                                    onChanged: (value) {
                                      context.read<ThemeProvider>().toggleTheme();
                                    },
                                    activeColor: accentOrange,
                                    inactiveThumbColor: accentBlue,
                                    activeTrackColor: accentOrange.withOpacity(0.3),
                                    inactiveTrackColor: accentBlue.withOpacity(0.2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Botón Cerrar Sesión
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed.withOpacity(isDark ? 0.15 : 0.12),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: primaryRed.withOpacity(isDark ? 0.3 : 0.25),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                color: primaryRed,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Overlay de animación de logout
          if (_isLoggingOut)
            AnimatedBuilder(
              animation: _logoutController,
              builder: (context, child) {
                return Container(
                  color: Colors.black.withOpacity(0.7 * _fadeOutAnimation.value),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo rotando y desapareciendo
                        Transform.rotate(
                          angle: _rotateAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [primaryRed, accentOrange],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryRed.withOpacity(0.6 * _fadeOutAnimation.value),
                                    blurRadius: 40,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Texto que desaparece
                        Opacity(
                          opacity: _fadeOutAnimation.value,
                          child: const Text(
                            'Cerrando sesión...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String value,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? darkCard : lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFFBBBBBB),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF999999),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}