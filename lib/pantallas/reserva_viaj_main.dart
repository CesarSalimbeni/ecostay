import 'package:ecostay/models/pdf_generator.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _generandoPdf = false;
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
      _reservaActual = null;
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

  Future<void> _descargarComprobante() async {
    if (_reservaActual == null) return;
    setState(() => _generandoPdf = true);
     
    try {
      final (_, viajeroId, publicacionId) = await _gestionReservacion.obtenerInformacion(_reservaActual!.id);

      String nombreAnfitrion = widget.publicacion.nombreAnfitrion;
      String tituloPublicacion = widget.publicacion.titulo;

      final docPub = await FirebaseFirestore.instance.collection('publications').doc(publicacionId).get();
      if (docPub.exists && docPub.data() != null) {
        final providerId = docPub.data()!['providerId'] ?? '';
        if (providerId.isNotEmpty) {
          final docAnf = await FirebaseFirestore.instance.collection('users').doc(providerId).get();
          if (docAnf.exists && docAnf.data() != null) {
            nombreAnfitrion = docAnf.data()!['nombre'] ?? nombreAnfitrion;
          }
        }
      }

      final pdfService = PdfService();
      await pdfService.generarVoucher(
        idReserva: _reservaActual!.id,
        nombreAnfitrion: nombreAnfitrion,
        idViajero: viajeroId.isNotEmpty ? viajeroId : widget.viajero.id,
        monto: _reservaActual!.total,
        tituloPublicacion: tituloPublicacion,
      );

    } catch (e) {
      debugPrint('Error al generar el comprobante PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar el comprobante: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
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
    final bool isMobile = size.width < 950; // Breakpoint de adaptabilidad

    // Extracción de lógica del botón de acción para evitar duplicación
    final VoidCallback onActionButtonPressed = () {
      if (_reservaActual == null) {
        if (widget.viajero.suspendido == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tu cuenta se encuentra suspendida. No puedes realizar nuevas solicitudes de reserva.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
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
    };

    final String labelButtonText = _reservaActual == null 
        ? 'Solicitar' 
        : (_reservaActual!.estado == EstadoReserva.COMPLETADA ? 'Reseñar' : 'Pagar');

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), 
        toolbarHeight: 90, 
        leadingWidth: isMobile ? 90 : 120, 
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: isMobile ? 15.0 : 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain,),
        ),
        title: SizedBox(
          width: isMobile ? size.width * 0.45 : 400,
          child: SearchBar(
            hintText: 'Buscar...', 
            hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
            leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
            backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
            elevation: const WidgetStatePropertyAll(0),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isMobile ? 10.0 : 20.0),
            child: Tooltip(
              message: 'Cerrar sesión', 
              preferBelow: true, 
              verticalOffset: 25,
              textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: BoxDecoration(
                color: const Color(0xFF216A44).withOpacity(0.95),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMobile) ...[
                        Text(widget.viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                          style: const TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                      ],
                      CircleAvatar(
                        backgroundColor: const Color(0xFF216A44),
                        backgroundImage: widget.viajero.imagenUrl != null && widget.viajero.imagenUrl!.isNotEmpty
                            ? NetworkImage(widget.viajero.imagenUrl!)
                            : null,
                        child: widget.viajero.imagenUrl == null || widget.viajero.imagenUrl!.isEmpty
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              // BARRA DE NAVEGACIÓN SUPERIOR RESPONSIVA
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomeViajero(viajero: widget.viajero)),
                        );
                      },
                      icon: Icon(Icons.search, color: const Color(0xFF216A44), size: isMobile ? 22 : 28),
                      label: Text('Explorar', style: TextStyle(color: const Color(0xFF216A44), fontSize: isMobile ? 18 : 25)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: widget.viajero)),
                        );
                      }, 
                      icon: Icon(Icons.send_outlined, color: const Color(0xFF216A44), size: isMobile ? 22 : 28),
                      label: Text('Reservas', style: TextStyle(color: const Color(0xFF216A44), fontSize: isMobile ? 18 : 25)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => PerfilViajero(viajero: widget.viajero)),
                        );
                      },  
                      icon: Icon(Icons.person_outline, color: const Color(0xFF216A44), size: isMobile ? 22 : 28),
                      label: Text('Perfil', style: TextStyle(color: const Color(0xFF216A44), fontSize: isMobile ? 18 : 25)),
                    ),
                  ],
                ),
              ),

              // TARJETA DE DETALLE PRINCIPAL ADAPTATIVA
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: isMobile ? 25 : 50, bottom: 30, left: 15, right: 15),
                  child: Container(
                    width: isMobile ? double.infinity : 1240, 
                    height: isMobile ? null : 500, // Altura automática en móvil para albergar contenido apilado
                    constraints: const BoxConstraints(maxWidth: 1240),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF), 
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ), 
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 20, vertical: isMobile ? 15 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 20),
                            child: isMobile 
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Imagen Adaptada para Celular
                                    Container(
                                      width: double.infinity, 
                                      height: 220, 
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20), 
                                        image: DecorationImage(
                                          image: (widget.publicacion.imagenUrl != null && widget.publicacion.imagenUrl!.startsWith('http'))
                                              ? NetworkImage(widget.publicacion.imagenUrl!) as ImageProvider
                                              : const AssetImage('assets/images/fondo.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    // Bloque de Información
                                    _buildInfoBloque(context, isMobile, onActionButtonPressed, labelButtonText),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start, 
                                  children: [
                                    // Imagen de Escritorio Inalterada
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20), 
                                      child: Container(
                                        width: 300, 
                                        height: 250, 
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20), 
                                          image: DecorationImage(
                                            image: (widget.publicacion.imagenUrl != null && widget.publicacion.imagenUrl!.startsWith('http'))
                                                ? NetworkImage(widget.publicacion.imagenUrl!) as ImageProvider
                                                : const AssetImage('assets/images/fondo.jpg'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // INFO DE LA PUBLICACIÓN ESCRITORIO
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: _buildInfoBloque(context, isMobile, onActionButtonPressed, labelButtonText),
                                      ),
                                    )
                                  ],
                                ),
                          ),
                          
                          // TÍTULO DE RESEÑAS
                          Padding(
                            padding: EdgeInsets.only(left: isMobile ? 10 : 60, right: 40),
                            child: const Text('Reseñas', 
                              style: TextStyle(fontSize: 30, fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                            ),
                          ),
                          
                          // LISTA DE RESEÑAS RESPONSIVA
                          isMobile 
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 15),
                                child: _cargandoCalificaciones
                                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF216A44)))
                                    : widget.publicacion.calificaciones.isEmpty
                                        ? const Text('No hay reseñas disponibles para esta posada todavía.', style: TextStyle(fontSize: 16, color: Colors.grey))
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: widget.publicacion.calificaciones.length,
                                            itemBuilder: (context, index) => _buildResenaItem(widget.publicacion.calificaciones[index], isMobile),
                                          ),
                              )
                            : Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 60, top: 10, bottom: 10),
                                  child: _cargandoCalificaciones
                                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF216A44)))
                                      : widget.publicacion.calificaciones.isEmpty
                                          ? const Text('No hay reseñas disponibles para esta posada todavía.', style: TextStyle(fontSize: 20, color: Colors.grey))
                                          : Scrollbar(
                                              thumbVisibility: true,
                                              child: ListView.builder(
                                                itemCount: widget.publicacion.calificaciones.length,
                                                itemBuilder: (context, index) => _buildResenaItem(widget.publicacion.calificaciones[index], isMobile),
                                              ),
                                            ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para construir toda la información textual de la posada
  Widget _buildInfoBloque(BuildContext context, bool isMobile, VoidCallback onAction, String btnText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.publicacion.titulo, 
                style: TextStyle(fontFamily: 'Idiqlat', fontSize: isMobile ? 28 : 40, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_reservaActual != null && _reservaActual!.estado == EstadoReserva.COMPLETADA)
              _generandoPdf 
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: Color(0xFF216A44), strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.description, color: Color(0xFF216A44), size: 32),
                      tooltip: 'Comprobante de reserva',
                      onPressed: _descargarComprobante,
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
        isMobile 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTextoItem('Lugar: ${widget.publicacion.ubicacion}', isMobile),
                _infoTextoItem('Anfitrión: ${widget.publicacion.nombreAnfitrion}', isMobile),
                _infoTextoItem('Estilo: ${widget.publicacion.estilo ?? 'No especificado'}', isMobile),
                _infoRatingItem(isMobile),
                _infoTextoItem('Cupos: ${widget.publicacion.cuposActual ?? 0} / ${widget.publicacion.cuposMax ?? 0}', isMobile),
                _infoTextoItem('Precio: \$${widget.publicacion.precio.toStringAsFixed(0)}', isMobile),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF216A44),
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                    child: Text(btnText, style: const TextStyle(fontSize: 20)),
                  ),
                )
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      _infoTextoItem('Lugar: ${widget.publicacion.ubicacion}', isMobile),
                      const SizedBox(height: 15),
                      _infoTextoItem('Estilo: ${widget.publicacion.estilo ?? 'No especificado'}', isMobile),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      _infoTextoItem('Anfitrión: ${widget.publicacion.nombreAnfitrion}', isMobile),
                      const SizedBox(height: 15),
                      _infoRatingItem(isMobile),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      _infoTextoItem('Cupos: ${widget.publicacion.cuposActual ?? 0} / ${widget.publicacion.cuposMax ?? 0}', isMobile),
                      const SizedBox(height: 15),
                      _infoTextoItem('Precio: \$${widget.publicacion.precio.toStringAsFixed(0)}', isMobile),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF216A44)),
                  child: Text(btnText, style: const TextStyle(fontSize: 28)),
                )
              ],
            ),
      ],
    );
  }

  Widget _infoTextoItem(String texto, bool isMobile) {
    return Text(
      texto, 
      style: TextStyle(fontSize: isMobile ? 18 : 26), 
      overflow: TextOverflow.ellipsis, 
      maxLines: 1
    );
  }

  Widget _infoRatingItem(bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Rating: ', style: TextStyle(fontSize: isMobile ? 18 : 26)),
        Icon(Icons.star, color: Colors.amber, size: isMobile ? 20 : 28),
        Text(' ${widget.publicacion.calificacionPromedio.toStringAsFixed(1)}', 
          style: TextStyle(fontSize: isMobile ? 18 : 26, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }

  // Elemento individual para renderizar comentarios adaptable en listas
  Widget _buildResenaItem(dynamic calificacion, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: isMobile ? 0.0 : 10.0),
      child: isMobile 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFF216A44), size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${calificacion.nombreUsuario}: ', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, color: Colors.redAccent, size: 20),
                    onPressed: () => _abrirDialogoReportar(
                      calificacionId: calificacion.id,
                      autorCalificacionId: calificacion.usuarioId,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22.0),
                child: Text(calificacion.comentario, style: const TextStyle(fontSize: 16, color: Colors.black)),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 22.0),
                child: Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < calificacion.puntaje ? Icons.star : Icons.star_border,
                      color: Colors.amber, size: 16,
                    );
                  }),
                ),
              ),
              const Divider(),
            ],
          )
        : Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF216A44), size: 24),
              const SizedBox(width: 15),
              Text('${calificacion.nombreUsuario}: ', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)),
              Expanded(
                child: Text(calificacion.comentario, style: const TextStyle(fontSize: 25, color: Colors.black), overflow: TextOverflow.ellipsis, maxLines: 2),
              ),
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
  }
}