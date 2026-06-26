import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/registro.dart';
import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/gestion_usuario.dart';

class PantallaIniSesion extends StatefulWidget {
  const PantallaIniSesion({super.key});

  @override
  State<PantallaIniSesion> createState() => _PantallaIniSesionState();
}

class _PantallaIniSesionState extends State<PantallaIniSesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GestionUsuario _gestionUsuario = GestionUsuario();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Inicio de sesion
  Future<void> _iniciarSesion() async {
    final emailText = _emailController.text.trim();
    final passwordText = _passwordController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // 1. Verificación de campos vacíos
    if (emailText.isEmpty || passwordText.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var usuarioLogueado = await _gestionUsuario.iniciarSesion(
        emailText,
        passwordText,
      );

      if (!mounted) return;

      if (usuarioLogueado.suspendido) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Usted esta suspendido, no puede ingresar. Contacte con soporte técnico de ser un error.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (usuarioLogueado.rol == 'cliente') {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                HomeViajero(viajero: usuarioLogueado as Viajero),
          ),
        );
      } else if (usuarioLogueado.rol == 'host') {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                HomeAnfitrion(prestador: usuarioLogueado as PrestadorServicio),
          ),
        );
      } else {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                HomeAdmin(administrador: usuarioLogueado as Administrador),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Método para recuperar la contraseña
  //Nota: el correo llegará pero estará en Spam.
  Future<void> _recuperarContrasena() async {
    final emailText = _emailController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    // 1. Validar que el usuario haya escrito un correo antes de presionar el botón
    if (emailText.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu correo electrónico primero.'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Llamar al método de recuperarContraseña, validar, etc.
      final resultado = await _gestionUsuario.recuperarContrasena(emailText);

      if (!mounted) return;

      if (resultado == true) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Se ha enviado un enlace de recuperación a tu correo.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (resultado is String) {
        // Si devolvió un string, significa que es un error controlado.
        messenger.showSnackBar(
          SnackBar(content: Text(resultado), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildFormContent(BuildContext context, double screenWidth) {
    final isCompact = screenWidth < 700;

    return Container(
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 24 : 40,
              vertical: isCompact ? 24 : 36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/logo.jpg'),
                      radius: 34,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Ecostay',
                      style: TextStyle(
                        fontFamily: 'Idiqlat',
                        color: Color(0xFF216A44),
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Bienvenido de Vuelta",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Inicia sesión para continuar tu gran viaje.",
                ),
                const SizedBox(height: 32),
                const Text("Correo electrónico"),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "tu@correo.com",
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: ColorPalette.bg,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 8,
                  children: [
                    const Text("Contraseña"),
                    TextButton(
                      onPressed: _isLoading ? null : _recuperarContrasena,
                      child: const Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(
                          color: Color(0xFF216A44),
                          fontFamily: 'Idiqlat',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "contraseña",
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: ColorPalette.bg,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF526F75),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                FilledButton(
                  onPressed: _isLoading ? null : _iniciarSesion,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF216A44),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Idiqlat',
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿No tienes cuenta?",
                      style: TextStyle(fontFamily: 'Idiqlat'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PantallaRegistro(),
                          ),
                        );
                      },
                      child: const Text(
                        "Registrate aquí",
                        style: TextStyle(
                          color: Color(0xFF216A44),
                          fontFamily: 'Idiqlat',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePanel({double? height}) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/fondo.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showSideImage = screenWidth >= 900;

    return Scaffold(
      body: SafeArea(
        child: showSideImage
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildFormContent(context, screenWidth),
                  ),
                  Expanded(
                    flex: 4,
                    child: _buildImagePanel(),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildImagePanel(height: 220),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildFormContent(context, screenWidth),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
