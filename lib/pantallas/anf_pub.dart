import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/anf_publicaciones.dart';
import 'package:ecostay/pantallas/anf_reservas.dart';
import 'package:ecostay/pantallas/anf_perfil.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';
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
  List<dynamic> _calificaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    try {
      final gestionCalificacion = GestionCalificacion();
      final lista = await gestionCalificacion.obtenerCalificaciones(widget.publicacion.id);
      if (mounted) {
        setState(() {
          _calificaciones = lista;
          _cargandoCalificaciones = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoCalificaciones = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar reseñas: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _gestionUsuario.cerrarSesion();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada con éxito')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaInicio()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  List<Widget> _buildNavItems(BuildContext context, {bool isVertical = false}) {
    final double fontSize = isVertical ? 18 : 22;
    return [
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeAnfitrion(prestador: widget.prestador)));
        }, 
        icon: Icon(Icons.dns, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Dashboard', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: widget.prestador)));
        }, 
        icon: Icon(Icons.upload, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Publicaciones', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: widget.prestador)));
        },
        icon: Icon(Icons.send_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Reservas', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilAnfitrion(prestador: widget.prestador)));
        }, 
        icon: Icon(Icons.person_outline, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Perfil', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double anchoPantalla = MediaQuery.of(context).size.width;
    bool esDesktop = anchoPantalla > 950;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        toolbarHeight: esDesktop ? 90 : 70,
        centerTitle: esDesktop ? true : false,
        leadingWidth: esDesktop ? 120 : null,
        leading: esDesktop
            ? Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
              )
            : null,
        title: esDesktop
            ? SizedBox(
                width: 400,
                child: SearchBar(
                  hintText: 'Buscar...',
                  hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
                  leading: const Icon(Icons.search, color: Color(0xFF526F75)),
                  backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
                  elevation: const WidgetStatePropertyAll(0),
                ),
              )
            : Text(widget.publicacion.titulo, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: esDesktop ? 20.0 : 10.0),
            child: InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (esDesktop) ...[
                      Text(
                        widget.prestador.nombre,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                    ],
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
        ],
      ),
      drawer: !esDesktop
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xFF216A44)),
                    accountName: Text(widget.prestador.nombre),
                    accountEmail: Text(widget.prestador.email),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: (widget.prestador.imagenUrl != null && widget.prestador.imagenUrl!.isNotEmpty)
                          ? NetworkImage(widget.prestador.imagenUrl!)
                          : null,
                      child: (widget.prestador.imagenUrl == null || widget.prestador.imagenUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                  ..._buildNavItems(context, isVertical: true),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                    onTap: _logout,
                  )
                ],
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (esDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildNavItems(context),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: esDesktop ? 40.0 : 16.0,
                vertical: 30.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Flex(
                    direction: anchoPantalla > 850 ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: anchoPantalla > 850 ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                    children: [
                      // COLUMNA DETALLES DE PUBLICACIÓN
                      Expanded(
                        flex: anchoPantalla > 850 ? 5 : 0,
                        child: Container(
                          padding: EdgeInsets.all(anchoPantalla > 600 ? 30.0 : 20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: widget.publicacion.imagenUrl != null
                                    ? Image.network(
                                        widget.publicacion.imagenUrl ?? '',
                                        height: anchoPantalla > 600 ? 350 : 220,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: anchoPantalla > 600 ? 350 : 220,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image, size: 50),
                                      ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                widget.publicacion.titulo,
                                style: TextStyle(
                                  fontSize: anchoPantalla > 600 ? 32 : 24,
                                  fontFamily: 'Idiqlat',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: Color(0xFF6E867A), size: 18),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.publicacion.ubicacion,
                                      style: const TextStyle(color: Color(0xFF6E867A), fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '\$${widget.publicacion.precio.toStringAsFixed(2)} / noche',
                                style: const TextStyle(color: Color(0xFF216A44), fontSize: 26, fontWeight: FontWeight.w800),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
                              ),
                              const Text(
                                'Descripción',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.publicacion.descripcion,
                                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(width: anchoPantalla > 850 ? 24 : 0, height: anchoPantalla > 850 ? 0 : 24),
                      
                      // COLUMNA RESEÑAS / CALIFICACIONES
                      Expanded(
                        flex: anchoPantalla > 850 ? 5 : 0,
                        child: Container(
                          padding: EdgeInsets.all(anchoPantalla > 600 ? 30.0 : 20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reseñas de viajeros',
                                style: TextStyle(fontSize: 24, fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 16),
                              _cargandoCalificaciones
                                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF216A44)))
                                  : _calificaciones.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 40.0),
                                          child: Center(
                                            child: Text(
                                              'Esta publicación aún no tiene reseñas.',
                                              style: TextStyle(fontSize: 16, color: Colors.grey),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _calificaciones.length,
                                          itemBuilder: (context, index) {
                                            final calificacion = _calificaciones[index];
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF5F7F2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          calificacion.comentario,
                                                          style: const TextStyle(fontSize: 16, color: Colors.black),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 3,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: List.generate(5, (starIndex) {
                                                          return Icon(
                                                            starIndex < calificacion.puntaje ? Icons.star : Icons.star_border,
                                                            color: Colors.amber,
                                                            size: 20,
                                                          );
                                                        }),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}