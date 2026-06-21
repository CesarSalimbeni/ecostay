import 'package:ecostay/models/estadoreserva.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/reserva.dart'; 
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/reserva_viaj_main.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:ecostay/pantallas/viaj_perfil.dart';
import 'package:ecostay/models/gestion_reservacion.dart'; 
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaMisReservas extends StatelessWidget {
  final Viajero viajero; 
  final GestionReservacion _gestionReservacion = GestionReservacion();

  PantallaMisReservas({super.key, required this.viajero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        toolbarHeight: 90, 
        leadingWidth: 120, 
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
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: Text(viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 20)),
          ),
          const Padding(padding: EdgeInsets.only(right: 10.0),
            child: CircleAvatar(),
          )
        ],
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // MENÚ SUPERIOR
            Padding(padding: const EdgeInsets.only(top: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  TextButton.icon(onPressed: () {
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeViajero(viajero: viajero)),);
                    }, 
                    icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                    label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(onPressed: null, 
                    icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                    label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25, 
                    fontWeight: FontWeight.w900)),
                  ),
                  TextButton.icon(onPressed: () {
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PerfilViajero(viajero: viajero)),);
                    }, 
                    icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                    label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                ],
              ),
            ),

            // TÍTULO
            const Padding(padding: EdgeInsets.only(left: 175, top: 40, bottom: 20),
              child: Text('Mis Reservas', 
                style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat', fontWeight: FontWeight.w800, fontSize: 30),
              ),
            ),

            // LISTVIEW DINÁMICO ASÍNCRONO
            Expanded(
              child: FutureBuilder<List<Reserva>>(future: _gestionReservacion.obtenerReservasPorViajero(viajero.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF216A44)),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar las reservas.',style: TextStyle(fontSize: 20, color: Colors.redAccent),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Aún no tienes ninguna reserva.', style: TextStyle(fontSize: 20, color: Colors.grey),),
                    );
                  }

                  final reservas = snapshot.data!;

                  return ListView.builder(
                    itemCount: reservas.length,
                    itemBuilder: (context, index) {
                      return CardReservaItem(
                        reserva: reservas[index],
                        viajero: viajero,
                        gestionReservacion: _gestionReservacion,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// WIDGET PARA RESERVA 
class CardReservaItem extends StatefulWidget {
  final Reserva reserva;
  final Viajero viajero;
  final GestionReservacion gestionReservacion;

  const CardReservaItem({
    super.key, 
    required this.reserva, 
    required this.viajero, 
    required this.gestionReservacion,
  });

  @override
  State<CardReservaItem> createState() => _CardReservaItemState();
}

class _CardReservaItemState extends State<CardReservaItem> {
  dynamic _publicacionCompleta;
  bool _cargandoDatos = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosPublicacion();
  }

  Future<void> _cargarDatosPublicacion() async {
    try {
      final (_, _, String idDeLaPublicacion) = await widget.gestionReservacion.obtenerInformacion(widget.reserva.id);
      final GestionPublicacion gestionPublicacion = GestionPublicacion();
      final pub = await gestionPublicacion.obtenerPublicacionPorId(idDeLaPublicacion);
      
      if (mounted) {
        setState(() {
          _publicacionCompleta = pub;
          _cargandoDatos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoDatos = false;
        });
      }
    }
  }

  Color _obtenerColorEstado(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.CONFIRMADA: return const Color(0xFFBEDA78);
      case EstadoReserva.CANCELADA: return Colors.redAccent;
      case EstadoReserva.PENDIENTE: return Colors.orangeAccent;
      case EstadoReserva.COMPLETADA: return Colors.blueAccent;
    }
  }

  String _obtenerTextoEstado(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.CONFIRMADA: return 'Confirmada';
      case EstadoReserva.CANCELADA: return 'Cancelada';
      case EstadoReserva.PENDIENTE: return 'Pendiente';
      case EstadoReserva.COMPLETADA: return 'Completada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fechaStr = "${widget.reserva.fechaInicio.day}/${widget.reserva.fechaInicio.month}/${widget.reserva.fechaInicio.year}";
    
    String tituloPosada = 'Cargando posada...';
    String ubicacionPosada = 'Cargando...';
    String nombreAnfitrion = 'Cargando...';
    ImageProvider imagenProvider = const AssetImage('assets/images/fondo.jpg');

    if (!_cargandoDatos && _publicacionCompleta != null) {
      tituloPosada = _publicacionCompleta.titulo;
      ubicacionPosada = _publicacionCompleta.ubicacion;
      nombreAnfitrion = _publicacionCompleta.nombreAnfitrion;
      
      if (_publicacionCompleta.imagenUrl != null && _publicacionCompleta.imagenUrl!.startsWith('http')) {
        imagenProvider = NetworkImage(_publicacionCompleta.imagenUrl!);
      }
    }

    return Padding(padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 10),
      child: Center(
        child: Container(width: 1240, height: 140, 
          decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(25)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              // IMAGEN REAL DE LA PUBLICACIÓN
              Padding(
                padding: const EdgeInsets.only(left: 20), 
                child: Container(width: 200, height: 110, 
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), 
                    image: DecorationImage(image: imagenProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
              
              // DETALLES REALES DE LA RESERVA
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 20),
                      child: Text(tituloPosada, style: const TextStyle(fontSize: 25, fontFamily: 'Idiqlat', fontWeight: FontWeight.w800)),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, 
                      children: [
                        // LUGAR
                        Padding(padding: const EdgeInsets.only(left: 20),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Lugar', style: TextStyle(fontSize: 20))),
                              Padding(padding: const EdgeInsets.only(bottom: 10), 
                                child: Text(ubicacionPosada, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), 
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                            ]
                          ),
                        ),
                        
                        // FECHA
                        Expanded(
                          child: Padding(padding: const EdgeInsets.only(left: 20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Fecha', style: TextStyle(
                                  fontSize: 20))),
                                Padding(padding: const EdgeInsets.only(bottom: 10), 
                                  child: Text(fechaStr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), 
                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                                ),
                              ]
                            ),
                          ),
                        ),
                        
                        // ANFITRIÓN 
                        Expanded(
                          child: Padding(padding: const EdgeInsets.only(left: 20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Anfitrión', 
                                style: TextStyle(fontSize: 20))),
                                Padding(padding: const EdgeInsets.only(bottom: 10), 
                                  child: Text(nombreAnfitrion, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), 
                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                                ),
                              ]
                            ),
                          ),
                        ),
                        
                        // TOTAL
                        Expanded(
                          child: Padding(padding: const EdgeInsets.only(left: 20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Total', style: TextStyle(
                                  fontSize: 20))),
                                Padding(padding: const EdgeInsets.only(bottom: 10), 
                                  child: Text('\$${widget.reserva.total.toStringAsFixed(2)}', style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, maxLines: 1),
                                ),
                              ]
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              
              // ESTATUS DINÁMICO
              Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(color: _obtenerColorEstado(widget.reserva.estado), borderRadius: BorderRadius.circular(50)),
                child: Text(_obtenerTextoEstado(widget.reserva.estado), style: const TextStyle(color: Colors.white, 
                fontSize: 20, fontWeight: FontWeight.w500)),
              ),
              
              // BOTONES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {}, 
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                      label: const Text('Contactar', style: TextStyle(fontSize: 25, color: Colors.black)), 
                      style: OutlinedButton.styleFrom(fixedSize: const Size(180, 40), side: const BorderSide(color: Colors.black)),
                    ),
                    
                    FilledButton.icon(
                      onPressed: _cargandoDatos || _publicacionCompleta == null ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaReserva(
                              publicacion: _publicacionCompleta,
                              viajero: widget.viajero,
                              reservaInicial: widget.reserva,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      label: const Text('Detalles', style: TextStyle(fontSize: 25, color: Color(0xFFFFFFFF))), 
                      style: FilledButton.styleFrom(fixedSize: const Size(180, 40), backgroundColor: const Color(0xFF216A44)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}