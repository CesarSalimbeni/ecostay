import 'dart:math';
import 'dart:io'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:ecostay/pantallas/anf_publicaciones.dart';
import 'package:ecostay/pantallas/anf_reservas.dart';
import 'package:ecostay/pantallas/anf_home.dart';
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

  XFile? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();
  bool _cargandoDatos = true;

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

    _initPerfil();
  }

  Future<void> _initPerfil() async {
    try {
      final usuarioFresco = await _gestionUsuario.obtenerInformacion(widget.prestador.id);
      
      if (mounted && usuarioFresco is PrestadorServicio) {
        setState(() {
          _prestadorActual = usuarioFresco;
          
          _nombreController.text = _prestadorActual.nombre;
          _emailController.text = _prestadorActual.email;
          _telefonoController.text = _prestadorActual.telefono;
          _rifController.text = _prestadorActual.rif;
          _direccionController.text = _prestadorActual.direccion;
          _paypalController.text = _prestadorActual.cuentaPayPal;
          _cargandoDatos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoDatos = false);
      }
    }
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

  Future<void> _seleccionarImagen() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagenSeleccionada = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoDatos) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF38664D))),
      );
    }
    return Scaffold(backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(padding: const EdgeInsets.only(left: 40.0),
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
          Padding(padding: const EdgeInsets.only(right: 20.0),
            child: Tooltip(message: 'Cerrar sesión', preferBelow: true, verticalOffset: 25,
              textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: BoxDecoration(color: const Color(0xFF216A44).withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () async {
                  try {
                    await _gestionUsuario.cerrarSesion();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sesión cerrada con éxito')),
                      );
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) => const PantallaInicio()),
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
                borderRadius: BorderRadius.circular(12),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(mainAxisSize: MainAxisSize.min,
                    children: [
                      Text( _prestadorActual.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF216A44),
                        backgroundImage: _imagenSeleccionada != null
                            ? (kIsWeb
                                ? NetworkImage(_imagenSeleccionada!.path)
                                : FileImage(File(_imagenSeleccionada!.path)) as ImageProvider)
                            : (_prestadorActual.imagenUrl != null && _prestadorActual.imagenUrl!.isNotEmpty)
                                ? NetworkImage(_prestadorActual.imagenUrl!)
                                : null,
                        child: (_imagenSeleccionada == null && (_prestadorActual.imagenUrl == null || _prestadorActual.imagenUrl!.isEmpty))
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                TextButton.icon(
                  onPressed: () {Navigator.pushReplacement(context,
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
                        
                        Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4,
                              child: Container(padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  children: [
                                    Container(width: 130, height: 130,
                                      decoration: const BoxDecoration(color: Color(0xFF38664D), shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: _imagenSeleccionada != null
                                            ? (kIsWeb
                                                ? Image.network(_imagenSeleccionada!.path, fit: BoxFit.cover)
                                                : Image.file(File(_imagenSeleccionada!.path), fit: BoxFit.cover))
                                            : (_prestadorActual.imagenUrl != null && _prestadorActual.imagenUrl!.isNotEmpty)
                                                ? Image.network(_prestadorActual.imagenUrl!, fit: BoxFit.cover)
                                                : const Icon(Icons.person, color: Colors.white, size: 70),
                                      ),
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
                                      onPressed: _seleccionarImagen, 
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
                                          await _gestionUsuario.cerrarSesion();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Sesión cerrada con éxito')),
                                            );
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
                            
                            Expanded(flex: 6,
                              child: Container(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                decoration: BoxDecoration(color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildEditableProfileItem('Responsable', _nombreController, 'No especificado'),
                                    _buildDivider(),
                                    // MODIFICADO: Correo deshabilitado
                                    _buildEditableProfileItem('Correo', _emailController, 'No especificado', 
                                        keyboardType: TextInputType.emailAddress),
                                    _buildDivider(),
                                    _buildEditableProfileItem('Teléfono', _telefonoController, 'No especificado', 
                                        keyboardType: TextInputType.phone),
                                    _buildDivider(),
                                    // MODIFICADO: RIF deshabilitado
                                    _buildEditableProfileItem('Rif', _rifController, 'No especificado', enabled: false),
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
                                          String? nuevaUrl = _prestadorActual.imagenUrl; 
                                            if (_imagenSeleccionada != null) {
                                              GestionImagenPerfil gestionImgPerfil = GestionImagenPerfil();
                                              
                                              final urlSubida = await gestionImgPerfil.subirImagen(_prestadorActual.id, _imagenSeleccionada!);
                                              
                                              if (urlSubida != null && urlSubida.isNotEmpty) {
                                                nuevaUrl = urlSubida;
                                                
                                                final usuarioAuth = FirebaseAuth.instance.currentUser;
                                                if (usuarioAuth != null) {
                                                  await usuarioAuth.updatePhotoURL(nuevaUrl);
                                                  await usuarioAuth.updateDisplayName(_nombreController.text);
                                                }
                                              }
                                            }
                                          
                                          Map<String, dynamic> datosActualizados = {
                                            'nombre': _nombreController.text,
                                            'email': _emailController.text,
                                            'telefono': _telefonoController.text,
                                            'rif': _rifController.text,
                                            'direccion': _direccionController.text,
                                            'cuentaPayPal': _paypalController.text,
                                            'imagenUrl': nuevaUrl ?? _prestadorActual.imagenUrl,
                                          };

                                          await _gestionUsuario.editarInformacion(_prestadorActual.id, datosActualizados);

                                          if (context.mounted) {
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
                                                suspendido: _prestadorActual.suspendido,
                                                imagenUrl: nuevaUrl,
                                              );
                                              _imagenSeleccionada = null;
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

  // MODIFICADO: Agregado el parámetro opcional `enabled` (por defecto true)
  Widget _buildEditableProfileItem(String label, TextEditingController controller, String hint, 
  {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: Text(label, style: const TextStyle(color: Color(0xFF38664D), 
            fontSize: 18, fontWeight: FontWeight.w500)),
          ),
          Expanded(flex: 6, child: TextFormField(
              controller: controller, keyboardType: keyboardType, enabled: enabled,
              style: TextStyle(color: enabled ? Colors.black : Colors.grey.shade500, fontSize: 18),
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