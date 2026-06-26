import 'package:ecostay/models/estadoreserva.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/reserva.dart'; 
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:ecostay/pantallas/reserva_viaj_main.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:ecostay/pantallas/viaj_perfil.dart';
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:ecostay/widgets/detalles_contacto.dart'; 
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaMisReservas extends StatelessWidget {
  final Viajero viajero; 
  final GestionReservacion _gestionReservacion = GestionReservacion();
  final GestionUsuario _gestionUsuario = GestionUsuario();

  PantallaMisReservas({super.key, required this.viajero});

  @override
  Widget build(BuildContext context) {
    final double currentWidth = MediaQuery.of(context).size.width;
    final bool isMobile = currentWidth < 750;

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
                      Text( viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                        style: TextStyle(fontSize: (currentWidth * 0.015).clamp(14.0, 20.0), color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF216A44),
                        backgroundImage: viajero.imagenUrl != null && viajero.imagenUrl!.isNotEmpty
                            ? NetworkImage(viajero.imagenUrl!)
                            : null,
                        child: viajero.imagenUrl == null || viajero.imagenUrl!.isEmpty
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
            // MENÚ SUPERIOR CORREGIDO: Se expande equitativamente y no se tira a la izquierda
            Padding(padding: const EdgeInsets.only(top: 15),
              child: SizedBox(
                width: currentWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(width: isMobile ? 16 : (currentWidth * 0.05)),
                      TextButton.icon(onPressed: () {
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomeViajero(viajero: viajero)),);
                        }, 
                        icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                        label: Text('Explorar', style: TextStyle(color: const Color(0xFF216A44), fontSize: (currentWidth * 0.018).clamp(15.0, 25.0))),
                      ),
                      SizedBox(width: isMobile ? 20 : (currentWidth * 0.1)),
                      TextButton.icon(onPressed: null, 
                        icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                        label: Text('Reservas', style: TextStyle(color: const Color(0xFF216A44), fontSize: (currentWidth * 0.018).clamp(15.0, 25.0), 
                        fontWeight: FontWeight.w900)),
                      ),
                      SizedBox(width: isMobile ? 20 : (currentWidth * 0.1)),
                      TextButton.icon(onPressed: () {
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => PerfilViajero(viajero: viajero)),);
                        }, 
                        icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                        label: Text('Perfil', style: TextStyle(color: const Color(0xFF216A44), fontSize: (currentWidth * 0.018).clamp(15.0, 25.0))),
                      ),
                      SizedBox(width: isMobile ? 16 : (currentWidth * 0.05)),
                    ],
                  ),
                ),
              ),
            ),

            // TÍTULO
            Padding(padding: EdgeInsets.only(left: isMobile ? 24.0 : (currentWidth * 0.12).clamp(24.0, 175.0), top: 40, bottom: 20),
              child: Text('Mis Reservas', 
                style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat', fontWeight: FontWeight.w800, fontSize: (currentWidth * 0.022).clamp(20.0, 30.0)),
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

/// WIDGET PARA RESERVA CORREGIDO Y AUTO-AJUSTABLE
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
    final double currentWidth = MediaQuery.of(context).size.width;
    final bool isMobile = currentWidth < 750;

    final String inicioCompletoStr = "${widget.reserva.fechaInicio.day}/${widget.reserva.fechaInicio.month}/${widget.reserva.fechaInicio.year}";
    final String finCompletoStr = "${widget.reserva.fechaFin.day}/${widget.reserva.fechaFin.month}/${widget.reserva.fechaFin.year}";
    final String rangoCompletoHint = "$inicioCompletoStr - $finCompletoStr";
    String rangoFechasVisible = "";
    if (widget.reserva.fechaInicio.year == widget.reserva.fechaFin.year) {
      rangoFechasVisible = "${widget.reserva.fechaInicio.day}/${widget.reserva.fechaInicio.month} - ${widget.reserva.fechaFin.day}/${widget.reserva.fechaFin.month}/${widget.reserva.fechaFin.year}";
    } else {
      rangoFechasVisible = rangoCompletoHint;
    }  
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

    // DISEÑO PARA CELULARES CORREGIDO CON CLAMP COMPLETO
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, height: 70, 
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), 
                      image: DecorationImage(image: imagenProvider, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tituloPosada, 
                          style: TextStyle(fontSize: (currentWidth * 0.045).clamp(14.0, 18.0), fontFamily: 'Idiqlat', fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: _obtenerColorEstado(widget.reserva.estado), borderRadius: BorderRadius.circular(50)),
                          child: Text(
                            _obtenerTextoEstado(widget.reserva.estado), 
                            style: TextStyle(color: Colors.white, fontSize: (currentWidth * 0.032).clamp(11.0, 14.0), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lugar', style: TextStyle(fontSize: (currentWidth * 0.032).clamp(11.0, 13.0), color: Colors.grey)),
                        Text(ubicacionPosada, style: TextStyle(fontSize: (currentWidth * 0.038).clamp(13.0, 16.0), fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha', style: TextStyle(fontSize: (currentWidth * 0.032).clamp(11.0, 13.0), color: Colors.grey)),
                        Text(rangoFechasVisible, style: TextStyle(fontSize: (currentWidth * 0.035).clamp(12.0, 15.0), fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Anfitrión', style: TextStyle(fontSize: (currentWidth * 0.032).clamp(11.0, 13.0), color: Colors.grey)),
                        Text(nombreAnfitrion, style: TextStyle(fontSize: (currentWidth * 0.038).clamp(13.0, 16.0), fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total', style: TextStyle(fontSize: (currentWidth * 0.032).clamp(11.0, 13.0), color: Colors.grey)),
                        Text('\$${widget.reserva.total.toStringAsFixed(2)}', style: TextStyle(fontSize: (currentWidth * 0.038).clamp(13.0, 16.0), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cargandoDatos || _publicacionCompleta == null ? null : () {
                        showDialog(context: context, builder: (context) => InfoContactoPrestadorDialog(publicacionId: _publicacionCompleta.id, nombreAnfitrion: nombreAnfitrion));
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black), padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: Text('Contactar', style: TextStyle(color: Colors.black, fontSize: (currentWidth * 0.038).clamp(13.0, 15.0))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _cargandoDatos || _publicacionCompleta == null ? null : () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaReserva(publicacion: _publicacionCompleta, viajero: widget.viajero, reservaInicial: widget.reserva)));
                      },
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF216A44), padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: Text('Detalles', style: TextStyle(fontSize: (currentWidth * 0.038).clamp(13.0, 15.0))),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    // DISEÑO ORIGINAL PARA COMPUTADORA/WEB (SE MANTIENE AL 100%)
    return Padding(padding: EdgeInsets.symmetric(horizontal: (currentWidth * 0.08).clamp(16.0, 125.0), vertical: 10),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1240), 
          height: 140, 
          decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(25)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Padding(padding: const EdgeInsets.only(left: 20), 
                child: Container(width: 200, height: 110, 
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), 
                    image: DecorationImage(image: imagenProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
              
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 20),
                      child: Text(tituloPosada, style: TextStyle(fontSize: (currentWidth * 0.018).clamp(15.0, 25.0), fontFamily: 'Idiqlat', fontWeight: FontWeight.w800)),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, 
                      children: [
                        Padding(padding: const EdgeInsets.only(left: 20),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              Padding(padding: const EdgeInsets.only(bottom: 10), child: Text('Lugar', style: TextStyle(fontSize: (currentWidth * 0.014).clamp(12.0, 20.0)))),
                              Padding(padding: const EdgeInsets.only(bottom: 10), 
                                child: Text(ubicacionPosada, style: TextStyle(fontSize: (currentWidth * 0.011).clamp(10.0, 15.0), fontWeight: FontWeight.w700), 
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                            ]
                          ),
                        ),
                        Expanded(
                          child: Padding(padding: const EdgeInsets.only(left: 20),
                            child: Tooltip(message: rangoCompletoHint,
                              textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: BoxDecoration(
                                color: const Color(0xFF216A44).withOpacity(0.95), borderRadius: BorderRadius.circular(8),
                              ),
                              preferBelow: true,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                children: [
                                  Padding(padding: const EdgeInsets.only(bottom: 10), child: Text('Fecha', style: TextStyle(fontSize: (currentWidth * 0.014).clamp(12.0, 20.0)))),
                                  Padding(padding: const EdgeInsets.only(bottom: 10), 
                                    child: Text(rangoFechasVisible, style: TextStyle(fontSize: (currentWidth * 0.011).clamp(10.0, 15.0), fontWeight: FontWeight.w700), 
                                    overflow: TextOverflow.ellipsis, maxLines: 1),
                                  ),
                                ]
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(padding: const EdgeInsets.only(left: 20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Padding(padding: const EdgeInsets.only(bottom: 10), child: Text('Anfitrión', 
                                style: TextStyle(fontSize: (currentWidth * 0.014).clamp(12.0, 20.0)))),
                                Padding(padding: const EdgeInsets.only(bottom: 10), 
                                  child: Text(nombreAnfitrion, style: TextStyle(fontSize: (currentWidth * 0.011).clamp(10.0, 15.0), fontWeight: FontWeight.w700), 
                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                                ),
                              ]
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(padding: const EdgeInsets.only(left: 20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Padding(padding: const EdgeInsets.only(bottom: 10), child: Text('Total', style: TextStyle(
                                  fontSize: (currentWidth * 0.014).clamp(12.0, 20.0)))),
                                Padding(padding: const EdgeInsets.only(bottom: 10), 
                                  child: Text('\$${widget.reserva.total.toStringAsFixed(2)}', style: TextStyle(
                                    fontSize: (currentWidth * 0.011).clamp(10.0, 15.0), fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, maxLines: 1),
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
              
              Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(color: _obtenerColorEstado(widget.reserva.estado), borderRadius: BorderRadius.circular(50)),
                child: Text(_obtenerTextoEstado(widget.reserva.estado), style: TextStyle(color: Colors.white, 
                fontSize: (currentWidth * 0.014).clamp(12.0, 20.0), fontWeight: FontWeight.w500)),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  children: [
                    OutlinedButton.icon(
                      onPressed: _cargandoDatos || _publicacionCompleta == null 
                          ? null 
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) => InfoContactoPrestadorDialog(
                                  publicacionId: _publicacionCompleta.id,
                                  nombreAnfitrion: nombreAnfitrion,
                                ),
                              );
                            }, 
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                      label: Text('Contactar', style: TextStyle(fontSize: (currentWidth * 0.016).clamp(13.0, 25.0), color: Colors.black)), 
                      style: OutlinedButton.styleFrom(
                        fixedSize: Size((currentWidth * 0.12).clamp(120.0, 180.0), 40), 
                        side: const BorderSide(color: Colors.black),
                      ),
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
                      label: Text('Detalles', style: TextStyle(fontSize: (currentWidth * 0.016).clamp(13.0, 25.0), color: const Color(0xFFFFFFFF))), 
                      style: FilledButton.styleFrom(
                        fixedSize: Size((currentWidth * 0.12).clamp(120.0, 180.0), 40), 
                        backgroundColor: const Color(0xFF216A44),
                      ),
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