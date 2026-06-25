import 'package:ecostay/models/buscador_exploracion.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/anf_pub.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/anf_reservas.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/anf_perfil.dart';
import 'package:ecostay/pantallas/pag_inicio.dart'; 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PantallaPublicaciones extends StatefulWidget {
  final PrestadorServicio prestador;
  
  const PantallaPublicaciones({super.key, required this.prestador});

  @override
  State<PantallaPublicaciones> createState() => _PantallaPublicacionesState();
}

class _PantallaPublicacionesState extends State<PantallaPublicaciones> {
  final GestionUsuario _gestionUsuario = GestionUsuario();
  final TextEditingController _searchController = TextEditingController();
  
  String _textoBusqueda = '';
  late Future<void> _cargarDatosFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatosFuture = widget.prestador.cargarMisDatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _mostrarDialogoPublicacion(BuildContext context, {Publicacion? publicacionAEditar}) {
    final bool esEdicion = publicacionAEditar != null;

    final TextEditingController tituloController = TextEditingController(
      text: esEdicion ? publicacionAEditar.titulo : '');
    final TextEditingController ubicacionController = TextEditingController(
      text: esEdicion ? publicacionAEditar.ubicacion : '');
    final TextEditingController precioController = TextEditingController(
      text: esEdicion ? publicacionAEditar.precio.toString() : '');
    final TextEditingController descripcionController = TextEditingController(
      text: esEdicion ? publicacionAEditar.descripcion : '');
    final TextEditingController policancelacionController = TextEditingController(
      text: esEdicion ? publicacionAEditar.politicaCancelacion : '');
    
    final TextEditingController cuposController = TextEditingController(
      text: esEdicion ? (publicacionAEditar.cuposMax?.toString() ?? '1') : '1');
    final TextEditingController estiloController = TextEditingController(
      text: esEdicion ? (publicacionAEditar.estilo ?? '') : '');

    bool transporteDisponible = esEdicion ? publicacionAEditar.disponibilidadtransporte : false;
    XFile? imagenSeleccionada;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context, barrierDismissible: false, 
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          Future<void> seleccionarImagen() async {
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setState(() {
                imagenSeleccionada = image;
              });
            }
          }
          return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), backgroundColor: ColorPalette.bg,
          title: Text(esEdicion ? 'Editar Publicación' : 'Crear Nueva Publicación',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF216A44), fontFamily: 'Idiqlat'),
          ),
          content: SizedBox(width: 450,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min,
                children: [
                  Text(esEdicion 
                    ? 'Modifica los datos de tu publicación.' : 'Ingresa los datos de tu nueva posada o servicio.'),
                  const SizedBox(height: 20),
                  GestureDetector(onTap: seleccionarImagen,
                    child: Container(height: 150, width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF216A44), width: 1, style: BorderStyle.solid),
                      ),
                      child: imagenSeleccionada != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(10),
                              child: kIsWeb
                                  ? Image.network(imagenSeleccionada!.path, fit: BoxFit.cover)
                                  : Image.file(File(imagenSeleccionada!.path), fit: BoxFit.cover),
                            )
                          : const Column(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFF216A44)),
                                SizedBox(height: 8),
                                Text('Toca para subir una foto', style: TextStyle(color: Color(0xFF216A44))),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: tituloController,
                    decoration: InputDecoration(labelText: 'Título de la Publicación',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF216A44), width: 2),),),
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: descripcionController, maxLines: 3,
                    decoration: InputDecoration(labelText: 'Descripción',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF216A44), width: 2),),),
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: estiloController,
                    decoration: InputDecoration(
                      labelText: 'Estilo de hospedaje',
                      hintText: 'Ej. montaña, playa, bosque',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF216A44), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: ubicacionController,
                    decoration: InputDecoration(labelText: 'Ubicación (Ej. Los Roques)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF216A44), width: 2),),),
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: policancelacionController,
                    decoration: InputDecoration(labelText: 'Política de cancelación',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF216A44), width: 2),),),
                  ),
                  const SizedBox(height: 15),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cuposController, keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Cupos Max',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF216A44), width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      Expanded(
                        child: TextField(
                          controller: precioController, keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Precio (\$)',
                            prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF216A44), size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF216A44), width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              transporteDisponible = !transporteDisponible;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400),
                              color: transporteDisponible ? const Color(0xFFE2ECE7) : Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_bus,
                                  color: transporteDisponible ? const Color(0xFF216A44) : Colors.grey.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                const Text('¿Transporte?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF216A44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (tituloController.text.isEmpty || ubicacionController.text.isEmpty || 
                    precioController.text.isEmpty || descripcionController.text.isEmpty || cuposController.text.isEmpty) { 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, llena todos los campos.')),
                  );
                  return;
                }

                try {
                  GestionPublicacion gestionPub = GestionPublicacion();
                  GestionImagenPublicacion gestionImg = GestionImagenPublicacion();
                  
                  int cuposMax = int.tryParse(cuposController.text) ?? 1;
                  String estiloFinal = estiloController.text.trim().isEmpty ? 'Otros' : estiloController.text.trim();

                  if (esEdicion) {
                    await gestionPub.editarPublicacion(
                      publicacionAEditar.id, 
                      {
                        'titulo': tituloController.text,
                        'descripcion': descripcionController.text,
                        'precio': double.parse(precioController.text),
                        'ubicacion': ubicacionController.text,
                        'politicaCancelacion': policancelacionController.text,
                        'transporte': transporteDisponible,
                        'estilo': estiloFinal,
                        'cuposMax': cuposMax,
                      }
                    );
                    if (imagenSeleccionada != null) {
                      await gestionImg.subirImagen(publicacionAEditar.id, imagenSeleccionada!);
                    }
                  } else {
                    String nuevoId = await gestionPub.crearPublicacion({
                      'titulo': tituloController.text,
                      'descripcion': descripcionController.text,
                      'precio': double.parse(precioController.text),
                      'ubicacion': ubicacionController.text,
                      'providerId': widget.prestador.id,
                      'autoruid': widget.prestador.id, 
                      'disponibilidadtransporte': transporteDisponible,
                      'politicaCancelacion': policancelacionController.text,
                      'nombreAnfitrion': widget.prestador.nombre,
                      'estilo': estiloFinal,
                      'cuposMax': cuposMax,
                      'cuposActual': 0,
                      'calificacionPromedio': 0.0,
                    });
                    if (imagenSeleccionada != null) {
                      await gestionImg.subirImagen(nuevoId, imagenSeleccionada!);
                    }
                  }
                  
                  if (!context.mounted) return;
                  
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(esEdicion ? '¡Publicación actualizada exitosamente!' 
                      : '¡Publicación creada exitosamente!'), backgroundColor: const Color(0xFF216A44),
                    ),
                  );

                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: widget.prestador)),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(esEdicion ? 'Guardar Cambios' : 'Publicar', style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        );});
      },
    );
  }

  void _eliminarPublicacion(BuildContext context, String publicacionId) {
    showDialog(context: context,
      builder: (BuildContext context) {
        return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Eliminar Publicación', style: TextStyle(color: Color(0xFF903030), 
          fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas eliminar esta publicación? Esta acción no se puede deshacer.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF903030),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                try {
                  GestionPublicacion gestionPub = GestionPublicacion();
                  await gestionPub.eliminarPublicacion(publicacionId);

                  if (!context.mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación eliminada exitosamente'),
                      backgroundColor: Color(0xFF216A44),
                    ),
                  );

                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: widget.prestador)),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              },
              child: const Text('Eliminar', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;
    
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
        ),
        title: SearchBar(
          controller: _searchController,
          hintText: 'Buscar por título...', 
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
          onChanged: (value) {
            setState(() {
              _textoBusqueda = value;
            });
          }, 
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
                      Text( widget.prestador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                      backgroundColor: const Color(0xFF216A44),
                      backgroundImage: (widget.prestador.imagenUrl != null && widget.prestador.imagenUrl!.isNotEmpty)
                          ? NetworkImage(widget.prestador.imagenUrl!)
                          : null,
                      child: (widget.prestador.imagenUrl == null || widget.prestador.imagenUrl!.isEmpty)
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
      
      body: FutureBuilder<void>(
        future: _cargarDatosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF216A44)),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar datos: ${snapshot.error}'),
            );
          }

          final publicacionesFiltradas = widget.prestador.publicaciones.where((pub) {
            return pub.titulo.toLowerCase().contains(_textoBusqueda.toLowerCase());
          }).toList();

          return Column(crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Padding(padding: const EdgeInsets.only(top: 15),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  children: [
                    TextButton.icon(
                      onPressed: () {Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeAnfitrion(prestador: widget.prestador)),
                      );
                    },  
                      icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                      label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                    ),
                    TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.upload, color: Color(0xFF216A44), size: 28),
                      label: const Text('Publicaciones', style: TextStyle(color: Color(0xFF216A44), fontSize: 25, 
                      fontWeight: FontWeight.w900)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: widget.prestador),
                          ),
                        );
                      }, 
                      icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                      label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                    ),
                    TextButton.icon(
                      onPressed: () {Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PerfilAnfitrion(prestador: widget.prestador)),
                      );
                    }, 
                      icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                      label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Stack(
                  children: [
                    SizedBox(width: double.infinity,
                      child: publicacionesFiltradas.isEmpty
                          ? Center(
                              child: Text(
                                _textoBusqueda.isEmpty 
                                    ? 'Aún no tienes publicaciones creadas.'
                                    : 'No se encontraron resultados para "$_textoBusqueda"',
                                style: const TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(left: 40.0, top: 40.0, bottom: 40.0, right: 120.0),
                              child: Wrap(alignment: WrapAlignment.center, spacing: 30.0, runSpacing: 30.0,
                                children: publicacionesFiltradas.map((pub) {
                                  return _buildPublicacionCard(
                                    context: context,
                                    pub: pub,
                                    titulo: pub.titulo,
                                    subtitulo: pub.ubicacion,
                                    precio: pub.precio,
                                    puntuacion: pub.calificacionPromedio,
                                    imagenUrl: (pub.imagenUrl != null && pub.imagenUrl!.isNotEmpty) 
                                        ? pub.imagenUrl! 
                                        : 'https://images.unsplash.com/photo-1506929562872-bb421503ef21?q=80&w=600&auto=format&fit=crop', 
                                    onEdit: () => _mostrarDialogoPublicacion(context, publicacionAEditar: pub),
                                    onDelete: () => _eliminarPublicacion(context, pub.id),
                                  );
                                }).toList(),
                              ),
                            ),
                    ),

                    Align(alignment: Alignment.centerRight,
                      child: Padding(padding: const EdgeInsets.only(right: 40.0),
                        child: SizedBox(width: 65, height: 65,
                          child: FloatingActionButton(backgroundColor: const Color(0xFF1E6144), 
                            onPressed: () => _mostrarDialogoPublicacion(context),
                            shape: const CircleBorder(), 
                            child: const Icon(Icons.note_add_outlined, color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPublicacionCard({
    required BuildContext context,
    required Publicacion pub,
    required String titulo,
    required String subtitulo,
    required double precio,
    required double puntuacion,
    required String imagenUrl,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(width: 350, 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),
              topRight: Radius.circular(20),), child: Image.network(imagenUrl, 
                height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(top: 15, right: 15,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFC7E08F), borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(puntuacion.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),

          Padding(padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Idiqlat'),
                ),
                const SizedBox(height: 4),
                Text(subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Idiqlat'),
                ),
              ],
            ),
          ),
          
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
          ),
          
          Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Align(alignment: Alignment.centerRight,
              child: Text('\$$precio', maxLines: 1, overflow: TextOverflow.ellipsis, 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF216A44)),
              ),
            ),
          ),
          
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
          ),
          
          Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionBtn(Icons.visibility_outlined, const Color(0xFF216A44), () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaPubReserv(
                        publicacion: pub, prestador: widget.prestador,),),
                  );
                }),
                _buildActionBtn(Icons.edit_outlined, const Color(0xFF216A44), onEdit), 
                _buildActionBtn(Icons.delete_outline, const Color(0xFF903030), onDelete), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        constraints: const BoxConstraints(), 
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}