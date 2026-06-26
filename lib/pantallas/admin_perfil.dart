import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/gestion_usuario.dart';
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

  Future<void> _logout(BuildContext context) async {
    try {
      await _gestionUsuario.cerrarSesion();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada con éxito')),
        );
        Navigator.pushAndRemoveUntil(
          context,
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
  }

  Future<void> _cambiarImagenPerfil() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _subiendoImagen = true;
    });

    try {
      String? nuevaUrl = await _gestionImagen.subirImagen(_adminActual.id, image,
      );

      if (nuevaUrl != null) {
        setState(() {
          _adminActual.imagenUrl = nuevaUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen de perfil actualizada correctamente.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _subiendoImagen = false;
      });
    }
  }

  Future<void> _actualizarDatosPerfil() async {
    final nuevoNombre = _nombreController.text.trim();

    if (nuevoNombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await _gestionUsuario.editarInformacion(_adminActual.id, {'nombre' : nuevoNombre});
      setState(() {
        _adminActual.nombre = nuevoNombre;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar datos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  List<Widget> _buildNavItems(BuildContext context, {bool isVertical = false}) {
    final double fontSize = isVertical ? 18 : 22;
    return [
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeAdmin(administrador: _adminActual)));
        },
        icon: Icon(Icons.dns, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Dashboard', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminExplorar(administrador: _adminActual)));
        },
        icon: Icon(Icons.search, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Explorar', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: _adminActual)));
        },
        icon: Icon(Icons.person_add_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Usuarios', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminModeracion(administrador: _adminActual)));
        },
        icon: Icon(Icons.shield_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Moderación', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: null,
        icon: Icon(Icons.person_outline, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Perfil', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize, fontWeight: FontWeight.w900)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double anchoPantalla = MediaQuery.of(context).size.width;
    bool esDesktop = anchoPantalla > 950;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), 
        toolbarHeight: esDesktop ? 90 : 70, 
        centerTitle: esDesktop ? true : false,
        leading: esDesktop 
          ? Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
            )
          : null,
        title: esDesktop 
          ? SizedBox(
              width: 400,
              child: SearchBar(
                hintText: 'Buscar...', 
                hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
                leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
                backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
                elevation: const WidgetStatePropertyAll(0),
              ),
            )
          : const Text('Mi Perfil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: esDesktop ? 20.0 : 10.0),
            child: InkWell(
              onTap: () => _logout(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (esDesktop) ...[
                      Text(
                        _adminActual.nombre, 
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 1, 
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                    ],
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
        ],
      ),
      drawer: !esDesktop 
        ? Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF216A44)),
                  accountName: Text(_adminActual.nombre),
                  accountEmail: Text(_adminActual.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: _adminActual.imagenUrl != null && _adminActual.imagenUrl!.isNotEmpty
                        ? NetworkImage(_adminActual.imagenUrl!)
                        : null,
                    child: _adminActual.imagenUrl == null || _adminActual.imagenUrl!.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                ..._buildNavItems(context, isVertical: true),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  onTap: () => _logout(context),
                )
              ],
            ),
          )
        : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          if (esDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: _buildNavItems(context),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: esDesktop ? 40.0 : 16.0, 
                vertical: 20.0
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Container(
                    padding: EdgeInsets.all(anchoPantalla > 600 ? 40.0 : 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), 
                          blurRadius: 15, 
                          offset: const Offset(0, 5)
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuración del Perfil', 
                          style: TextStyle(
                            fontSize: esDesktop ? 36 : 28, 
                            fontFamily: 'Idiqlat', 
                            color: Colors.black, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 30),

                        // ENCABEZADO DE PERFIL (FLEX DINÁMICO)
                        Flex(
                          direction: anchoPantalla > 600 ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: anchoPantalla > 600 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: const Color(0xFF38664D),
                                  backgroundImage: _adminActual.imagenUrl != null && _adminActual.imagenUrl!.isNotEmpty
                                      ? NetworkImage(_adminActual.imagenUrl!)
                                      : null,
                                  child: _adminActual.imagenUrl == null || _adminActual.imagenUrl!.isEmpty
                                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                                      : null,
                                ),
                                if (_subiendoImagen)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(60),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF216A44),
                                    child: IconButton(
                                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                      onPressed: _subiendoImagen ? null : _cambiarImagenPerfil,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: anchoPantalla > 600 ? 30 : 0, height: anchoPantalla > 600 ? 0 : 20),
                            Expanded(
                              flex: anchoPantalla > 600 ? 1 : 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _adminActual.nombre, 
                                    style: TextStyle(
                                      fontSize: anchoPantalla > 600 ? 28 : 22, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.black, 
                                      fontFamily: 'Idiqlat'
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Administrador Principal', 
                                    style: TextStyle(fontSize: 16, color: Color(0xFF6E867A)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: anchoPantalla > 600 ? 15 : 0, height: anchoPantalla > 600 ? 0 : 25),
                            SizedBox(
                              width: anchoPantalla > 600 ? null : double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF216A44),
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 0,
                                ),
                                onPressed: _actualizarDatosPerfil,
                                child: const Text(
                                  'Guardar Cambios', 
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                        const Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
                        const SizedBox(height: 20),

                        // FORMULARIO DE CAMPOS DE EDICIÓN
                        _buildProfileInputField('Nombre Completo', _nombreController, anchoPantalla, isEditable: true),
                        _buildDivider(),
                        _buildProfileInputField('Correo Electrónico', _correoController, anchoPantalla, isEditable: false),
                        _buildDivider(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInputField(String label, TextEditingController controller, double anchoPantalla, {bool isEditable = true}) {
    bool usarLayoutHorizontal = anchoPantalla > 550;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Flex(
        direction: usarLayoutHorizontal ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: usarLayoutHorizontal ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: usarLayoutHorizontal ? 260 : double.infinity,
            child: Text(
              label, 
              style: const TextStyle(color: Color(0xFF38664D), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (!usarLayoutHorizontal) const SizedBox(height: 6),
          Expanded(
            flex: usarLayoutHorizontal ? 1 : 0,
            child: TextField(
              controller: controller, 
              readOnly: !isEditable,
              style: TextStyle(color: isEditable ? Colors.black : Colors.grey.shade600, fontSize: 18),
              decoration: const InputDecoration(
                border: InputBorder.none, 
                isDense: true,
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
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: Color(0xFFF0F2EE), thickness: 1.0),
    );
  }
}