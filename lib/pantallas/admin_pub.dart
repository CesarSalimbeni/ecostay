import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/pantallas/admin_explorar.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_perfil.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/pantallas/estilo.dart';

class PantallaPubAdmin extends StatefulWidget {
  final Publicacion publicacion;
  final Administrador administrador;

  const PantallaPubAdmin({
    super.key, 
    required this.publicacion, 
    required this.administrador,
  });

  @override
  State<PantallaPubAdmin> createState() => PantallaPubAdminState();
}

class PantallaPubAdminState extends State<PantallaPubAdmin> {
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

  Future<void> _logout(BuildContext context) async {
    try {
      await _gestionUsuario.cerrarSesion();
      if (context.mounted) {
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
      if (context.mounted) {
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeAdmin(administrador: widget.administrador)));
        },
        icon: Icon(Icons.dns, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Dashboard', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminExplorar(administrador: widget.administrador)));
        },
        icon: Icon(Icons.search, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Explorar', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: widget.administrador)));
        }, 
        icon: Icon(Icons.person_add_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Usuarios', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminModeracion(administrador: widget.administrador)));
        }, 
        icon: Icon(Icons.shield_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Moderación', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilAdministrador(administrador: widget.administrador)));
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
          : const Text('Detalle de Publicación', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: esDesktop ? 20.0 : 10.0),
            child: InkWell(
              onTap: () => _logout(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (esDesktop) ...[
                      Text(
                        widget.administrador.nombre, 
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 1, 
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                    ],
                    CircleAvatar(
                      backgroundColor: const Color(0xFF216A44),
                      backgroundImage: widget.administrador.imagenUrl != null && widget.administrador.imagenUrl!.isNotEmpty
                          ? NetworkImage(widget.administrador.imagenUrl!)
                          : null,
                      child: widget.administrador.imagenUrl == null || widget.administrador.imagenUrl!.isEmpty
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
                  accountName: Text(widget.administrador.nombre),
                  accountEmail: const Text("Administrador - Gestión"),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: widget.administrador.imagenUrl != null && widget.administrador.imagenUrl!.isNotEmpty
                        ? NetworkImage(widget.administrador.imagenUrl!)
                        : null,
                    child: widget.administrador.imagenUrl == null || widget.administrador.imagenUrl!.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                ..._buildNavItems(context, isVertical: true),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  onTap: () => _logout(context),
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
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: _buildNavItems(context),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: esDesktop ? 40.0 : 16.0, 
                vertical: 20.0
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Container(
                    padding: EdgeInsets.all(anchoPantalla > 600 ? 30.0 : 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF), 
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECCIÓN DE DETALLE DE LA PUBLICACIÓN (FLEX RESPONSIVO)
                        Flex(
                          direction: anchoPantalla > 800 ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: anchoPantalla > 800 ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: anchoPantalla > 800 ? 300 : double.infinity, 
                              height: anchoPantalla > 800 ? 250 : 220, 
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
                            SizedBox(width: anchoPantalla > 800 ? 25 : 0, height: anchoPantalla > 800 ? 0 : 20),
                            
                            // INFO DE LA PUBLICACIÓN
                            Expanded(
                              flex: anchoPantalla > 800 ? 1 : 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, 
                                children: [
                                  Text(
                                    widget.publicacion.titulo, 
                                    style: TextStyle(
                                      fontFamily: 'Idiqlat', 
                                      fontSize: anchoPantalla > 600 ? 38 : 28, 
                                      fontWeight: FontWeight.w800
                                    ), 
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 15),
                                  Flex(
                                    direction: anchoPantalla > 600 ? Axis.horizontal : Axis.vertical,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: anchoPantalla > 600 ? CrossAxisAlignment.start : CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: anchoPantalla > 600 ? 1 : 0,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, 
                                          children: [
                                            Text(
                                              'Lugar: ${widget.publicacion.ubicacion}', 
                                              style: TextStyle(fontSize: anchoPantalla > 600 ? 22 : 18), 
                                              overflow: TextOverflow.ellipsis, 
                                              maxLines: 2,
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Rating: ', style: TextStyle(fontSize: anchoPantalla > 600 ? 22 : 18)),
                                                const Icon(Icons.star, color: Colors.amber, size: 26),
                                                Text(
                                                  ' ${widget.publicacion.calificacionPromedio.toStringAsFixed(1)}', 
                                                  style: TextStyle(fontSize: anchoPantalla > 600 ? 22 : 18, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (anchoPantalla <= 600) const SizedBox(height: 12),
                                      Expanded(
                                        flex: anchoPantalla > 600 ? 1 : 0,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: anchoPantalla > 600 ? 16.0 : 0.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start, 
                                            children: [
                                              Text(
                                                'Anfitrión: ${widget.publicacion.nombreAnfitrion}', 
                                                style: TextStyle(fontSize: anchoPantalla > 600 ? 22 : 18), 
                                                overflow: TextOverflow.ellipsis, 
                                                maxLines: 2,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Precio: \$${widget.publicacion.precio.toStringAsFixed(0)}', 
                                                style: TextStyle(fontSize: anchoPantalla > 600 ? 22 : 18, fontWeight: FontWeight.w600), 
                                                overflow: TextOverflow.ellipsis, 
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        
                        const SizedBox(height: 35),
                        const Divider(color: Color(0xFFF0F2EE), thickness: 1.5),
                        const SizedBox(height: 15),

                        // TÍTULO DE RESEÑAS
                        Text(
                          'Reseñas de viajeros', 
                          style: TextStyle(
                            fontSize: anchoPantalla > 600 ? 26 : 22, 
                            fontFamily: 'Idiqlat', 
                            color: Colors.black, 
                            fontWeight: FontWeight.w800
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        // LISTA DE RESEÑAS CON CONTROLES ANTI-OVERFLOW
                        _cargandoCalificaciones
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(child: CircularProgressIndicator(color: Color(0xFF216A44))),
                              )
                            : widget.publicacion.calificaciones.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.0),
                                    child: Text(
                                      'No hay reseñas disponibles para esta posada todavía.', 
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: widget.publicacion.calificaciones.length,
                                    itemBuilder: (context, index) {
                                      final calificacion = widget.publicacion.calificaciones[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(top: 2.0),
                                              child: Icon(Icons.circle, color: Color(0xFF216A44), size: 14),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${calificacion.nombreUsuario}:', 
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    calificacion.comentario, 
                                                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: List.generate(5, (starIndex) {
                                                      return Icon(
                                                        starIndex < calificacion.puntaje ? Icons.star : Icons.star_border,
                                                        color: Colors.amber, 
                                                        size: 18,
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
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
              ),
            ),
          )
        ],
      ),
    );
  }
}