import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/usuario.dart';
import 'package:ecostay/models/prestador_servicio.dart';

enum UserRole { viajero, anfitrion }

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}
class _PantallaRegistroState extends State<PantallaRegistro> {
  UserRole _selectedRole = UserRole.viajero;
  final GestionUsuario _gestionUsuario = GestionUsuario();
  bool _isLoading = false; 

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _cedulaCtrl = TextEditingController();
  final TextEditingController _rifCtrl = TextEditingController();
  final TextEditingController _paypalCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    _passCtrl.dispose();
    _cedulaCtrl.dispose();
    _rifCtrl.dispose();
    _paypalCtrl.dispose();
    super.dispose();
  }
  
  Future<void> _crearCuenta() async {
    final isViajero = _selectedRole == UserRole.viajero;
    final emailText = _correoCtrl.text.trim();

    // Validación estricta del dominio @correo.unimet.edu.ve solo para viajeros
    if (isViajero) {
      final unimetRegex = RegExp(r'^[\w-\.]+@correo\.unimet\.edu\.ve$');
      if (!unimetRegex.hasMatch(emailText.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Acceso denegado: Los viajeros deben usar un correo institucional @correo.unimet.edu.ve'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final String rolBackend = isViajero ? 'cliente' : 'host';

      Map<String, dynamic> extras = isViajero 
        ? {
            'telefono': _telefonoCtrl.text.trim(),
            'cedula': _cedulaCtrl.text.trim(),
            'direccion': _direccionCtrl.text.trim(), // Se usa para Ciudad
            'suspendido': false
          }
        : {
            'telefono': _telefonoCtrl.text.trim(),
            'direccion': _direccionCtrl.text.trim(),
            'rif': _rifCtrl.text.trim(),
            'cuentaPayPal': _paypalCtrl.text.trim(),
            'suspendido': false
          };

      await _gestionUsuario.registrarUsuario(
        email: emailText,
        password: _passCtrl.text.trim(),
        nombre: _nombreCtrl.text.trim(),
        rol: rolBackend,
        datosAdicionales: extras,
      );

      String uid = FirebaseAuth.instance.currentUser!.uid;
      Usuario usuarioCreado;

      if (isViajero) {
        usuarioCreado = Viajero(
          id: uid, 
          nombre: _nombreCtrl.text.trim(),
          email: emailText,
          fechaRegistro: DateTime.now(),
          telefono: _telefonoCtrl.text.trim(),
          cedula: _cedulaCtrl.text.trim(),
          ciudad: _direccionCtrl.text.trim(),
          suspendido: false,
          historialReservas: [],
        );
      } else {
        usuarioCreado = PrestadorServicio(
          id: uid, 
          nombre: _nombreCtrl.text.trim(),
          email: emailText,      
          fechaRegistro: DateTime.now(),
          rif: _rifCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
          cuentaPayPal: _paypalCtrl.text.trim(),
          suspendido: false,
          estadisticas: [],
        );
      }
      
      if (mounted) {
        if (usuarioCreado is Viajero) {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => HomeViajero(viajero: usuarioCreado as Viajero),
            ),
          );
        } else if (usuarioCreado is PrestadorServicio) {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => HomeAnfitrion(prestador: usuarioCreado as PrestadorServicio),
            ),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cuenta creada con éxito!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isViajero = _selectedRole == UserRole.viajero;

    return Scaffold(
      backgroundColor: ColorPalette.bg, 
      body: Center(
        child: Container(width: 775, height: 775,
          decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(30)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 30.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Crea tu cuenta de Ecostay',
                      style: TextStyle(fontFamily: 'Idiqlat', color: Colors.black, fontSize: 30),
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(backgroundImage: AssetImage('assets/images/logo.jpg'), radius: 40)
                  ],
                ),
                const SizedBox(height: 25),
            
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () { setState(() { _selectedRole = UserRole.viajero; }); },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(20.0),
                          backgroundColor: isViajero ? const Color(0xFF216A44).withOpacity(0.1) : Colors.transparent,
                          side: BorderSide(color: isViajero ? const Color(0xFF216A44) : Colors.grey.shade400, width: isViajero ? 2.0 : 1.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          alignment: AlignmentDirectional.centerStart,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.air, color: Color(0xFF216A44), size: 40),
                            Text('Soy Viajero', style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat', 
                            fontWeight: isViajero ? FontWeight.bold : FontWeight.normal)),
                            const Text('Quiero descubrir destinos.', style: TextStyle(color: Color(0xFF8E8E93)))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () { setState(() { _selectedRole = UserRole.anfitrion; }); },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(20.0),
                          backgroundColor: !isViajero ? const Color(0xFF216A44).withOpacity(0.1) : Colors.transparent,
                          side: BorderSide(color: !isViajero ? const Color(0xFF216A44) : Colors.grey.shade400, width: !isViajero ? 2.0 : 1.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          alignment: AlignmentDirectional.centerStart,
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.home_outlined, color: Color(0xFF216A44), size: 40),
                            Text('Soy Anfitrión', style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat', fontWeight: !isViajero ? FontWeight.bold : FontWeight.normal)),
                            const Text('Ofrezco servicios turísticos', style: TextStyle(color: Color(0xFF8E8E93)))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Nombre"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nombreCtrl, keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]')),
                            ],
                            decoration: InputDecoration(labelText: "Nombre", border: const OutlineInputBorder(), 
                              filled: true, fillColor: ColorPalette.bg,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Teléfono"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _telefonoCtrl, keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(labelText: "Teléfono", border: const OutlineInputBorder(), filled: true, fillColor: ColorPalette.bg),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
            
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Correo electrónico"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _correoCtrl, keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: "tu@correo.com", border: const OutlineInputBorder(), filled: true, fillColor: ColorPalette.bg),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isViajero ? "Ciudad" : "Dirección Fiscal"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _direccionCtrl,
                            decoration: InputDecoration(
                              labelText: isViajero ? "Ciudad Real, País" : "Calle Real, Estado, País",
                              border: const OutlineInputBorder(), filled: true, fillColor: ColorPalette.bg,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Contraseña"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passCtrl, obscureText: true, decoration: InputDecoration(
                              labelText: "Contraseña", border: const OutlineInputBorder(), 
                            filled: true, fillColor: ColorPalette.bg),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                if (isViajero)
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Cédula"),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _cedulaCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(labelText: "55555555", border: const OutlineInputBorder(), filled: true, fillColor: ColorPalette.bg),
                      )
                    ],
                  )
                else
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Rif"),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _rifCtrl,
                              decoration: InputDecoration(labelText: "J-555555-5", border: const OutlineInputBorder(), filled: true, fillColor: ColorPalette.bg),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Cuenta PayPal"),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _paypalCtrl,
                              decoration: InputDecoration(labelText: "tu.cuenta@paypal.com", border: const OutlineInputBorder(), filled: true, fillColor: ColorPalette.bg),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                
                Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: FilledButton(
                    onPressed: _isLoading ? null : _crearCuenta,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF216A44), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading 
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Crea tu cuenta de Ecostay", style: TextStyle(fontSize: 16, fontFamily: 'Idiqlat')),
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