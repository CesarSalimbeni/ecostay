import 'dart:math';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:ecostay/pantallas/publicaciones_anf.dart';
import 'package:ecostay/pantallas/reservas_anf.dart';
import 'package:ecostay/screens/home_anfitrion.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/prestador_servicio.dart';

class PerfilAnfitrion extends StatefulWidget {
  final PrestadorServicio prestador;

  const PerfilAnfitrion({super.key, required this.prestador});

  @override
  State<PerfilAnfitrion> createState() => _PerfilAnfitrionState();
}

class _PerfilAnfitrionState extends State<PerfilAnfitrion> {
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _rifController;
  late TextEditingController _direccionController;
  late TextEditingController _paypalController;

  final GestionUsuario _gestionUsuario = GestionUsuario();
  
  late PrestadorServicio _prestadorActual;

  @override
  void initState() {
    super.initState();

    _prestadorActual = widget.prestador;

    _nombreController = TextEditingController(text: _prestadorActual.nombre);
    _emailController = TextEditingController(text: _prestadorActual.email);
    _telefonoController = TextEditingController(text: _prestadorActual.telefono);
    _rifController = TextEditingController(text: _prestadorActual.rif);
    _direccionController = TextEditingController(text: _prestadorActual.direccion);
    _paypalController = TextEditingController(text: _prestadorActual.cuentaPayPal);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _rifController.dispose();
    _direccionController.dispose();
    _paypalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
        ),
        title: SearchBar(
          hintText: 'Buscar...', 
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
        ),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 10.0),
            // Usamos _prestadorActual para reflejar cambios en la UI
            child: Text(_prestadorActual.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
            style: const TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF216A44),
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                TextButton.icon(
                  onPressed: () {Navigator.pushReplacement(context,
                      // Pasamos el prestador actualizado al navegar
                      MaterialPageRoute(builder: (context) => HomeAnfitrion(prestador: _prestadorActual)),
                    );
                  }, 
                  icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                  label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,)),
                ),
                TextButton.icon(
                  onPressed: () {Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: _prestadorActual)),
                    );
                  }, 
                  icon: const Icon(Icons.upload, color: Color(0xFF216A44), size: 28),
                  label: const Text('Publicaciones', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed:() {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: _prestadorActual),
                        ),
                      );
                    },
                  icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed: null, 
                  icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                  label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                  fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(padding: const EdgeInsets.only(top: 50, bottom: 50),
                  child: SizedBox(width: 1240, 
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mi Perfil', style: TextStyle(fontSize: 40, 
                          fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 30),
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // COLUMNA IZQUIERDA: Tarjeta del Avatar
                            Expanded(flex: 4,
                              child: Container(padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                decoration: BoxDecoration(color: Colors.white, 
                                borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  children: [
                                    Container(width: 130, height: 130,
                                      decoration: const BoxDecoration(color: Color(0xFF38664D), 
                                      shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.person, color: Colors.white, size: 70),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      _prestadorActual.nombre, 
                                      textAlign: TextAlign.center, style: const TextStyle(
                                      fontSize: 32, fontFamily: 'Idiqlat', color: Colors.black, 
                                      fontWeight: FontWeight.w800)),
                                    const Text('Anfitrión', style: TextStyle(color: Color(0xFF6E867A), fontSize: 18)),
                                    const SizedBox(height: 25),
                                    OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFCCCCCC)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                        minimumSize: const Size(200, 50),
                                        backgroundColor: const Color(0xFFF5F7F2),
                                      ),
                                      child: const Text('Cambiar Foto', style: TextStyle(color: Colors.black, 
                                      fontSize: 16)),
                                    ),
                                    const SizedBox(height: 35),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          // 1. Cerramos la sesión en Firebase
                                          await _gestionUsuario.cerrarSesion();
                                          
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Sesión cerrada con éxito')),
                                            );

                                            // 2. Navegamos a la pantalla de login limpiando el historial de navegación
                                            Navigator.pushAndRemoveUntil(context,
                                              MaterialPageRoute(builder: (context) => const PantallaInicio(), 
                                              ),
                                              (route) => false,
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al cerrar sesión: $e')),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.black, 
                                      fontSize: 18, fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 40),
                            
                            // COLUMNA DERECHA: Detalles del perfil
                            Expanded(flex: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                decoration: BoxDecoration(color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildEditableProfileItem('Responsable', _nombreController, 'No especificado'),
                                    _buildDivider(),
                                    _buildEditableProfileItem('Correo', _emailController, 'No especificado', 
                                    keyboardType: TextInputType.emailAddress),
                                    _buildDivider(),
                                    _buildEditableProfileItem('Teléfono', _telefonoController, 'No especificado', 
                                    keyboardType: TextInputType.phone),
                                    _buildDivider(),
                                    _buildEditableProfileItem('Rif', _rifController, 'No especificado'),
                                    _buildDivider(),
                                    _buildEditableProfileItem('Dirección Fiscal', _direccionController, 
                                    'No especificado'),
                                    _buildDivider(),
                                    _buildEditableProfileItem('Cuenta PayPal', _paypalController, 'No especificado', 
                                    keyboardType: TextInputType.emailAddress),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          Map<String, dynamic> datosActualizados = {
                                            'nombre': _nombreController.text,
                                            'email': _emailController.text,
                                            'telefono': _telefonoController.text,
                                            'rif': _rifController.text,
                                            'direccion': _direccionController.text,
                                            'cuentaPayPal': _paypalController.text,
                                          };

                                          // Enviamos la edición a Firebase
                                          await _gestionUsuario.editarInformacion(_prestadorActual.id, datosActualizados);

                                          if (context.mounted) {
                                            // Actualizamos el estado local para redibujar la UI con los nuevos cambios
                                            setState(() {
                                              _prestadorActual = PrestadorServicio(
                                                id: _prestadorActual.id,
                                                nombre: _nombreController.text,
                                                email: _emailController.text,
                                                fechaRegistro: _prestadorActual.fechaRegistro,
                                                rif: _rifController.text,
                                                telefono: _telefonoController.text,
                                                direccion: _direccionController.text,
                                                cuentaPayPal: _paypalController.text,
                                                estadisticas: _prestadorActual.estadisticas,
                                                suspendido: _prestadorActual.suspendido
                                              );
                                            });

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Cambios guardados con éxito')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al guardar cambios: $e')),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF38664D),
                                        foregroundColor: Colors.white, elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      ),
                                      child: const Text('Guardar Cambios', style: TextStyle(fontSize: 16, 
                                      fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]
                    )
                  )
                )
              ),
            ),
          )
        ]
      )
    );
  }

  Widget _buildEditableProfileItem(String label, TextEditingController controller, String hint, 
  {TextInputType keyboardType = TextInputType.text}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: Text(label, style: const TextStyle(color: Color(0xFF38664D), 
            fontSize: 18, fontWeight: FontWeight.w500)),
          ),
          Expanded(flex: 6, child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.black, fontSize: 18),
              decoration: InputDecoration(isDense: true, hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
                border: InputBorder.none, focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none, errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
    );
  }
}