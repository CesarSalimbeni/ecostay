import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/registro.dart';
import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SE AÑADIÓ: Necesario para FilteringTextInputFormatter
import 'package:ecostay/models/gestion_usuario.dart'; 

class PantallaIniSesion extends StatefulWidget {
  const PantallaIniSesion({super.key});

  @override
  State<PantallaIniSesion> createState() => _PantallaIniSesionState();
}

class _PantallaIniSesionState extends State<PantallaIniSesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // SE AÑADIERON: Controladores para Cédula y Teléfono
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  
  final GestionUsuario _gestionUsuario = GestionUsuario();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cedulaController.dispose(); // SE AÑADIÓ: Limpieza del controlador
    _telefonoController.dispose(); // SE AÑADIÓ: Limpieza del controlador
    super.dispose();
  }

  // Inicio de sesion
  Future<void> _iniciarSesion() async {
    final emailText = _emailController.text.trim();
    final passwordText = _passwordController.text.trim();
    final cedulaText = _cedulaController.text.trim(); // SE AÑADIÓ
    final telefonoText = _telefonoController.text.trim(); // SE AÑADIÓ

    // 1. Verificación de campos vacíos (Se incluyeron cédula y teléfono)
    if (emailText.isEmpty || passwordText.isEmpty || cedulaText.isEmpty || telefonoText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos.')),
      );
      return;
    }

    // 2. Validación estricta del dominio @unimet.edu.ve
    final unimetRegex = RegExp(r'^[\w-\.]+@unimet\.edu\.ve$');
    if (!unimetRegex.hasMatch(emailText.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acceso denegado: Debes usar un correo institucional @unimet.edu.ve'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var usuarioLogueado = await _gestionUsuario.iniciarSesion(
        emailText,
        passwordText,
      );

      if (usuarioLogueado.rol == 'cliente') {
        Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (context) => HomeViajero(viajero: usuarioLogueado as Viajero),),
        );
        
      } else if (usuarioLogueado.rol == 'host') {
         Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => HomeAnfitrion(prestador: usuarioLogueado as PrestadorServicio),
          ),
        );
        
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20,),
                    const Row(
                      children: [
                        SizedBox(width: 20,),
                        CircleAvatar(backgroundImage: AssetImage('assets/images/logo.jpg'), radius: 40,),
                        SizedBox(width: 10,),
                        Text('Ecostay', style: TextStyle(fontFamily: 'Idiqlat', 
                        color: Color(0xFF216A44), fontSize: 30),)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60.0, right: 40.0),
                      child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20,),
                          const Text("Bienvenido de Vuelta", style: TextStyle(color: Colors.black, fontSize: 20),),
                          const Text("Inicia sesión para continuar tu gran viaje."),
                          const SizedBox(height: 40,),
                          const Text("Correo electrónico"),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "tu@unimet.edu.ve",
                              border: const OutlineInputBorder(),
                              filled: true, 
                              fillColor: ColorPalette.bg
                            ),
                          ),
                          
                          // ==========================================
                          // SE AÑADIÓ: CAMPO DE CÉDULA (SOLO NÚMEROS)
                          // ==========================================
                          const SizedBox(height: 30,),
                          const Text("Cédula"),
                          TextField(
                            controller: _cedulaController,
                            keyboardType: TextInputType.number, // Teclado numérico
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // Bloquea letras/símbolos
                            ],
                            decoration: InputDecoration(
                              labelText: "Ej: 28123456", 
                              border: const OutlineInputBorder(), 
                              filled: true, 
                              fillColor: ColorPalette.bg
                            ),
                          ),

                          // ==========================================
                          // SE AÑADIÓ: CAMPO DE TELÉFONO (SOLO NÚMEROS)
                          // ==========================================
                          const SizedBox(height: 30,),
                          const Text("Número de teléfono"),
                          TextField(
                            controller: _telefonoController,
                            keyboardType: TextInputType.phone, // Teclado telefónico
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // Bloquea letras/símbolos
                            ],
                            decoration: InputDecoration(
                              labelText: "Ej: 04121234567", 
                              border: const OutlineInputBorder(), 
                              filled: true, 
                              fillColor: ColorPalette.bg
                            ),
                          ),
                          // ==========================================

                          const SizedBox(height: 30,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            children: [
                              const Text("Contraseña"),
                              TextButton(
                                onPressed: () {}, 
                                child: const Text("¿Olvidaste tu contraseña?", 
                                style: TextStyle(color: Color(0xFF216A44), fontFamily: 'Idiqlat'),),
                              )
                            ],
                          ),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "contraseña", 
                              border: const OutlineInputBorder(), 
                              filled: true, 
                              fillColor: ColorPalette.bg,
                              suffixIcon: IconButton(onPressed: () {
                                setState(() {_obscurePassword = !_obscurePassword;});
                              }, 
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFF526F75)))
                            ),
                          ),
                          const SizedBox(height: 50,),
                          FilledButton(
                            onPressed: _isLoading ? null : _iniciarSesion,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF216A44),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: _isLoading 
                                ? const SizedBox(
                                    height: 20, 
                                    width: 20, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)
                                  )
                                : const Text("Iniciar Sesión", style: TextStyle(fontSize: 16, fontFamily: 'Idiqlat'),),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("¿No tienes cuenta?", style: TextStyle(fontFamily: 'Idiqlat'),),
                              TextButton(
                                onPressed: () {Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const PantallaRegistro(), ),);
                                },
                                child: const Text("Registrate aquí", 
                                style: TextStyle(color: Color(0xFF216A44), fontFamily: 'Idiqlat'),)
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fondo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}