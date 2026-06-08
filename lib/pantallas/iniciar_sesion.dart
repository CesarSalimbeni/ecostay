import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/pagextraviaj.dart';
import 'package:ecostay/pantallas/registro.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Inicio de sesion
  Future<void> _iniciarSesion() async {
    //verificación de campos
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var usuarioLogueado = await _gestionUsuario.iniciarSesion(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (usuarioLogueado.rol == 'cliente') {
        Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (context) => PantallaTempviaj(viajero: usuarioLogueado as Viajero),),
        );
        
      } else if (usuarioLogueado.rol == 'prestador') {
        
        // Cuando tengas tu pantalla de hotel lista, harás el cast correspondiente:
        // Navigator.pushReplacement(
        //   context, 
        //   MaterialPageRoute(
        //     builder: (context) => PantallaHotel(prestador: usuarioLogueado as PrestadorServicio),
        //   ),
        // );
        
      }
      
      } catch (e) {
      // Error de login (contraseña mal, usuario no existe, etc.)
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
                              labelText: "tu@correo.com", 
                              border: OutlineInputBorder(),
                              filled: true, 
                              fillColor: ColorPalette.bg
                            ),
                          ),
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
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "contraseña", 
                              border: OutlineInputBorder(), 
                              filled: true, 
                              fillColor: ColorPalette.bg
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