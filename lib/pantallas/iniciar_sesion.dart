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

  // Inicio de sesión
  Future<void> _iniciarSesion() async {
    final emailText = _emailController.text.trim();
    final passwordText = _passwordController.text.trim();

    if (emailText.isEmpty || passwordText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
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

      if (usuarioLogueado.suspendido) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usted está suspendido, no puede ingresar. Contacte con soporte técnico.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (usuarioLogueado.rol == 'cliente') {
        Navigator.pushReplacement(context,
          MaterialPageRoute(
            builder: (context) => HomeViajero(viajero: usuarioLogueado as Viajero),
          ),
        );
      } else if (usuarioLogueado.rol == 'host') {
        Navigator.pushReplacement(context,
          MaterialPageRoute(
            builder: (context) => HomeAnfitrion(prestador: usuarioLogueado as PrestadorServicio),
          ),
        );
      } else {
        Navigator.pushReplacement(context,
          MaterialPageRoute(
            builder: (context) => HomeAdmin(administrador: usuarioLogueado as Administrador),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Recuperar contraseña
  Future<void> _recuperarContrasena() async {
    final emailText = _emailController.text.trim();

    if (emailText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu correo electrónico primero.'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resultado = await _gestionUsuario.recuperarContrasena(emailText);

      if (resultado == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un enlace de recuperación a tu correo.'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (resultado is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 750;
          final double currentWidth = constraints.maxWidth;

          Widget bloqueFormulario = SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24.0 : 60.0,
                  vertical: 40.0, // Un margen superior prudente para respirar un poco arriba
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  mainAxisAlignment: MainAxisAlignment.start, // Modificado a start para empujar todo arriba
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/logo.jpg'),
                          radius: 35,
                        ),
                        const SizedBox(width: 12),
                        Text('Ecostay',
                          style: TextStyle(fontFamily: 'Idiqlat', color: const Color(0xFF216A44),
                            fontSize: (currentWidth * 0.035).clamp(24.0, 34.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text("Bienvenido de Vuelta",
                      style: TextStyle(color: Colors.black, fontSize: (currentWidth * 0.025).clamp(18.0, 22.0),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Inicia sesión para continuar tu gran viaje.",
                      style: TextStyle(color: Colors.grey,  fontSize: (currentWidth * 0.018).clamp(13.0, 15.0),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    Text("Correo electrónico", 
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: (currentWidth * 0.018).clamp(13.0, 15.0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: _emailController, keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: (currentWidth * 0.018).clamp(14.0, 16.0)),
                      decoration: InputDecoration(hintText: "tu@correo.com",
                        hintStyle: TextStyle(fontSize: (currentWidth * 0.018).clamp(14.0, 16.0)),
                        border: const OutlineInputBorder(), filled: true, fillColor: ColorPalette.bg,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Contraseña", 
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: (currentWidth * 0.018).clamp(13.0, 15.0),
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _recuperarContrasena,
                          child: Text("¿Olvidaste tu contraseña?",
                            style: TextStyle(color: const Color(0xFF216A44), fontFamily: 'Idiqlat',
                              fontSize: (currentWidth * 0.016).clamp(12.0, 14.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextField(controller: _passwordController, obscureText: _obscurePassword,
                      style: TextStyle(fontSize: (currentWidth * 0.018).clamp(14.0, 16.0)),
                      decoration: InputDecoration(hintText: "contraseña",
                        hintStyle: TextStyle(fontSize: (currentWidth * 0.018).clamp(14.0, 16.0)),
                        border: const OutlineInputBorder(), filled: true, fillColor: ColorPalette.bg,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF526F75), size: (currentWidth * 0.025).clamp(20.0, 24.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    FilledButton(
                      onPressed: _isLoading ? null : _iniciarSesion,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF216A44), foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,
                              ),
                            )
                          : Text("Iniciar Sesión",
                              style: TextStyle(fontSize: (currentWidth * 0.020).clamp(14.0, 17.0),
                                fontFamily: 'Idiqlat',
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("¿No tienes cuenta?",
                          style: TextStyle(fontFamily: 'Idiqlat', fontSize: (currentWidth * 0.018).clamp(13.0, 15.0),
                          ),
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
                          child: Text("Regístrate aquí",
                            style: TextStyle(color: const Color(0xFF216A44), fontFamily: 'Idiqlat',
                              fontSize: (currentWidth * 0.018).clamp(13.0, 15.0),
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

          if (isMobile) {
            return bloqueFormulario;
          }

          return Row(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 6,
                child: Container(color: Colors.white,
                  child: bloqueFormulario,
                ),
              ),
              Expanded(flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/images/fondo.jpg'), fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}