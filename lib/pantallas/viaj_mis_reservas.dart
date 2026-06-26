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

class PantallaMisReservas extends StatelessWidget {
  final Viajero viajero; 
  final GestionReservacion _gestionReservacion = GestionReservacion();
  final GestionUsuario _gestionUsuario = GestionUsuario();

  PantallaMisReservas({super.key, required this.viajero});

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
                      Text(viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 18, color: Colors.black)),
                      const SizedBox(width: 10),
                    ],
                    CircleAvatar(
                      backgroundColor: const Color(0xFF216A44),
                      backgroundImage: viajero.imagenUrl != null && viajero.imagenUrl!.isNotEmpty ? NetworkImage(viajero.imagenUrl!) : null,
                      child: viajero.imagenUrl == null || viajero.imagenUrl!.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
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
          // MENÚ SUPERIOR DINÁMICO
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                _buildNavButton(Icons.search, 'Explorar', isMobile, () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeViajero(viajero: viajero)));
                }, activo: false),
                _buildNavButton(Icons.send_outlined, 'Reservas', isMobile, null, activo: true),
                _buildNavButton(Icons.person_outline, 'Perfil', isMobile, () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilViajero(viajero: viajero)));
                }, activo: false),
              ],
            ),
          ),

          // TÍTULO ADAPTABLE
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : (width > 1200 ? 120.0 : 40.0),
              vertical: 15
            ),
            child: Text(
              'Mis Reservas', 
              style: TextStyle(
                color: Colors.black, 
                fontFamily: 'Idiqlat', 
                fontWeight: FontWeight.w800, 
                fontSize: isMobile ? 24 : 30
              ),
            ),
          ),

          // LISTVIEW DINÁMICO ASÍNCRONO
          Expanded(
            child: FutureBuilder<List<Reserva>>(
              future: _gestionReservacion.obtenerReservasPorViajero(viajero.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF216A44)));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar las reservas.', style: TextStyle(fontSize: 18, color: Colors.redAccent)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aún no tienes ninguna reserva.', style: TextStyle(fontSize: 18, color: Colors.grey)));
                }

                final reservas = snapshot.data!;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : (width > 1200 ? 120.0 : 40.0),
                    vertical: 10
                  ),
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
          fontWeight: activo ? FontWeight.w900 : FontWeight.normal
        )
      ),
    );
  }
}

/// WIDGET DE TARJETA ADAPTABLE
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
        setState(() => _cargandoDatos = false);
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
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final bool usarLayoutMovil = anchoPantalla < 950;
    final bool isMobile = anchoPantalla < 768;

    final String inicioCompletoStr = "${widget.reserva.fechaInicio.day}/${widget.reserva.fechaInicio.month}/${widget.reserva.fechaInicio.year}";
    final String finCompletoStr = "${widget.reserva.fechaFin.day}/${widget.reserva.fechaFin.month}/${widget.reserva.fechaFin.year}";
    final String rangoCompletoHint = "$inicioCompletoStr - $finCompletoStr";
    
    String rangoFechasVisible = widget.reserva.fechaInicio.year == widget.reserva.fechaFin.year
        ? "${widget.reserva.fechaInicio.day}/${widget.reserva.fechaInicio.month} - ${widget.reserva.fechaFin.day}/${widget.reserva.fechaFin.month}/${widget.reserva.fechaFin.year}"
        : rangoCompletoHint;

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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      constraints: const BoxConstraints(maxWidth: 1240),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))]
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: usarLayoutMovil 
            ? _buildLayoutMovil(imagenProvider, tituloPosada, ubicacionPosada, nombreAnfitrion, rangoFechasVisible, rangoCompletoHint, isMobile)
            : _buildLayoutEscritorio(imagenProvider, tituloPosada, ubicacionPosada, nombreAnfitrion, rangoFechasVisible, rangoCompletoHint),
      ),
    );
  }

  // DISEÑO HORIZONTAL (PC / TABLETS GRANDES)
  Widget _buildLayoutEscritorio(
    ImageProvider imagen, String titulo, String lugar, String anfitrion, String fechas, String hintFechas
  ) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(width: 160, height: 110, child: Image(image: imagen, fit: BoxFit.cover)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 20, fontFamily: 'Idiqlat', fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoColumna('Lugar', lugar),
                  Tooltip(
                    message: hintFechas,
                    child: _infoColumna('Fecha', fechas),
                  ),
                  _infoColumna('Anfitrión', anfitrion),
                  _infoColumna('Total', '\$${widget.reserva.total.toStringAsFixed(2)}'),
                ],
              )
            ],
          ),
        ),
        const SizedBox(width: 20),
        Column(
          children: [
            _badgeEstado(),
            const SizedBox(height: 12),
            _buildAcciones(vertical: false)
          ],
        )
      ],
    );
  }

  // DISEÑO VERTICAL (TELÉFONOS / TABLETS CHICAS)
  Widget _buildLayoutMovil(
    ImageProvider imagen, String titulo, String lugar, String anfitrion, String fechas, String hintFechas, bool isMobile
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(width: 90, height: 80, child: Image(image: imagen, fit: BoxFit.cover)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 16, fontFamily: 'Idiqlat', fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  _badgeEstado(),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          childAspectRatio: isMobile ? 3 : 2.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _infoColumna('Lugar', lugar),
            _infoColumna('Fecha', fechas),
            _infoColumna('Anfitrión', anfitrion),
            _infoColumna('Total', '\$${widget.reserva.total.toStringAsFixed(2)}', destacar: true),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),
        _buildAcciones(vertical: true),
      ],
    );
  }

  Widget _infoColumna(String etiqueta, String valor, {bool destacar = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(etiqueta, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          valor, 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w700, 
            color: destacar ? const Color(0xFF216A44) : Colors.black
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _badgeEstado() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: _obtenerColorEstado(widget.reserva.estado), borderRadius: BorderRadius.circular(20)),
      child: Text(
        _obtenerTextoEstado(widget.reserva.estado), 
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildAcciones({required bool vertical}) {
    final botones = [
      OutlinedButton.icon(
        onPressed: _cargandoDatos || _publicacionCompleta == null 
            ? null 
            : () {
                showDialog(
                  context: context,
                  builder: (context) => InfoContactoPrestadorDialog(
                    publicacionId: _publicacionCompleta.id,
                    nombreAnfitrion: _publicacionCompleta.nombreAnfitrion,
                  ),
                );
              }, 
        icon: const Icon(Icons.chat_bubble_outline, size: 16),
        label: const Text('Contactar', style: TextStyle(fontSize: 14)), 
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: vertical ? const Size(double.infinity, 40) : const Size(130, 40)
        ),
      ),
      if (vertical) const SizedBox(height: 8) else const SizedBox(width: 8),
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
        icon: const Icon(Icons.info_outline, size: 16),
        label: const Text('Detalles', style: TextStyle(fontSize: 14)), 
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF216A44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: vertical ? const Size(double.infinity, 40) : const Size(130, 40)
        ),
      )
    ];

    return vertical 
        ? Column(children: botones) 
        : Row(mainAxisAlignment: MainAxisAlignment.end, children: botones);
  }
}