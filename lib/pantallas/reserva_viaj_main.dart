import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:ecostay/pantallas/viaj_perfil.dart';
import 'package:ecostay/widgets/reserva_viaj_reportar.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/reserva.dart';
import 'package:ecostay/models/estadoreserva.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/viaj_mis_reservas.dart';
import 'package:ecostay/widgets/reserva_viaj_completada.dart';
import 'package:ecostay/widgets/reserva_viaj_pagar.dart';
import 'package:ecostay/widgets/reserva_viaj_solicitar.dart';

class PantallaReserva extends StatefulWidget {
  final Publicacion publicacion;
  final Viajero viajero;
  final Reserva? reservaInicial;

  const PantallaReserva({super.key, required this.publicacion, required this.viajero, this.reservaInicial,});

  @override
  State<PantallaReserva> createState() => _PantallaReservaState();
}

class _PantallaReservaState extends State<PantallaReserva> {
  bool _cargandoCalificaciones = true;
  Reserva? _reservaActual; 
  final GestionReservacion _gestionReservacion = GestionReservacion();
  final GestionUsuario _gestionUsuario = GestionUsuario();

  @override
  void initState() {
    super.initState();
    _cargarResenas();
    if (widget.reservaInicial != null) {
      _reservaActual = widget.reservaInicial;
    } else {
      _obtenerEstadoReservaUsuario();
    }
  }

  Future<void> _obtenerEstadoReservaUsuario() async {
    try {
      final listaReservasGenerales = await _gestionReservacion.obtenerReservasPorViajero(widget.viajero.id);
      Reserva? reservaEncontrada;

      for (var reservaSimp in listaReservasGenerales) {
        final (reservaData, _, publicacionId) = await _gestionReservacion.obtenerInformacion(reservaSimp.id);
        
        if (publicacionId == widget.publicacion.id && reservaData.estado != EstadoReserva.CANCELADA) {
          reservaEncontrada = reservaData;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _reservaActual = reservaEncontrada;
        });
      }
    } catch (e) {
      print('Error al validar la publicación de las reservas: $e');
    }
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

  void _mostrarDialogoComentario(BuildContext ctx) {
    if (_reservaActual == null) return;
    
    showDialog(
      context: ctx,
      builder: (context) => DialogoComentario(
        reservaActual: _reservaActual!,
        onResenaEnviada: () {
          _cargarResenas();
          _obtenerEstadoReservaUsuario();
        },
      ),
    );
  }

  void _abrirDialogoReportar({String? calificacionId, String? autorCalificacionId}) {
    showDialog(
      context: context,
      builder: (context) => DialogoReportar(
        reservaActual: _reservaActual,
        publicacionId: widget.publicacion.id,
        viajeroId: widget.viajero.id,
        calificacionId: calificacionId,
        autorCalificacionId: autorCalificacionId,
        onReporteEnviado: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reporte enviado correctamente para revisión.')),
          );
        },
      ),
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
                      Text(widget.viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      const CircleAvatar(
                        backgroundColor: Color(0xFF216A44),
                        child: Icon(Icons.person, color: Colors.white),
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
                    onPressed: () {Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeViajero(viajero: widget.viajero),
                      ),
                    );
                  },
                    icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                    label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: widget.viajero)),
                      );
                    }, 
                    icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                    label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PerfilViajero(viajero: widget.viajero),
                      ),
                    );
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.publicacion.titulo, 
                                              style: const TextStyle(fontFamily: 'Idiqlat', fontSize: 40, 
                                              fontWeight: FontWeight.w800),overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (_reservaActual != null)
                                            IconButton(
                                              icon: const Icon(Icons.flag_outlined, color: Colors.redAccent, size: 32),
                                              tooltip: 'Reportar Publicación',
                                              onPressed: () => _abrirDialogoReportar(),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                        children: [
                                          Expanded(
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                              children: [
                                                Text('Lugar: ${widget.publicacion.ubicacion}', 
                                                style: const TextStyle(fontSize: 26), overflow: TextOverflow.ellipsis, 
                                                maxLines: 1),
                                                const SizedBox(height: 15),
                                                Text('Estilo: ${widget.publicacion.estilo ?? 'No especificado'}', 
                                                style: const TextStyle(fontSize: 26), overflow: TextOverflow.ellipsis, 
                                                maxLines: 1),
                                              ],
                                            ),
                                          ),
                                          
                                          Expanded(
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                              children: [
                                                Text('Anfitrión: ${widget.publicacion.nombreAnfitrion}', 
                                                style: const TextStyle(fontSize: 26), overflow: TextOverflow.ellipsis, 
                                                maxLines: 1),
                                                const SizedBox(height: 15),
                                                Row(mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Text('Rating: ', style: TextStyle(fontSize: 26)),
                                                    const Icon(Icons.star, color: Colors.amber, size: 28),
                                                    Text(' ${widget.publicacion.calificacionPromedio.toStringAsFixed(1)}', 
                                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          Expanded(
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                              children: [
                                                Text('Cupos: ${widget.publicacion.cuposActual ?? 0} / ${widget.publicacion.cuposMax ?? 0}', 
                                                style: const TextStyle(fontSize: 26), overflow: TextOverflow.ellipsis, 
                                                maxLines: 1),
                                                const SizedBox(height: 15),
                                                Text('Precio: \$${widget.publicacion.precio.toStringAsFixed(0)}', 
                                                style: const TextStyle(fontSize: 26), overflow: TextOverflow.ellipsis, 
                                                maxLines: 1),
                                              ],
                                            ),
                                          ),
                                          
                                          // BOTÓN DE ACCIÓN (Solicitar, Pagar o Reseñar)
                                          FilledButton(
                                            onPressed: () {
                                              if (_reservaActual == null) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => DialogoSolicitarReserva(
                                                    publicacion: widget.publicacion,
                                                    viajero: widget.viajero,
                                                    onReservaCreada: () => _obtenerEstadoReservaUsuario(),
                                                  ),
                                                );
                                              } else if (_reservaActual!.estado == EstadoReserva.COMPLETADA) {
                                                _mostrarDialogoComentario(context);
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => DialogoPagoReserva(
                                                    reservaActual: _reservaActual!,
                                                    publicacion: widget.publicacion,
                                                    viajero: widget.viajero,
                                                    onPagoCompletado: () => _obtenerEstadoReservaUsuario(),
                                                  ),
                                                );
                                              }
                                            },
                                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF216A44)),
                                            child: Text(
                                              _reservaActual == null 
                                                  ? 'Solicitar' 
                                                  : (_reservaActual!.estado == EstadoReserva.COMPLETADA ? 'Reseñar' : 'Pagar'),
                                              style: const TextStyle(fontSize: 28),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        
                        //TÍTULO DE RESEÑAS
                        Padding(padding: const EdgeInsets.only(left: 60, right: 40),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Reseñas', style: TextStyle(fontSize: 30, fontFamily: 'Idiqlat', 
                              color: Colors.black, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        
                        //RESEÑAS
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
                                            return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, 
                                            horizontal: 10.0),
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
                                                  
                                                  // ESTRELLAS DINÁMICAS BASADAS EN EL PUNTAJE
                                                  Row(
                                                    children: List.generate(5, (starIndex) {
                                                      return Icon(
                                                        starIndex < calificacion.puntaje ? Icons.star : Icons.star_border,
                                                        color: Colors.amber, size: 22,
                                                      );
                                                    }),
                                                  ),
                                                  const SizedBox(width: 10),
                                                    IconButton(
                                                      icon: const Icon(Icons.flag_outlined, color: Colors.redAccent, size: 22),
                                                      tooltip: 'Reportar Comentario',
                                                      onPressed: () => _abrirDialogoReportar(
                                                        calificacionId: calificacion.id,
                                                        autorCalificacionId: calificacion.usuarioId,
                                                      ),
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