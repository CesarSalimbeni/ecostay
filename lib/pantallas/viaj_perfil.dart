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

  Future<void> _cambiarImagenPerfil() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _subiendoImagen = true);
      try {
        String? nuevaUrl = await _gestionImagen.subirImagen(_viajeroActual.id, image);
        if (nuevaUrl != null) {
          setState(() {
            _viajeroActual.imagenUrl = nuevaUrl;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imagen de perfil actualizada con éxito.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir la imagen: $e')),
          );
        }
      } finally {
        setState(() => _subiendoImagen = false);
      }
    }
  }

  Future<void> _guardarCambios() async {
    try {
      Map<String, dynamic> datosActualizados = {
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'cedula': _cedulaController.text.trim(),
        'ciudad': _ciudadController.text.trim(),
      };

      await _gestionUsuario.editarInformacion(_viajeroActual.id, datosActualizados);

      setState(() {
        _viajeroActual.nombre = datosActualizados['nombre'];
        _viajeroActual.telefono = datosActualizados['telefono'];
        _viajeroActual.cedula = datosActualizados['cedula'];
        _viajeroActual.ciudad = datosActualizados['ciudad'];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar cambios: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        toolbarHeight: isMobile ? 70 : 90,
        leadingWidth: isMobile ? 80 : 120,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: isMobile ? 10.0 : 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
        ),
        title: isMobile 
            ? null 
            : SearchBar(
                hintText: 'Buscar...',
                hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
                leading: const Icon(Icons.search, color: Color(0xFF526F75)),
                backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
                elevation: const WidgetStatePropertyAll(0),
              ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isMobile ? 10.0 : 20.0),
            child: InkWell(
              onTap: () async {
                try {
                  await _gestionUsuario.cerrarSesion();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaInicio()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isMobile) ...[
                      Text(_viajeroActual.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 18, color: Colors.black)),
                      const SizedBox(width: 10),
                    ],
                    CircleAvatar(
                      backgroundColor: const Color(0xFF216A44),
                      backgroundImage: _viajeroActual.imagenUrl != null && _viajeroActual.imagenUrl!.isNotEmpty ? NetworkImage(_viajeroActual.imagenUrl!) : null,
                      child: _viajeroActual.imagenUrl == null || _viajeroActual.imagenUrl!.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MENÚ DE NAVEGACIÓN SUPERIOR
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(Icons.search, 'Explorar', isMobile, () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeViajero(viajero: _viajeroActual)));
                }, activo: false),
                _buildNavButton(Icons.send_outlined, 'Reservas', isMobile, () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: _viajeroActual)));
                }, activo: false),
                _buildNavButton(Icons.person_outline, 'Perfil', isMobile, null, activo: true),
              ],
            ),
          ),

          // CONTENIDO DEL PERFIL SCROLLEABLE Y FLUIDO
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useVerticalForm = constraints.maxWidth < 850;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: useVerticalForm ? 16.0 : (width > 1200 ? 120.0 : 40.0),
                    vertical: 20
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: useVerticalForm 
                            ? _buildVerticalLayout(isMobile) 
                            : _buildHorizontalLayout(),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  // DISEÑO HORIZONTAL (PC / RECEPTÁCULOS AMPLIOS)
  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildAvatarSection()),
        const SizedBox(width: 45),
        Expanded(flex: 7, child: _buildFormSection(isMobile: false)),
      ],
    );
  }

  // DISEÑO VERTICAL (MÓVILES / TABLETS)
  Widget _buildVerticalLayout(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatarSection(),
        const SizedBox(height: 35),
        const Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
        const SizedBox(height: 15),
        _buildFormSection(isMobile: isMobile),
      ],
    );
  }

  // COMPONENTE FOTO DE PERFIL
  Widget _buildAvatarSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: const Color(0xFF38664D),
              backgroundImage: _viajeroActual.imagenUrl != null && _viajeroActual.imagenUrl!.isNotEmpty
                  ? NetworkImage(_viajeroActual.imagenUrl!)
                  : null,
              child: _viajeroActual.imagenUrl == null || _viajeroActual.imagenUrl!.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _subiendoImagen ? null : _cambiarImagenPerfil,
          icon: const Icon(Icons.camera_alt_outlined, size: 16),
          label: const Text('Cambiar foto', style: TextStyle(fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF38664D),
            side: const BorderSide(color: Color(0xFF38664D)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // COMPONENTE FORMULARIO DE EDICIÓN
  Widget _buildFormSection({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos Personales',
          style: TextStyle(fontSize: isMobile ? 22 : 26, fontFamily: 'Idiqlat', fontWeight: FontWeight.w800, color: Colors.black),
        ),
        const SizedBox(height: 20),
        _buildProfileInputField('Nombre Completo', _nombreController, isMobile: isMobile),
        _buildDivider(),
        _buildProfileInputField('Correo Electrónico', _correoController, isEditable: false, isMobile: isMobile),
        _buildDivider(),
        _buildProfileInputField('Teléfono móvil', _telefonoController, isMobile: isMobile),
        _buildDivider(),
        _buildProfileInputField('Documento / Cédula', _cedulaController, isMobile: isMobile),
        _buildDivider(),
        _buildProfileInputField('Ciudad / Estado', _ciudadController, isMobile: isMobile),
        const SizedBox(height: 35),
        Align(
          alignment: isMobile ? Alignment.center : Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _guardarCambios,
            icon: const Icon(Icons.check),
            label: const Text('Guardar Cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF216A44),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: isMobile ? const Size(double.infinity, 48) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInputField(String label, TextEditingController controller, {bool isEditable = true, required bool isMobile}) {
    // Si es móvil usamos un diseño apilado (Etiqueta arriba, Input abajo), de lo contrario usamos Row
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF38664D), fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              controller: controller,
              readOnly: !isEditable,
              style: TextStyle(color: isEditable ? Colors.black : Colors.grey, fontSize: 16),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: isEditable ? const UnderlineInputBorder() : InputBorder.none,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: const TextStyle(color: Color(0xFF38664D), fontSize: 18, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 6,
            child: TextField(
              controller: controller,
              readOnly: !isEditable,
              style: TextStyle(color: isEditable ? Colors.black : Colors.grey, fontSize: 18),
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
      child: Divider(color: Color(0xFFEBEBEB), thickness: 1.2),
    );
  }

  Widget _buildNavButton(IconData icon, String label, bool isMobile, VoidCallback? onTap, {required bool activo}) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: const Color(0xFF216A44), size: isMobile ? 22 : 28),
      label: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF216A44),
          fontSize: isMobile ? 16 : 22,
          fontWeight: activo ? FontWeight.w900 : FontWeight.normal,
        ),
      ),
    );
  }
}