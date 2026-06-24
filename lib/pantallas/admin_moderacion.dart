import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
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
              onPressed: () {Navigator.of(context).pop();alConfirmar();
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
    return Scaffold(backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
        ),
        title: SearchBar(
          hintText: 'Buscar...',
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)),
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
        ),
        actions: [Padding(padding: const EdgeInsets.only(right: 10.0),
            child: Text(widget.administrador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF216A44),
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 15, bottom: 25),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeAdmin(administrador: widget.administrador)),
                    );
                  },
                  icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                  label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: widget.administrador)),
                    );
                  },
                  icon: const Icon(Icons.person_add_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Usuarios', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Moderación', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SECCIÓN DINÁMICA CON FUTUREBUILDER (Colección Principal)
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

                return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  itemCount: listaReportes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Padding(padding: EdgeInsets.only(bottom: 25),
                        child: Text('Reportes', style: TextStyle(color: Colors.black, fontSize: 36,
                            fontWeight: FontWeight.bold, fontFamily: 'Idiqlat',
                          ),
                        ),
                      );
                    }

                    final reporte = listaReportes[index - 1];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: _buildCardReporte(
                        context: context,
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

  // CARD ADAPTADA AL MAPA DE LA COLECCIÓN "REPORTS"
  Widget _buildCardReporte({
    required BuildContext context,
    required Map<String, dynamic> reporte,
    required VoidCallback onIgnorar,
    required VoidCallback onEliminar,
  }) {
    return Container(padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: _obtenerTituloContenido(reporte),
                      builder: (context, snapshot) {
                        String titulo = snapshot.data ?? (reporte['tipo'] == 'CALIFICACION' ? 'Comentario / Reseña' : 'Publicación');
                        return Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Reporte de: $titulo', 
                                style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, 
                                fontFamily: 'Idiqlat'),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatearTiempo(reporte['fechaReporte']),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFB72E2E), borderRadius: BorderRadius.circular(15),
                ),
                child: const Text('Pendiente', style: TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // Motivo del Reporte 
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(color: const Color(0xFFF5F7F2), borderRadius: BorderRadius.circular(15),
            ),
            child: Text('Motivo: ${reporte['motivo'] ?? 'Sin motivo especificado'}',
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),

          if (reporte['tipo'] == 'CALIFICACION') ...[
            const SizedBox(height: 15),
            Container(width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(15), 
                border: Border.all(color: const Color(0xFFF5C6C6), width: 1),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contenido del Comentario:',
                    style: TextStyle(color: Color(0xFFB72E2E), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<String>(
                    future: _obtenerComentarioReportado(reporte),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB72E2E)),
                        );
                      }
                      
                      final comentarioReal = snapshot.data ?? 'Contenido no disponible';
                      return Text('"$comentarioReal"',
                        style: const TextStyle(color: Colors.black87, fontSize: 18, fontStyle: FontStyle.italic),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Fila de Botones de Acción
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onIgnorar,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Ignorar', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF216A44),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 15),

              ElevatedButton.icon(
                onPressed: onEliminar,
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Eliminar', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB72E2E),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 15),

              OutlinedButton.icon(
                onPressed: () {
                  // Puedes usar reporte['autorObjetoId'] o reporte['usuarioReportoId'] si deseas inspeccionar perfiles
                },
                icon: const Icon(Icons.info_outline, color: Colors.black),
                label: const Text('Ver Perfil', style: TextStyle(fontSize: 18, color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
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