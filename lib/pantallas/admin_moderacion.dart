import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/admin_explorar.dart';
import 'package:ecostay/pantallas/admin_perfil.dart';
import 'package:ecostay/pantallas/admin_perfil_usuario.dart';
import 'package:ecostay/pantallas/admin_pub.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/models/gestion_reportes.dart';

class AdminModeracion extends StatefulWidget {
  final Administrador administrador;

  const AdminModeracion({super.key, required this.administrador});

  @override
  State<AdminModeracion> createState() => _AdminModeracionState();
}

class _AdminModeracionState extends State<AdminModeracion> {
  final GestionReportes _gestionReportes = GestionReportes();
  late Future<List<Map<String, dynamic>>> _futureReportes;
  final GestionPublicacion _gestionPublicacion = GestionPublicacion();
  final GestionUsuario _gestionUsuario = GestionUsuario();

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  void _cargarReportes() {
    setState(() {
      _futureReportes = _gestionReportes.buscarTodosLosReportes();
    });
  }

  // Helper para cerrar sesión
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

  // Lista centralizada de items de navegación para reusar en Barra Superior o Drawer
  List<Widget> _buildNavItems(BuildContext context, {bool isVertical = false}) {
    final double fontSize = isVertical ? 18 : 22;
    return [
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeAdmin(administrador: widget.administrador)),
          );
        },
        icon: Icon(Icons.dns, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Dashboard', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminExplorar(administrador: widget.administrador)),
          );
        },
        icon: Icon(Icons.search, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Explorar', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: widget.administrador)),
          );
        },
        icon: Icon(Icons.person_add_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Usuarios', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: null,
        icon: Icon(Icons.shield_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Moderación', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize, fontWeight: FontWeight.w900)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PerfilAdministrador(administrador: widget.administrador)),
          );
        },
        icon: Icon(Icons.person_outline, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Perfil', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
    ];
  }

  void _mostrarConfirmacion({
    required String accion,
    required VoidCallback alConfirmar,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Confirmar $accion?'),
          content: const Text('Esta acción es permanente y no se puede deshacer. ¿Está seguro de realizarla?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                alConfirmar();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accion == 'Eliminar' ? const Color(0xFFB72E2E) : const Color(0xFF216A44),
              ),
              child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _ignorarReporte(Map<String, dynamic> reporte) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procesando solicitud...'), duration: Duration(milliseconds: 500)),
      );

      TipoObjeto tipo = reporte['tipo'] == 'CALIFICACION' 
          ? TipoObjeto.CALIFICACION 
          : TipoObjeto.PUBLICACION;

      await _gestionReportes.desestimarReporte(
        objetoId: reporte['objetoId'] ?? '',
        tipo: tipo,
        publicacionId: reporte['publicacionId'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte desestimado correctamente.')),
        );
        _cargarReportes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al desestimar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _eliminarContenidoReportado(Map<String, dynamic> reporte) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eliminando contenido...'), duration: Duration(milliseconds: 500)),
      );

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String objetoId = reporte['objetoId'] ?? '';
      final String? publicacionId = reporte['publicacionId'];

      if (reporte['tipo'] == 'CALIFICACION') {
        if (publicacionId == null || publicacionId.isEmpty) {
          throw ArgumentError('Falta el ID de la publicación asociada a esta calificación.');
        }
        await firestore.collection('publications').doc(publicacionId).collection('ratings').doc(objetoId).delete();
      } else {
        await firestore.collection('publications').doc(objetoId).delete();
      }

      QuerySnapshot reportesAsociados = await firestore
          .collection('reports').where('objetoId', isEqualTo: objetoId).get();

      WriteBatch batch = firestore.batch();
      for (var doc in reportesAsociados.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El contenido ofensivo y sus reportes han sido eliminados.')),
        );
        _cargarReportes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar contenido: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatearTiempo(dynamic fechaReporte) {
    if (fechaReporte == null || fechaReporte is! Timestamp) return 'Hace un momento';
    
    final DateTime fecha = fechaReporte.toDate();
    final duracion = DateTime.now().difference(fecha);
    
    if (duracion.inDays > 0) return 'Hace ${duracion.inDays} d';
    if (duracion.inHours > 0) return 'Hace ${duracion.inHours} h';
    if (duracion.inMinutes > 0) return 'Hace ${duracion.inMinutes} m';
    return 'Hace un momento';
  }

  Future<String> _obtenerComentarioReportado(Map<String, dynamic> reporte) async {
    try {
      final String publicacionId = reporte['publicacionId'] ?? '';
      final String objetoId = reporte['objetoId'] ?? '';

      if (publicacionId.isEmpty || objetoId.isEmpty) {
        return 'Contenido no disponible (IDs inválidos)';
      }

      var ratingDoc = await FirebaseFirestore.instance
          .collection('publications').doc(publicacionId).collection('ratings').doc(objetoId).get();

      if (ratingDoc.exists) {
        return ratingDoc.data()?['comentario'] ?? 'Calificación sin comentario escrito';
      } else {
        return 'El comentario ya no existe o fue eliminado.';
      }
    } catch (e) {
      print('Error al buscar comentario: $e');
      return 'Error al cargar el contenido del comentario';
    }
  }

  Future<String> _obtenerTituloContenido(Map<String, dynamic> reporte) async {
    final firestore = FirebaseFirestore.instance;
    try {
      if (reporte['tipo'] == 'CALIFICACION') {
        String publicacionId = reporte['publicacionId'] ?? '';
        String objetoId = reporte['objetoId'] ?? '';
        
        var ratingDoc = await firestore
            .collection('publications').doc(publicacionId).collection('ratings').doc(objetoId).get();
        String autor = ratingDoc.data()?['nombreUsuario'] ?? 'Usuario';
        
        Publicacion? publicacion = await _gestionPublicacion.obtenerPublicacionPorId(publicacionId);
        String posada = publicacion?.titulo ?? 'Posada';
        
        return '$autor en $posada';
      } else {
        String objetoId = reporte['objetoId'] ?? '';
        Publicacion? publicacion = await _gestionPublicacion.obtenerPublicacionPorId(objetoId);
        return publicacion?.titulo ?? 'Publicación sin nombre';
      }
    } catch (e) {
      return reporte['tipo'] == 'CALIFICACION' ? 'Comentario / Reseña' : 'Publicación';
    }
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
          : null, // Muestra el botón de menú Hamburguesa en móviles automáticamente si hay drawer
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
          : const Text('EcoStay Moderación', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(padding: EdgeInsets.only(right: esDesktop ? 20.0 : 10.0),
            child: InkWell(
              onTap: () => _logout(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
      // Menú colapsable lateral para móviles y tablets
      drawer: !esDesktop 
        ? Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF216A44)),
                  accountName: Text(widget.administrador.nombre),
                  accountEmail: const Text("Administrador - Moderación"),
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
          // Mostrar barra de pestañas horizontal solo en resoluciones Desktop
          if (esDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildNavItems(context),
              ),
            ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureReportes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF216A44)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Ocurrió un error al cargar reportes: ${snapshot.error}'),
                  );
                }

                final listaReportes = snapshot.data ?? [];

                if (listaReportes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay reportes pendientes de revisión.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                // Ajuste dinámico del padding según tamaño del dispositivo
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: esDesktop ? 60.0 : 20.0, 
                    vertical: 10
                  ),
                  itemCount: listaReportes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: esDesktop ? 0.0 : 15.0, 
                          bottom: 25
                        ),
                        child: Text(
                          'Reportes', 
                          style: TextStyle(
                            color: Colors.black, 
                            fontSize: esDesktop ? 36 : 28,
                            fontWeight: FontWeight.bold, 
                            fontFamily: 'Idiqlat',
                          ),
                        ),
                      );
                    }

                    final reporte = listaReportes[index - 1];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: _buildCardReporte(
                        context: context,
                        anchoPantalla: anchoPantalla,
                        reporte: reporte,
                        onIgnorar: () => _mostrarConfirmacion(accion: 'Ignorar', alConfirmar: () => _ignorarReporte(reporte)),
                        onEliminar: () => _mostrarConfirmacion(accion: 'Eliminar', alConfirmar: () => _eliminarContenidoReportado(reporte)),
                      ),
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

  Widget _buildCardReporte({
    required BuildContext context,
    required double anchoPantalla,
    required Map<String, dynamic> reporte,
    required VoidCallback onIgnorar,
    required VoidCallback onEliminar,
  }) {
    final bool esDePublicacion = reporte['tipo'] == 'PUBLICACION';
    final String textoBotonDinamico = esDePublicacion ? 'Ver Publicación' : 'Ver Perfil';
    final IconData iconoBotonDinamico = esDePublicacion ? Icons.article_outlined : Icons.account_circle_outlined;

    return Container(
      padding: EdgeInsets.all(anchoPantalla > 600 ? 25.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera responsiva: se apila verticalmente si el ancho es menor a 550px
          Flex(
            direction: anchoPantalla > 550 ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: anchoPantalla > 550 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: anchoPantalla > 550 ? 1 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: _obtenerTituloContenido(reporte),
                      builder: (context, snapshot) {
                        String titulo = snapshot.data ?? (esDePublicacion ? 'Publicación' : 'Comentario / Reseña');
                        return Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Reporte de: $titulo', 
                                style: TextStyle(
                                  color: Colors.black, 
                                  fontSize: anchoPantalla > 600 ? 20 : 18, 
                                  fontWeight: FontWeight.bold, 
                                  fontFamily: 'Idiqlat'
                                ),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatearTiempo(reporte['fechaReporte']),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (anchoPantalla <= 550) const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFB72E2E), 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pendiente', 
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          Container(
            width: double.infinity, 
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F2), 
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Motivo: ${reporte['motivo'] ?? 'Sin motivo especificado'}',
              style: TextStyle(color: Colors.black, fontSize: anchoPantalla > 600 ? 17 : 15),
            ),
          ),

          if (reporte['tipo'] == 'CALIFICACION') ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5), 
                borderRadius: BorderRadius.circular(15), 
                border: Border.all(color: const Color(0xFFF5C6C6), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contenido del Comentario:',
                    style: TextStyle(color: Color(0xFFB72E2E), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<String>(
                    future: _obtenerComentarioReportado(reporte),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB72E2E)),
                        );
                      }
                      
                      final comentarioReal = snapshot.data ?? 'Contenido no disponible';
                      return Text(
                        '"$comentarioReal"',
                        style: TextStyle(
                          color: Colors.black87, 
                          fontSize: anchoPantalla > 600 ? 17 : 15, 
                          fontStyle: FontStyle.italic
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Wrap Adaptativo para evitar overflows en los botones de acción corporativa
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: onIgnorar,
                icon: const Icon(Icons.check, color: Colors.white, size: 20),
                label: const Text('Ignorar', style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF216A44),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
              ),

              ElevatedButton.icon(
                onPressed: onEliminar,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                label: const Text('Eliminar', style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB72E2E),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
              ),

              OutlinedButton.icon(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cargando elemento solicitado...'), duration: Duration(milliseconds: 700)),
                  );

                  try {
                    final String objetoId = reporte['objetoId'] ?? '';
                    
                    if (esDePublicacion) {
                      final String idABuscar = objetoId;

                      Publicacion? pub = await _gestionPublicacion.obtenerPublicacionPorId(idABuscar);
                      if (pub != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaPubAdmin(
                              publicacion: pub,
                              administrador: widget.administrador,
                            ),
                          ),
                        );
                      } else {
                        throw Exception('La publicación no existe o fue dada de baja.');
                      }
                    } else {
                      String idUsuarioBuscar = '';
                      
                      if (reporte['tipo'] == 'CALIFICACION') {
                        final String publicacionId = reporte['publicacionId'] ?? '';
                        var ratingDoc = await FirebaseFirestore.instance
                            .collection('publications')
                            .doc(publicacionId)
                            .collection('ratings')
                            .doc(objetoId)
                            .get();
                        
                        if (ratingDoc.exists) {
                          final dataComentario = ratingDoc.data();
                          
                          idUsuarioBuscar = dataComentario?['viajeroId'] ?? 
                                            dataComentario?['usuarioId'] ?? 
                                            reporte['autorObjetoId'] ?? '';
                        } else {
                          throw Exception('El comentario asociado al reporte no fue encontrado.');
                        }
                      } else {
                        idUsuarioBuscar = objetoId;
                      }

                      if (idUsuarioBuscar.isEmpty) {
                        throw Exception('No se pudo determinar el ID del usuario.');
                      }

                      final usuarioEncontrado = await _gestionUsuario.obtenerInformacion(idUsuarioBuscar);

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PerfilUsuario(
                              usuarioSeleccionado: usuarioEncontrado, 
                              administrador: widget.administrador,
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al redirigir: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                icon: Icon(iconoBotonDinamico, color: Colors.black, size: 20),
                label: Text(textoBotonDinamico, style: const TextStyle(fontSize: 16, color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}