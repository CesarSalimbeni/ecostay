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
  
  final ImagePicker _picker = ImagePicker();
  bool _subiendoImagen = false;

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

  Future<void> _logout() async {
    try {
      await _gestionUsuario.cerrarSesion();
      if (mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Future<void> _cambiarImagenPerfil() async {
    try {
      final XFile? imagenSeleccionada = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (imagenSeleccionada == null) return;

      setState(() {
        _subiendoImagen = true;
      });

      final gestionImagen = GestionImagenPerfil();
      String? nuevaUrl;

        nuevaUrl = await gestionImagen.subirImagen(_prestadorActual.id, imagenSeleccionada);

      setState(() {
        _prestadorActual = PrestadorServicio(
          id: _prestadorActual.id,
          nombre: _prestadorActual.nombre,
          email: _prestadorActual.email,
          telefono: _prestadorActual.telefono,
          suspendido: _prestadorActual.suspendido,
          rif: _prestadorActual.rif,
          direccion: _prestadorActual.direccion,
          cuentaPayPal: _prestadorActual.cuentaPayPal,
          imagenUrl: nuevaUrl,
          fechaRegistro: _prestadorActual.fechaRegistro,
          estadisticas: []
        );
        _subiendoImagen = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen de perfil actualizada con éxito')),
        );
      }
    } catch (e) {
      setState(() {
        _subiendoImagen = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la imagen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _guardarCambiosPerfil() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      Map<String, dynamic> datosAActualizar = {
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'rif': _rifController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'cuentaPayPal': _paypalController.text.trim(),
      };

      await _gestionUsuario.editarInformacion(_prestadorActual.id, datosAActualizar);

      setState(() {
        _prestadorActual = PrestadorServicio(
          id: _prestadorActual.id,
          nombre: _nombreController.text.trim(),
          email: _prestadorActual.email,
          telefono: _telefonoController.text.trim(),
          suspendido: _prestadorActual.suspendido,
          rif: _rifController.text.trim(),
          direccion: _direccionController.text.trim(),
          cuentaPayPal: _paypalController.text.trim(),
          imagenUrl: _prestadorActual.imagenUrl,
          fechaRegistro: _prestadorActual.fechaRegistro,
          estadisticas: [],
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar cambios: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Widget> _buildNavItems(BuildContext context, {bool isVertical = false}) {
    final double fontSize = isVertical ? 18 : 22;
    return [
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeAnfitrion(prestador: _prestadorActual)));
        }, 
        icon: Icon(Icons.dns, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Dashboard', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: _prestadorActual)));
        }, 
        icon: Icon(Icons.upload, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Publicaciones', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: _prestadorActual)));
        },
        icon: Icon(Icons.send_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Reservas', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
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
        leadingWidth: esDesktop ? 120 : null,
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
              onTap: _logout,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (esDesktop) ...[
                      Text(
                        _prestadorActual.nombre, 
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 1, 
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                    ],
                    CircleAvatar(
                      backgroundColor: const Color(0xFF216A44),
                      backgroundImage: (_prestadorActual.imagenUrl != null && _prestadorActual.imagenUrl!.isNotEmpty)
                          ? NetworkImage(_prestadorActual.imagenUrl!)
                          : null,
                      child: (_prestadorActual.imagenUrl == null || _prestadorActual.imagenUrl!.isEmpty)
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
                  accountName: Text(_prestadorActual.nombre),
                  accountEmail: Text(_prestadorActual.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: (_prestadorActual.imagenUrl != null && _prestadorActual.imagenUrl!.isNotEmpty)
                        ? NetworkImage(_prestadorActual.imagenUrl!)
                        : null,
                    child: (_prestadorActual.imagenUrl == null || _prestadorActual.imagenUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                ..._buildNavItems(context, isVertical: true),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  onTap: _logout,
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
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: _buildNavItems(context),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: esDesktop ? 40.0 : 16.0, 
                vertical: 30.0
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Container(
                    padding: EdgeInsets.all(anchoPantalla > 600 ? 40.0 : 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información de Perfil', 
                          style: TextStyle(
                            fontSize: anchoPantalla > 600 ? 32 : 26, 
                            fontFamily: 'Idiqlat', 
                            color: Colors.black, 
                            fontWeight: FontWeight.w800
                          ),
                        ),
                        const SizedBox(height: 30),

                        // LAYOUT CONFIGURABLE DE PERFIL (FLEX)
                        Flex(
                          direction: anchoPantalla > 800 ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: anchoPantalla > 800 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                          children: [
                            // SECCIÓN FOTO IZQUIERDA / ARRIBA
                            Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: anchoPantalla > 600 ? 110 : 80,
                                      backgroundColor: const Color(0xFFF0F2EE),
                                      backgroundImage: (_prestadorActual.imagenUrl != null && _prestadorActual.imagenUrl!.isNotEmpty)
                                          ? NetworkImage(_prestadorActual.imagenUrl!)
                                          : null,
                                      child: (_prestadorActual.imagenUrl == null || _prestadorActual.imagenUrl!.isEmpty) && !_subiendoImagen
                                          ? Icon(Icons.person, size: anchoPantalla > 600 ? 110 : 80, color: Colors.grey)
                                          : null,
                                    ),
                                    if (_subiendoImagen)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black45,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                OutlinedButton.icon(
                                  onPressed: _subiendoImagen ? null : _cambiarImagenPerfil,
                                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
                                  label: const Text('Cambiar foto', style: TextStyle(color: Colors.black, fontSize: 16)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(width: anchoPantalla > 800 ? 50 : 0, height: anchoPantalla > 800 ? 0 : 40),

                            // SECCIÓN FORMULARIO DERECHA / ABAJO
                            Expanded(
                              flex: anchoPantalla > 800 ? 1 : 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEditableProfileItem('Nombre', _nombreController, 'Ingresa tu nombre completo'),
                                  _buildDivider(),
                                  _buildEditableProfileItem('Correo', _emailController, 'Tu dirección de correo', enabled: false),
                                  _buildDivider(),
                                  _buildEditableProfileItem('Teléfono', _telefonoController, 'Ingresa tu número telefónico', keyboardType: TextInputType.phone),
                                  _buildDivider(),
                                  _buildEditableProfileItem('Rif', _rifController, 'Ingresa tu RIF comercial o personal'),
                                  _buildDivider(),
                                  _buildEditableProfileItem('Dirección Fiscal', _direccionController, 'Ingresa tu dirección comercial'),
                                  _buildDivider(),
                                  _buildEditableProfileItem('Cuenta PayPal', _paypalController, 'Ingresa tu correo vinculado a PayPal', keyboardType: TextInputType.emailAddress),
                                  _buildDivider(),
                                  
                                  const SizedBox(height: 35),
                                  
                                  SizedBox(
                                    width: anchoPantalla > 600 ? 200 : double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _guardarCambiosPerfil,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF216A44),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Guardar Cambios',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEditableProfileItem(String label, TextEditingController controller, String hint, 
  {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool usarApilado = constraints.maxWidth < 450;
          return Flex(
            direction: usarApilado ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: usarApilado ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: usarApilado ? double.infinity : 150,
                child: Text(
                  label, 
                  style: const TextStyle(color: Color(0xFF38664D), fontSize: 18, fontWeight: FontWeight.w500)
                ),
              ),
              if (usarApilado) const SizedBox(height: 4),
              Expanded(
                flex: usarApilado ? 0 : 1,
                child: TextFormField(
                  controller: controller, 
                  keyboardType: keyboardType, 
                  enabled: enabled,
                  style: TextStyle(color: enabled ? Colors.black : Colors.grey.shade500, fontSize: 18),
                  decoration: InputDecoration(
                    isDense: true, 
                    hintText: hint,
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
                    border: InputBorder.none, 
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none, 
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none, 
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
    );
  }
}