import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/anf_reservas.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/anf_perfil.dart'; 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PantallaPublicaciones extends StatelessWidget {
  final PrestadorServicio prestador;
  const PantallaPublicaciones({super.key, required this.prestador});

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
    bool transporteDisponible = esEdicion ? publicacionAEditar.disponibilidadtransporte : false;
    XFile? imagenSeleccionada;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,barrierDismissible: false, 
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(esEdicion ? 'Editar Publicación' : 'Crear Nueva Publicación',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF216A44)),
          ),
          content: SizedBox(width: 400,
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
                  TextField(controller: descripcionController,maxLines: 3,
                    decoration: InputDecoration(labelText: 'Descripción',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF216A44), width: 2),),),
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
                  SwitchListTile(title: const Text('¿Ofrece transporte?'), activeThumbColor: const Color(0xFF216A44),
                    value: transporteDisponible,onChanged: (bool value) {
                      setState(() {transporteDisponible = value;});
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300)
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: precioController,keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Precio por noche (\$)',
                      prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF216A44)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF216A44), width: 2),),),
                  ),
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
                    precioController.text.isEmpty ||descripcionController.text.isEmpty) { 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, llena todos los campos.')),
                  );
                  return;
                }

                try {
                  GestionPublicacion gestionPub = GestionPublicacion();
                  GestionImagenPublicacion gestionImg = GestionImagenPublicacion();
                  
                  if (esEdicion) {
                    await gestionPub.editarPublicacion(
                      publicacionAEditar.id, 
                      {'titulo': tituloController.text,
                        'descripcion': descripcionController.text,
                        'precio': double.parse(precioController.text),
                        'ubicacion': ubicacionController.text,
                        'politicaCancelacion': policancelacionController.text,
                        'transporte': transporteDisponible,
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
                      'providerId': prestador.id,
                      'autoruid': prestador.id, 
                      'disponibilidadtransporte': transporteDisponible,
                      'politicaCancelacion': policancelacionController.text,
                      'nombreAnfitrion': prestador.nombre,
                      'estilo': 'Otros',
                      'cuposMax': 1,
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
                      : '¡Publicación creada exitosamente!'),backgroundColor: const Color(0xFF216A44),
                    ),
                  );

                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: prestador)),
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
                    MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: prestador)),
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
          hintText: 'Buscar...', 
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
        ),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: Text(prestador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
            style: const TextStyle(fontSize: 20),
            ),
          ),
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF216A44),
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      
      body: FutureBuilder<void>(
        future: prestador.cargarMisDatos(),
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

          return Column(crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Padding(padding: const EdgeInsets.only(top: 15),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  children: [
                    TextButton.icon(
                      onPressed: () {Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeAnfitrion(prestador: prestador)),
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
                          MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: prestador),
                          ),
                        );
                      }, 
                      icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                      label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                    ),
                    TextButton.icon(
                      onPressed: () {Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PerfilAnfitrion(prestador: prestador)),
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
                      child: prestador.publicaciones.isEmpty
                          ? const Center(
                              child: Text(
                                'Aún no tienes publicaciones creadas.',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(left: 40.0, top: 40.0, bottom: 40.0, right: 120.0),
                              child: Wrap(alignment: WrapAlignment.center, spacing: 30.0, runSpacing: 30.0,
                                children: prestador.publicaciones.map((pub) {
                                  return _buildPublicacionCard(
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
                _buildActionBtn(Icons.visibility_outlined, const Color(0xFF216A44), () { /* Read view action */ }),
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