import 'package:ecostay/models/pdf_generator.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:ecostay/pantallas/viaj_perfil.dart';
import 'package:ecostay/widgets/reserva_viaj_reportar.dart';
import 'package:flutter/material.dart';
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

  const PantallaReserva({super.key, required this.publicacion, required this.viajero, this.reservaInicial});

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
        setState(() => _cargandoCalificaciones = false);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar el comprobante: $e')));
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado correctamente.')));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

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
                    Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) => const PantallaInicio()), (route) => false,
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
                      Text(widget.viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 18, color: Colors.black)),
                      const SizedBox(width: 10),
                    ],
                    CircleAvatar(
                      backgroundColor: const Color(0xFF216A44),
                      backgroundImage: widget.viajero.imagenUrl != null && widget.viajero.imagenUrl!.isNotEmpty ? NetworkImage(widget.viajero.imagenUrl!) : null,
                      child: widget.viajero.imagenUrl == null || widget.viajero.imagenUrl!.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final anchoMaximo = constraints.maxWidth;
          final usarLayoutMovil = anchoMaximo < 950;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menú superior dinámico
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(Icons.search, 'Explorar', isMobile, () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeViajero(viajero: widget.viajero)));
                    }),
                    _buildNavButton(Icons.send_outlined, 'Reservas', isMobile, () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: widget.viajero)));
                    }),
                    _buildNavButton(Icons.person_outline, 'Perfil', isMobile, () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilViajero(viajero: widget.viajero)));
                    }),
                  ],
                ),
              ),

              // Contenido principal scrolleable
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: usarLayoutMovil ? 16 : (anchoMaximo > 1300 ? 120 : 40),
                    vertical: 20
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Adaptación de los datos primarios
                            usarLayoutMovil 
                                ? _buildVerticalLayout(isMobile) 
                                : _buildHorizontalLayout(),
                            
                            const SizedBox(height: 30),
                            const Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
                            const SizedBox(height: 15),
                            
                            // Sección de Reseñas
                            Text('Reseñas', style: TextStyle(fontSize: isMobile ? 22 : 30, fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 15),
                            _buildResenasSection(isMobile),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  // Vista en FILA para Escritorios/Tablets grandes
  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 320, height: 250,
            child: _buildMainImage(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderActions(fontSize: 32, iconSize: 28),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                children: _buildGridDetails(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerRight, child: _buildActionButton(fontSize: 20)),
            ],
          ),
        )
      ],
    );
  }

  // Vista en COLUMNA para Teléfonos o pantallas chicas
  Widget _buildVerticalLayout(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: double.infinity, height: 220,
            child: _buildMainImage(),
          ),
        ),
        const SizedBox(height: 16),
        _buildHeaderActions(fontSize: isMobile ? 24 : 32, iconSize: 24),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 1 : 2,
          childAspectRatio: isMobile ? 5 : 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: _buildGridDetails(fontSize: isMobile ? 16 : 20),
        ),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: _buildActionButton(fontSize: 18)),
      ],
    );
  }

  Widget _buildMainImage() {
    return Image(
      image: (widget.publicacion.imagenUrl != null && widget.publicacion.imagenUrl!.startsWith('http'))
          ? NetworkImage(widget.publicacion.imagenUrl!) as ImageProvider
          : const AssetImage('assets/images/fondo.jpg'),
      fit: BoxFit.cover,
    );
  }

  Widget _buildHeaderActions({required double fontSize, required double iconSize}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.publicacion.titulo,
            style: TextStyle(fontFamily: 'Idiqlat', fontSize: fontSize, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis, maxLines: 2,
          ),
        ),
        if (_reservaActual != null && _reservaActual!.estado == EstadoReserva.COMPLETADA)
          _generandoPdf
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF216A44), strokeWidth: 2))
              : IconButton(icon: Icon(Icons.description, color: const Color(0xFF216A44), size: iconSize), tooltip: 'Comprobante', onPressed: _descargarComprobante),
        if (_reservaActual != null)
          IconButton(icon: Icon(Icons.flag_outlined, color: Colors.redAccent, size: iconSize), tooltip: 'Reportar Publicación', onPressed: () => _abrirDialogoReportar()),
      ],
    );
  }

  List<Widget> _buildGridDetails({required double fontSize}) {
    return [
      _infoTile(Icons.location_on, 'Lugar: ${widget.publicacion.ubicacion}', fontSize),
      _infoTile(Icons.style, 'Estilo: ${widget.publicacion.estilo}', fontSize),
      _infoTile(Icons.person, 'Anfitrión: ${widget.publicacion.nombreAnfitrion}', fontSize),
      Row(
        children: [
          Icon(Icons.star, color: Colors.amber, size: fontSize + 2),
          const SizedBox(width: 6),
          Expanded(child: Text('Rating: ${widget.publicacion.calificacionPromedio.toStringAsFixed(1)}', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ],
      ),
      _infoTile(Icons.people, 'Cupos: ${widget.publicacion.cuposActual} / ${widget.publicacion.cuposMax}', fontSize),
      _infoTile(Icons.attach_money, 'Precio: \$${widget.publicacion.precio.toStringAsFixed(0)}', fontSize, color: const Color(0xFF216A44)),
    ];
  }

  Widget _infoTile(IconData icon, String text, double fontSize, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey[700], size: fontSize + 2),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: fontSize, color: color, fontWeight: color != null ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildActionButton({required double fontSize}) {
    return FilledButton(
      onPressed: () {
        if (_reservaActual == null) {
          if (widget.viajero.suspendido == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tu cuenta se encuentra suspendida.'), backgroundColor: Colors.redAccent),
            );
            return;
          }
          showDialog(context: context, builder: (context) => DialogoSolicitarReserva(publicacion: widget.publicacion, viajero: widget.viajero, onReservaCreada: () => _obtenerEstadoReservaUsuario()));
        } else if (_reservaActual!.estado == EstadoReserva.COMPLETADA) {
          _mostrarDialogoComentario(context);
        } else {
          showDialog(context: context, builder: (context) => DialogoPagoReserva(reservaActual: _reservaActual!, publicacion: widget.publicacion, viajero: widget.viajero, onPagoCompletado: () => _obtenerEstadoReservaUsuario()));
        }
      },
      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF216A44), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
      child: Text(
        _reservaActual == null ? 'Solicitar' : (_reservaActual!.estado == EstadoReserva.COMPLETADA ? 'Reseñar' : 'Pagar'),
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResenasSection(bool isMobile) {
    if (_cargandoCalificaciones) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF216A44)));
    }
    if (widget.publicacion.calificaciones.isEmpty) {
      return Text('No hay reseñas disponibles para esta posada todavía.', style: TextStyle(fontSize: isMobile ? 14 : 18, color: Colors.grey));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // El scroll principal maneja todo
      itemCount: widget.publicacion.calificaciones.length,
      itemBuilder: (context, index) {
        final calificacion = widget.publicacion.calificaciones[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF9FBF7), borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle, color: Color(0xFF216A44), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(calificacion.nombreUsuario, style: TextStyle(fontSize: isMobile ? 15 : 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(calificacion.comentario, style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.black87)),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(starIndex < calificacion.puntaje ? Icons.star : Icons.star_border, color: Colors.amber, size: 16);
                        }),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flag_outlined, color: Colors.redAccent, size: 20),
                  tooltip: 'Reportar Comentario',
                  onPressed: () => _abrirDialogoReportar(calificacionId: calificacion.id, autorCalificacionId: calificacion.usuarioId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavButton(IconData icon, String label, bool isMobile, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: const Color(0xFF216A44), size: isMobile ? 22 : 28),
      label: Text(label, style: TextStyle(color: const Color(0xFF216A44), fontSize: isMobile ? 16 : 22)),
    );
  }
}