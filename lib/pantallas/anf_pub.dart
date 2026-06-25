import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/anf_publicaciones.dart';
import 'package:ecostay/pantallas/anf_reservas.dart';
import 'package:ecostay/pantallas/anf_perfil.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/pantallas/estilo.dart';

class PantallaPubReserv extends StatefulWidget {
  final Publicacion publicacion;
  final PrestadorServicio prestador;

  const PantallaPubReserv({super.key, required this.publicacion, required this.prestador});

  @override
  State<PantallaPubReserv> createState() => _PantallaPubReservState();
}

class _PantallaPubReservState extends State<PantallaPubReserv> {
  bool _cargandoCalificaciones = true;
  final GestionUsuario _gestionUsuario = GestionUsuario();

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    try {
      final gestionCalificacion = GestionCalificacion();
      final listaResenas = await gestionCalificacion.obtenerCalificaciones(widget.publicacion.id);
      
      if (mounted) {
        setState(() {
          widget.publicacion.calificaciones.clear();
          widget.publicacion.calificaciones.addAll(listaResenas);
          _cargandoCalificaciones = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoCalificaciones = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(padding: const EdgeInsets.only(left: 40.0),
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
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Padding(padding: const EdgeInsets.only(top: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeAnfitrion(prestador: widget.prestador)));
                    },
                    icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                    label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: widget.prestador)));
                    }, 
                    icon: const Icon(Icons.upload, color: Color(0xFF216A44), size: 28),
                    label: const Text('Publicaciones', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: widget.prestador)));
                    }, 
                    icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                    label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilAnfitrion(prestador: widget.prestador)));
                    },  
                    icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                    label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                ],
              ),
            ),

            // TARJETA DE DETALLE PRINCIPAL
            Center(child: Padding(padding: const EdgeInsets.only(top: 50),
                child: Container(width: 1240, height: 500, 
                  decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(25)), 
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(mainAxisAlignment: MainAxisAlignment.start, 
                            children: [
                              Padding(padding: const EdgeInsets.only(left: 20), 
                                child: Container(width: 300, height: 250, 
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), 
                                    image: DecorationImage(
                                      image: (widget.publicacion.imagenUrl != null && widget.publicacion.imagenUrl!.startsWith('http'))
                                          ? NetworkImage(widget.publicacion.imagenUrl!) as ImageProvider
                                          : const AssetImage('assets/images/fondo.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // INFO DE LA PUBLICACIÓN
                              Expanded(
                                child: Padding(padding: const EdgeInsets.all(20),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text(
                                        widget.publicacion.titulo, 
                                        style: const TextStyle(fontFamily: 'Idiqlat', fontSize: 40, 
                                        fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                        children: [
                                          Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                            children: [
                                              Text('Lugar: ${widget.publicacion.ubicacion}', 
                                                style: const TextStyle(fontSize: 30), overflow: TextOverflow.ellipsis, 
                                                maxLines: 1),
                                              const SizedBox(height: 10),
                                              Row(mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text('Rating: ', style: TextStyle(fontSize: 30)),
                                                  const Icon(Icons.star, color: Colors.amber, size: 32),
                                                  Text(' ${widget.publicacion.calificacionPromedio.toStringAsFixed(1)}', 
                                                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Padding(padding: const EdgeInsets.only(left: 10),
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                              children: [
                                                Text('Anfitrión: ${widget.publicacion.nombreAnfitrion}', 
                                                  style: const TextStyle(fontSize: 30), overflow: TextOverflow.ellipsis, 
                                                  maxLines: 1),
                                                const SizedBox(height: 10),
                                                Text('Precio: \$${widget.publicacion.precio.toStringAsFixed(0)}', 
                                                  style: const TextStyle(fontSize: 30), overflow: TextOverflow.ellipsis, 
                                                  maxLines: 1),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        
                        // TÍTULO DE RESEÑAS
                        const Padding(padding: EdgeInsets.only(left: 60, right: 40),
                          child: Text('Reseñas de viajeros', style: TextStyle(fontSize: 30, fontFamily: 'Idiqlat', 
                            color: Colors.black, fontWeight: FontWeight.w800),
                          ),
                        ),
                        
                        // LISTA DE RESEÑAS
                        Expanded(
                          child: Padding(padding: const EdgeInsets.only(left: 60, top: 10, bottom: 10),
                            child: _cargandoCalificaciones
                                ? const Center(child: CircularProgressIndicator(color: Color(0xFF216A44)))
                                : widget.publicacion.calificaciones.isEmpty
                                    ? const Text('No hay reseñas disponibles para esta posada todavía.', 
                                    style: TextStyle(fontSize: 20, color: Colors.grey))
                                    : Scrollbar(thumbVisibility: true,
                                        child: ListView.builder(itemCount: widget.publicacion.calificaciones.length,
                                          itemBuilder: (context, index) {
                                            final calificacion = widget.publicacion.calificaciones[index];
                                            return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.circle, color: Color(0xFF216A44), size: 24),
                                                  const SizedBox(width: 15),
                                                  
                                                  Text('${calificacion.nombreUsuario}: ', style: const TextStyle(
                                                    fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)),
                                                  
                                                  Expanded(
                                                    child: Text(calificacion.comentario, style: const TextStyle(
                                                      fontSize: 25, color: Colors.black), overflow: TextOverflow.ellipsis,
                                                      maxLines: 2),
                                                  ),
                                                  
                                                  Row(
                                                    children: List.generate(5, (starIndex) {
                                                      return Icon(
                                                        starIndex < calificacion.puntaje ? Icons.star : Icons.star_border,
                                                        color: Colors.amber, size: 22,
                                                      );
                                                    }),
                                                  ),
                                                  const SizedBox(width: 20),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}