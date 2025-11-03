import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _heartbeatController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _heartbeatAnimation;

  // Colores del patrón de diseño
  static const Color backgroundColor = Color(0xFF1C1C1E);
  static const Color secondaryBackground = Color(0xFF2C2C2E);
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color cardBackground = Color(0xFF2C2C2E);
  static const Color successGreen = Color(0xFF34C759);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _heartbeatAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _heartbeatController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _heartbeatController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _heartbeatController.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _showAlertDialog({
    required String title,
    required String message,
    required Color color,
    IconData icon = Icons.info_outlined,
    VoidCallback? onConfirm,
    bool isAutoClose = false,
    int durationSeconds = 2,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isAutoClose,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono animado
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Mensaje
              Text(
                message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),

              if (!isAutoClose) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm?.call();
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
                      'Entendido',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (isAutoClose) {
      Future.delayed(Duration(seconds: durationSeconds), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
          onConfirm?.call();
        }
      });
    }
  }

  // Validar nombre (solo letras y espacios, mínimo 3 caracteres)
  bool _isValidName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.trim().length < 3) return false;
    // Solo letras, espacios y acentos
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    return nameRegex.hasMatch(name.trim());
  }

  // Validar email (formato correcto)
  bool _isValidEmail(String email) {
    if (email.trim().isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  // Validar contraseña (mínimo 6 caracteres, al menos 1 letra y 1 número)
  bool _isValidPassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < 6) return false;
    // Al menos una letra y un número
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    return hasLetter && hasNumber;
  }

  void _register() async {
    // 1. Validar nombre
    if (_name.text.trim().isEmpty) {
      _showAlertDialog(
        title: '❌ Campo Vacío',
        message: 'Por favor ingresa tu nombre completo',
        color: primaryRed,
        icon: Icons.person_outline,
      );
      return;
    }

    if (_name.text.trim().length < 3) {
      _showAlertDialog(
        title: '⚠️ Nombre Muy Corto',
        message: 'Tu nombre debe tener al menos 3 caracteres',
        color: accentOrange,
        icon: Icons.short_text,
      );
      return;
    }

    if (!_isValidName(_name.text)) {
      _showAlertDialog(
        title: '⚠️ Nombre Inválido',
        message: 'El nombre solo puede contener letras y espacios, sin números ni símbolos',
        color: accentOrange,
        icon: Icons.abc,
      );
      return;
    }

    // 2. Validar email
    if (_email.text.trim().isEmpty) {
      _showAlertDialog(
        title: '❌ Campo Vacío',
        message: 'Por favor ingresa tu correo electrónico',
        color: primaryRed,
        icon: Icons.email_outlined,
      );
      return;
    }

    if (!_email.text.contains('@')) {
      _showAlertDialog(
        title: '⚠️ Email Incompleto',
        message: 'El correo debe contener el símbolo @ (ejemplo: usuario@email.com)',
        color: accentOrange,
        icon: Icons.alternate_email,
      );
      return;
    }

    if (!_isValidEmail(_email.text)) {
      _showAlertDialog(
        title: '⚠️ Email Inválido',
        message: 'Por favor ingresa un correo electrónico válido\n(ejemplo: usuario@gmail.com)',
        color: accentOrange,
        icon: Icons.email_outlined,
      );
      return;
    }

    // 3. Validar contraseña
    if (_password.text.isEmpty) {
      _showAlertDialog(
        title: '❌ Campo Vacío',
        message: 'Por favor ingresa una contraseña',
        color: primaryRed,
        icon: Icons.lock_outline,
      );
      return;
    }

    if (_password.text.length < 6) {
      _showAlertDialog(
        title: '⚠️ Contraseña Muy Corta',
        message: 'La contraseña debe tener al menos 6 caracteres para tu seguridad',
        color: accentOrange,
        icon: Icons.security,
      );
      return;
    }

    if (!_isValidPassword(_password.text)) {
      _showAlertDialog(
        title: '⚠️ Contraseña Débil',
        message: 'La contraseña debe contener al menos:\n• Una letra (a-z)\n• Un número (0-9)',
        color: accentOrange,
        icon: Icons.password,
      );
      return;
    }

    // 4. Validar confirmación de contraseña
    if (_confirmPassword.text.isEmpty) {
      _showAlertDialog(
        title: '❌ Campo Vacío',
        message: 'Por favor confirma tu contraseña',
        color: primaryRed,
        icon: Icons.lock_outline,
      );
      return;
    }

    if (_password.text != _confirmPassword.text) {
      _showAlertDialog(
        title: '⚠️ Contraseñas No Coinciden',
        message: 'Las contraseñas ingresadas no son iguales. Por favor verifica.',
        color: primaryRed,
        icon: Icons.sync_problem,
      );
      return;
    }

    // 5. Validar términos
    if (!_acceptTerms) {
      _showAlertDialog(
        title: '⚠️ Términos No Aceptados',
        message: 'Debes aceptar los términos y condiciones para continuar',
        color: primaryRed,
        icon: Icons.assignment_outlined,
      );
      return;
    }

    // 6. Registrar usuario
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      final success = await auth.register(
        _name.text.trim(),
        _email.text.trim().toLowerCase(),
        _password.text,
      );

      if (success) {
        await auth.logout();
        setState(() => _loading = false);

        // Éxito - con cierre automático
        _showAlertDialog(
          title: '✅ ¡Cuenta Creada!',
          message: 'Tu cuenta se ha creado exitosamente. Redirigiendo al inicio de sesión...',
          color: successGreen,
          icon: Icons.check_circle,
          isAutoClose: true,
          durationSeconds: 2,
          onConfirm: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        );
      } else {
        setState(() => _loading = false);
        _showAlertDialog(
          title: '❌ Error en el Registro',
          message: 'No pudimos crear tu cuenta. El correo ya podría estar registrado.',
          color: primaryRed,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      _showAlertDialog(
        title: '❌ Error de Conexión',
        message: 'Hubo un problema al crear tu cuenta. Verifica tu conexión a internet.',
        color: primaryRed,
        icon: Icons.wifi_off,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              secondaryBackground,
              backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botón de retroceso
                      IconButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: cardBackground.withOpacity(0.5),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Logo con animación de latido
                      Center(
                        child: AnimatedBuilder(
                          animation: _heartbeatAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _heartbeatAnimation.value,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [primaryRed, accentOrange],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryRed.withOpacity(0.6 * _heartbeatAnimation.value),
                                      blurRadius: 30 * _heartbeatAnimation.value,
                                      spreadRadius: 8 * _heartbeatAnimation.value,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Título
                      const Center(
                        child: Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtítulo
                      Center(
                        child: Text(
                          'Únete a SafeAlert hoy',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Campo Nombre (SOLO LETRAS)
                      _buildInputField(
                        controller: _name,
                        label: 'Nombre Completo',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                          LengthLimitingTextInputFormatter(50),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Campo Email
                      _buildInputField(
                        controller: _email,
                        label: 'Correo Electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')), // Sin espacios
                          LengthLimitingTextInputFormatter(60),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Campo Contraseña
                      _buildPasswordField(
                        controller: _password,
                        label: 'Contraseña',
                        obscure: _obscurePassword,
                        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Campo Confirmar Contraseña
                      _buildPasswordField(
                        controller: _confirmPassword,
                        label: 'Confirmar Contraseña',
                        obscure: _obscureConfirmPassword,
                        onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Checkbox de términos
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                              activeColor: primaryRed,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Acepto los ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Términos y Condiciones',
                                    style: TextStyle(
                                      color: accentOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Botón de Registro
                      _buildRegisterButton(),

                      const SizedBox(height: 25),

                      // Texto de login
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes cuenta? ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                              child: const Text(
                                'Inicia sesión',
                                style: TextStyle(
                                  color: primaryRed,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.white.withOpacity(0.5),
            size: 22,
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryRed, accentOrange],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryRed.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _loading ? null : _register,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}