import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/admin_explorar.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart'; 
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PerfilAdministrador extends StatefulWidget {
  final Administrador administrador;

  const PerfilAdministrador({super.key, required this.administrador});

  @override
  State<PerfilAdministrador> createState() => _PerfilAdministradorState();
}

class _PerfilAdministradorState extends State<PerfilAdministrador> {
  late TextEditingController _nombreController;
  late TextEditingController _correoController;

  final GestionUsuario _gestionUsuario = GestionUsuario();
  final GestionImagenPerfil _gestionImagen = GestionImagenPerfil();
  
  late Administrador _adminActual;
  bool _subiendoImagen = false;

  @override
  void initState() {
    super.initState();
    _adminActual = widget.administrador;

    _nombreController = TextEditingController(text: _adminActual.nombre);
    _correoController = TextEditingController(text: _adminActual.email);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
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
                      Text(_adminActual.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF216A44),
                        backgroundImage: _adminActual.imagenUrl != null && _adminActual.imagenUrl!.isNotEmpty
                            ? NetworkImage(_adminActual.imagenUrl!)
                            : null,
                        child: _adminActual.imagenUrl == null || _adminActual.imagenUrl!.isEmpty
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
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeAdmin(administrador: widget.administrador)),
                    );
                  },
                  icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                  label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AdminExplorar(administrador: widget.administrador)),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: widget.administrador)),
                    );
                  },
                  icon: const Icon(Icons.person_add_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Usuarios', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed:() {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminModeracion(administrador: widget.administrador)));
                  },
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Moderación', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
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
                        const Text('Perfil de Administrador', style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat', 
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
                                        image: _adminActual.imagenUrl != null && _adminActual.imagenUrl!.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(_adminActual.imagenUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _adminActual.imagenUrl == null || _adminActual.imagenUrl!.isEmpty
                                          ? const Icon(Icons.person, size: 65, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      _adminActual.nombre,
                                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, 
                                      fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                                    ),
                                    const Text('Administrador', style: TextStyle(color: Color(0xFF6E867A), fontSize: 18)),
                                    const SizedBox(height: 25),
                                    
                                    // BOTÓN CAMBIAR FOTO 
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
                                              _adminActual.id, 
                                              imagenSeleccionada
                                            );

                                            if (urlDescarga != null && context.mounted) {
                                              setState(() {
                                                _adminActual = Administrador(
                                                  id: _adminActual.id,
                                                  nombre: _adminActual.nombre,
                                                  email: _adminActual.email,
                                                  fechaRegistro: _adminActual.fechaRegistro,
                                                  suspendido: _adminActual.suspendido,
                                                  imagenUrl: urlDescarga, 
                                                  nivelAcceso: _adminActual.nivelAcceso, 
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
                                    _buildProfileInputField('Correo electrónico', _correoController, isEditable: false),
                                    const SizedBox(height: 30),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          Map<String, dynamic> datosActualizados = {
                                            'nombre': _nombreController.text,
                                            'email': _correoController.text,
                                          };

                                          await _gestionUsuario.editarInformacion(_adminActual.id, datosActualizados);

                                          if (context.mounted) {
                                            setState(() {
                                              _adminActual = Administrador(
                                                  id: _adminActual.id,
                                                  nombre: _adminActual.nombre,
                                                  email: _adminActual.email,
                                                  fechaRegistro: _adminActual.fechaRegistro,
                                                  suspendido: _adminActual.suspendido,
                                                  imagenUrl: _adminActual.imagenUrl, 
                                                  nivelAcceso: _adminActual.nivelAcceso, 
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
            child: TextField(controller: controller, readOnly: !isEditable,
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