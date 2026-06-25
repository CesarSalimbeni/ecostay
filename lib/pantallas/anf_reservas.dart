import 'package:ecostay/models/estadoreserva.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/models/reserva.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/anf_publicaciones.dart';
import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/anf_perfil.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservaUIWrapper {
  final Reserva reserva;
  final String nombreViajero;
  final String tituloPublicacion;

  ReservaUIWrapper({
    required this.reserva,
    required this.nombreViajero,
    required this.tituloPublicacion,
  });
}

class PantallaReservasH extends StatefulWidget {
  final PrestadorServicio prestador;

  const PantallaReservasH({super.key, required this.prestador});

  @override
  State<PantallaReservasH> createState() => _PantallaReservasHState();
}

class _PantallaReservasHState extends State<PantallaReservasH> {
  final GestionReservacion _gestionReservacion = GestionReservacion();
  late Future<List<ReservaUIWrapper>> _futureReservas;
  String _filtroSeleccionado = 'Todas';
  final GestionUsuario _gestionUsuario = GestionUsuario();

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  void _cargarReservas() {
    setState(() {
      _futureReservas = _obtenerReservasDelAnfitrion();
    });
  }

  Future<List<ReservaUIWrapper>> _obtenerReservasDelAnfitrion() async {
    List<ReservaUIWrapper> reservasCompletas = [];
    try {
      final queryPublicaciones = await FirebaseFirestore.instance
          .collection('publications')
          .where('providerId', isEqualTo: widget.prestador.id)
          .get();

      Map<String, String> infoPublicaciones = {};
      for (var doc in queryPublicaciones.docs) {
        infoPublicaciones[doc.id] = doc.data()['titulo'] ?? 'Sin título';
      }

      if (infoPublicaciones.isEmpty) return [];

      final queryReservas = await FirebaseFirestore.instance
          .collection('reservations')
          .where('publicacionId', whereIn: infoPublicaciones.keys.toList())
          .get();

      for (var doc in queryReservas.docs) {
        final data = doc.data();
        final reserva = _gestionReservacion.mapToReserva(doc.id, data);
        final viajeroId = data['viajeroId'] ?? '';
        final publicacionId = data['publicacionId'] ?? '';

        String nombreViajero = 'Usuario EcoStay';
        if (viajeroId.isNotEmpty) {
          final docViajero = await FirebaseFirestore.instance
              .collection('users') 
              .doc(viajeroId)
              .get();
          if (docViajero.exists) {
            nombreViajero = docViajero.data()?['nombre'] ?? 'Usuario EcoStay';
          }
        }

        reservasCompletas.add(
          ReservaUIWrapper(
            reserva: reserva,
            nombreViajero: nombreViajero,
            tituloPublicacion: infoPublicaciones[publicacionId] ?? 'Destino Desconocido',
          ),
        );
      }

      reservasCompletas.sort((a, b) => b.reserva.fechaInicio.compareTo(a.reserva.fechaInicio));
      
    } catch (e) {
      debugPrint("Error al mapear reservas del anfitrión: $e");
    }
    return reservasCompletas;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
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
                    onPressed: () {Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeAnfitrion(prestador: widget.prestador)),
                      );
                    },   
                    icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                    label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: widget.prestador)),
                      );
                    }, 
                    icon: const Icon(Icons.upload, color: Color(0xFF216A44), size: 28),
                    label: const Text('Publicaciones', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                    label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                    fontWeight: FontWeight.w900)),
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

            // --- MAIN CONTENT CONTAINER ---
            Center(
              child: Padding(padding: const EdgeInsets.only(top: 30),
                child: Container(width: 1240,height: 560, decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(25),
                  ), 
                  child: Padding(padding: const EdgeInsets.all(30.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reservas Recibidas', 
                          style: TextStyle(fontSize: 32, fontFamily: 'Idiqlat', color: Colors.black, 
                          fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 15),
                        
                        // --- FILTROS DE PESTAÑAS (Todas, Pendientes, Confirmadas) ---
                        Container(padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: ['Todas', 'Pendientes', 'Confirmadas'].map((filtro) {
                              final esActivo = _filtroSeleccionado == filtro;
                              return GestureDetector(
                                onTap: () => setState(() => _filtroSeleccionado = filtro),
                                child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: esActivo ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: esActivo ? [BoxShadow(color: Colors.black.withOpacity(0.05), 
                                    blurRadius: 4)] : [],
                                  ),
                                  child: Text(filtro,style: TextStyle(
                                      color: esActivo ? Colors.black : const Color(0xFF526F75),
                                      fontWeight: esActivo ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 25),
                        
                        // --- TABLA DINÁMICA ---
                        Expanded(
                          child: FutureBuilder<List<ReservaUIWrapper>>(future: _futureReservas,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator(color: Color(0xFF216A44)));
                              }
                              if (snapshot.hasError) {
                                return Center(child: Text('Error al cargar datos: ${snapshot.error}', 
                                style: const TextStyle(color: Colors.red)));
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('No has recibido ninguna reserva todavía.', 
                                style: TextStyle(fontSize: 22, color: Colors.grey)));
                              }

                              // Aplicar filtro local
                              final reservasFiltradas = snapshot.data!.where((item) {
                                if (_filtroSeleccionado == 'Pendientes') {
                                  return item.reserva.estado == EstadoReserva.PENDIENTE;
                                }
                                if (_filtroSeleccionado == 'Confirmadas') {
                                  return item.reserva.estado == EstadoReserva.CONFIRMADA;
                                }
                                return true;
                              }).toList();

                              if (reservasFiltradas.isEmpty) {
                                return const Center(child: Text('No hay reservas en esta categoría.', 
                                style: TextStyle(fontSize: 18, color: Colors.grey)));
                              }

                              return Container(
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), 
                                  borderRadius: BorderRadius.circular(12),),
                                child: Column(
                                  children: [
                                    Container(color: const Color(0xFFF4F7F6),
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      child: Row(
                                        children: const [
                                          Expanded(flex: 2, child: Text('Viajero', style: TextStyle(
                                            fontWeight: FontWeight.bold, color: Color(0xFF526F75)))),
                                          Expanded(flex: 2, child: Text('Destino', style: TextStyle(
                                            fontWeight: FontWeight.bold, color: Color(0xFF526F75)))),
                                          // MODIFICADO: Cambiado el título para reflejar el rango de fechas
                                          Expanded(flex: 2, child: Text('Estadía (In - Fin)', style: TextStyle(
                                            fontWeight: FontWeight.bold, color: Color(0xFF526F75)))),
                                          Expanded(flex: 1, child: Text('Cupos', style: TextStyle(
                                            fontWeight: FontWeight.bold, color: Color(0xFF526F75)))),
                                          Expanded(flex: 1, child: Text('Total', style: TextStyle(
                                            fontWeight: FontWeight.bold, color: Color(0xFF526F75)))),
                                          Expanded(flex: 2, child: Text('Estado', style: TextStyle(
                                            fontWeight: FontWeight.bold, color: Color(0xFF526F75)))),
                                          Expanded(flex: 2, child: Text('Acciones', style: TextStyle(
                                            fontWeight: FontWeight.bold, color: Color(0xFF526F75)))),
                                        ],
                                      ),
                                    ),
                                    // Cuerpo de la tabla
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: reservasFiltradas.length,
                                        itemBuilder: (context, index) {
                                          final item = reservasFiltradas[index];
                                          return _buildFilaReservaWeb(item);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

  // --- COMPONENT: ROW CUSTOM RENDERER ---
  Widget _buildFilaReservaWeb(ReservaUIWrapper item) {
    final reserva = item.reserva;

    Color statusBg = const Color(0xFFEAEAEA);
    Color statusText = Colors.black87;
    String etiquetaEstado = 'Solicitado';

    if (reserva.estado == EstadoReserva.CONFIRMADA) {
      statusBg = const Color(0xFF1E4D36);
      statusText = Colors.white;
      etiquetaEstado = 'Confirmada';
    } else if (reserva.estado == EstadoReserva.COMPLETADA) {
      statusBg = Colors.blueGrey;
      statusText = Colors.white;
      etiquetaEstado = 'Pagada';
    } else if (reserva.estado == EstadoReserva.CANCELADA) {
      statusBg = const Color(0xFF8A1C14);
      statusText = Colors.white;
      etiquetaEstado = 'Cancelada';
    }

    List<String> meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    String stringFecha = "${reserva.fechaInicio.day} ${meses[reserva.fechaInicio.month - 1]} - ${reserva.fechaFin.day} ${meses[reserva.fechaFin.month - 1]} ${reserva.fechaFin.year}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200)),),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.nombreViajero, style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 15))),
          Expanded(flex: 2, child: Text(item.tituloPublicacion, style: const TextStyle(
            color: Colors.black87, fontSize: 15))),
          Expanded(flex: 2, child: Text(stringFecha, style: const TextStyle(fontSize: 15))),
          
          Expanded(flex: 1, child: Text('${reserva.cupos} solic.', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          
          Expanded(flex: 1, child: Text('${reserva.total.toInt()}\$', style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 15))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                child: Text(etiquetaEstado, style: TextStyle(color: statusText, fontWeight: FontWeight.w600, 
                fontSize: 13)),
              ),
            ),
          ),
          Expanded(flex: 2,
            child: Row(mainAxisSize: MainAxisSize.min,
              children: [
                if (reserva.estado == EstadoReserva.PENDIENTE) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Color(0xFF387653), size: 24),
                    onPressed: () async {
                      await _gestionReservacion.confirmarReserva(reserva.id);
                      _cargarReservas();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Color(0xFF8A1C14), size: 24),
                    onPressed: () async {
                      await _gestionReservacion.cancelarReserva(reserva.id);
                      _cargarReservas();
                    },
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}