import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/viaj_mis_reservas.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PerfilViajero extends StatefulWidget {
  final Viajero viajero; 

  const PerfilViajero({super.key, required this.viajero});

  @override
  State<PerfilViajero> createState() => _PerfilViajeroState();
}

class _PerfilViajeroState extends State<PerfilViajero> {
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _cedulaController;
  late TextEditingController _ciudadController;

  final GestionUsuario _gestionUsuario = GestionUsuario();
  final GestionImagenPerfil _gestionImagen = GestionImagenPerfil();
  
  late Viajero _viajeroActual;
  bool _subiendoImagen = false;

  @override
  void initState() {
    super.initState();
    _viajeroActual = widget.viajero;

    _nombreController = TextEditingController(text: _viajeroActual.nombre);
    _correoController = TextEditingController(text: _viajeroActual.email);
    _telefonoController = TextEditingController(text: _viajeroActual.telefono);
    _cedulaController = TextEditingController(text: _viajeroActual.cedula);
    _ciudadController = TextEditingController(text: _viajeroActual.ciudad);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _cedulaController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, 
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain,),
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
                      Text( _viajeroActual.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF216A44),
                        backgroundImage: _viajeroActual.imagenUrl != null && _viajeroActual.imagenUrl!.isNotEmpty
                            ? NetworkImage(_viajeroActual.imagenUrl!)
                            : null,
                        child: _viajeroActual.imagenUrl == null || _viajeroActual.imagenUrl!.isEmpty
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
                TextButton.icon(onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeViajero(viajero: _viajeroActual),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                  label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,)),
                ),
                TextButton.icon(onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: _viajeroActual),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25, )),
                ),
                TextButton.icon(onPressed: null,
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
                child: Padding(padding: const EdgeInsets.only(top: 40, bottom: 40),
                  child: SizedBox(width: 992, 
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mi Perfil', style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat', 
                        fontWeight: FontWeight.w800, fontSize: 30),
                        ),
                        const SizedBox(height: 24),
                        Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4,
                              child: Container(padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                decoration: BoxDecoration(color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  children: [
                                    Container(width: 130, height: 130, 
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF38664D), 
                                        shape: BoxShape.circle,
                                        image: _viajeroActual.imagenUrl != null && _viajeroActual.imagenUrl!.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(_viajeroActual.imagenUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _viajeroActual.imagenUrl == null || _viajeroActual.imagenUrl!.isEmpty
                                          ? const Icon(Icons.person, size: 65, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      _viajeroActual.nombre,
                                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, 
                                      fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                                    ),
                                    const Text('Viajero', style: TextStyle(color: Color(0xFF6E867A), fontSize: 18)),
                                    const SizedBox(height: 25),
                                    // BOTÓN CAMBIAR FOTO INTEGRADO
                                    OutlinedButton(
                                      onPressed: _subiendoImagen ? null : () async {
                                        final ImagePicker picker = ImagePicker();
                                        final XFile? imagenSeleccionada = await picker.pickImage(
                                          source: ImageSource.gallery,
                                          imageQuality: 80,
                                        );

                                        if (imagenSeleccionada != null) {
                                          setState(() => _subiendoImagen = true);
                                          try {
                                            String? urlDescarga = await _gestionImagen.subirImagen(
                                              _viajeroActual.id, 
                                              imagenSeleccionada
                                            );

                                            if (urlDescarga != null && context.mounted) {
                                              setState(() {
                                                _viajeroActual = Viajero(
                                                  id: _viajeroActual.id,
                                                  nombre: _viajeroActual.nombre,
                                                  email: _viajeroActual.email,
                                                  fechaRegistro: _viajeroActual.fechaRegistro,
                                                  telefono: _viajeroActual.telefono,
                                                  cedula: _viajeroActual.cedula,
                                                  ciudad: _viajeroActual.ciudad,
                                                  historialReservas: _viajeroActual.historialReservas,
                                                  suspendido: _viajeroActual.suspendido,
                                                  imagenUrl: urlDescarga, // <-- Asignación de la nueva URL
                                                );
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('¡Foto de perfil actualizada con éxito!')),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error al subir imagen: $e')),
                                              );
                                            }
                                          } finally {
                                            if (context.mounted) {
                                              setState(() => _subiendoImagen = false);
                                            }
                                          }
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFCCCCCC)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                        minimumSize: const Size(200, 50),
                                        backgroundColor: const Color(0xFFF5F7F2),
                                      ),
                                      child: _subiendoImagen 
                                          ? const SizedBox(width: 20, height: 20, 
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38664D)),
                                            )
                                          : const Text('Cambiar Foto', style: TextStyle(color: Colors.black, fontSize: 16)),
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
                            const SizedBox(width: 32),
                            Expanded(flex: 6,
                              child: Container(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                decoration: BoxDecoration(color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildProfileInputField('Nombre', _nombreController),
                                    _buildDivider(),
                                    _buildProfileInputField('Correo', _correoController, isEditable: false),
                                    _buildDivider(),
                                    _buildProfileInputField('Teléfono', _telefonoController),
                                    _buildDivider(),
                                    _buildProfileInputField('Cédula', _cedulaController),
                                    _buildDivider(),
                                    _buildProfileInputField('Ciudad', _ciudadController),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          Map<String, dynamic> datosActualizados = {
                                            'nombre': _nombreController.text,
                                            'email': _correoController.text,
                                            'telefono': _telefonoController.text,
                                            'cedula': _cedulaController.text,
                                            'ciudad': _ciudadController.text,
                                          };

                                          await _gestionUsuario.editarInformacion(_viajeroActual.id, datosActualizados);

                                          if (context.mounted) {
                                            setState(() {
                                              _viajeroActual = Viajero(
                                                id: _viajeroActual.id,
                                                nombre: _nombreController.text,
                                                email: _correoController.text,
                                                fechaRegistro: _viajeroActual.fechaRegistro,
                                                telefono: _telefonoController.text,
                                                cedula: _cedulaController.text,
                                                ciudad: _ciudadController.text,
                                                historialReservas: _viajeroActual.historialReservas,
                                                suspendido: _viajeroActual.suspendido,
                                                imagenUrl: _viajeroActual.imagenUrl
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
                                        backgroundColor: const Color(0xFF38664D), foregroundColor: Colors.white,
                                        elevation: 0, shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]
      )
    );
  }

  Widget _buildProfileInputField(String label, TextEditingController controller, {bool isEditable = true}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 4, 
            child: Text(label, style: const TextStyle(color: Color(0xFF38664D), fontSize: 18, 
            fontWeight: FontWeight.w500)),
          ),
          Expanded(flex: 6, 
            child: TextField(
              controller: controller,
              readOnly: !isEditable,
              style: TextStyle(color: isEditable ? Colors.black : Colors.grey, fontSize: 18),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
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