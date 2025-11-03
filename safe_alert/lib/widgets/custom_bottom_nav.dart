import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color accentBlue = Color(0xFF00A8FF);
  static const Color inactiveColor = Color(0xFF8E8E93);
  static const Color darkBg = Color(0xFF1C1C1E);
  static const Color darkSecondary = Color(0xFF2C2C2E);
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  

  // Colores para cada botón
  static const List<Color> itemColors = [primaryRed, accentBlue, primaryRed, accentBlue];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CurvedNavigationBar(
      index: currentIndex,
      height: 75,
      // Items con colores fijos (no cambian)
      items: <Widget>[
        _buildNavItem(
          icon: Icons.sos_rounded,
          label: 'SOS',
          isActive: currentIndex == 0,
          color: primaryRed,
          isDark: isDark,
        ),
        _buildNavItem(
          icon: Icons.contacts_rounded,
          label: 'Contactos',
          isActive: currentIndex == 1,
          color: accentBlue,
          isDark: isDark,
        ),
        _buildNavItem(
          icon: Icons.history_rounded,
          label: 'Historial',
          isActive: currentIndex == 2,
          color: primaryRed,
          isDark: isDark,
        ),
        _buildNavItem(
          icon: Icons.person_rounded,
          label: 'Perfil',
          isActive: currentIndex == 3,
          color: accentBlue,
          isDark: isDark,
        ),
      ],
      // Colores principales con curvatura elegante
      color: isDark ? darkSecondary : const Color.fromARGB(255, 65, 63, 63),
      buttonBackgroundColor: isDark ? darkSecondary : lightCard,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 500),
      onTap: onTap,
    );
  }

  static Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Contenedor con brillo suave
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Gradiente sutil - menos opaco
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [
                      color.withOpacity(0.15),
                      color.withOpacity(0.05),
                    ]
                  : [
                      Colors.transparent,
                      Colors.transparent,
                    ],
            ),
            // Borde elegante solo si está activo
            border: Border.all(
              color: isActive
                  ? color.withOpacity(isDark ? 0.35 : 0.25)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 28,
            color: isActive ? color : inactiveColor,
          ),
        ),
        const SizedBox(height: 8),
        // Label elegante
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : inactiveColor,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}