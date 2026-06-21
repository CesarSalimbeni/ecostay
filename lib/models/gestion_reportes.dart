import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/calificacion.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/reporte.dart';

/// Define el tipo de contenido que está siendo reportado.
enum TipoObjeto {
  PUBLICACION,
  CALIFICACION
}

class GestionReportes {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> reportarCalificacion({
    required String objetoId,
    required String publicacionId,
    required String autorCalificacionId,
    required String usuarioReportoId,
    required String motivo,
  }) async {
    try {
      // Evitar que el mismo usuario reporte lo mismo dos veces
      bool yaReportado = await duplicacionReporte(objetoId, usuarioReportoId);
      if (yaReportado) {
        throw Exception('Ya has reportado este elemento anteriormente.');
      }
      
      await _firestore.collection('reports').add({
        'objetoId': objetoId,
        'publicacionId': publicacionId,
        'autorObjetoId': autorCalificacionId,
        'usuarioReportoId': usuarioReportoId,
        'motivo': motivo,
        'tipo': TipoObjeto.CALIFICACION.name,
        'fechaReporte': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('publications')
          .doc(publicacionId)
          .collection('ratings')
          .doc(objetoId)
          .update({
        'contadorReportes': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Error al reportar calificación: $e');
    }
  }

  Future<void> reportarPublicacion({
    required String objetoId,
    required String autorPublicacionId,
    required String usuarioReportoId,
    required String motivo,
  }) async {
    try {
      // Evitar que el mismo usuario reporte lo mismo dos veces
      bool yaReportado = await duplicacionReporte(objetoId, usuarioReportoId);
      if (yaReportado) {
        throw Exception('Ya has reportado este elemento anteriormente.');
      }

      await _firestore.collection('reports').add({
        'objetoId': objetoId,
        'autorObjetoId': autorPublicacionId,
        'usuarioReportoId': usuarioReportoId,
        'motivo': motivo,
        'tipo': TipoObjeto.PUBLICACION.name,
        'fechaReporte': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('publications').doc(objetoId).update({
        'contadorReportes': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Error al reportar publicación: $e');
    }
  }

  Future<List<Calificacion>> buscarCalificacionesReportadas() async {
    try {
      QuerySnapshot query = await _firestore
          .collectionGroup('ratings')
          .where('contadorReportes', isGreaterThan: 0)
          .orderBy('contadorReportes', descending: true)
          .get();

      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        DateTime fechaDoc = DateTime.now();
        if (data['fecha'] != null && data['fecha'] is Timestamp) {
          fechaDoc = (data['fecha'] as Timestamp).toDate();
        }

        return Calificacion(
          id: doc.id,
          puntaje: (data['puntaje'] as num).toDouble(),
          comentario: data['comentario'] ?? '',
          fecha: fechaDoc,
          nombreUsuario: data['nombreUsuario'] ?? '',
          usuarioId: data['usuarioId'] ?? '',
          publicacionId: doc.reference.parent.parent?.id
        );
      }).toList();
    } catch (e) {
      print('Error al buscar calificaciones reportadas: $e');
      return [];
    }
  }

  Future<List<Publicacion>> buscarPublicacionesReportadas() async {
    try {
      GestionPublicacion gestionPublicacion = GestionPublicacion();
      QuerySnapshot query = await _firestore
          .collection('publications')
          .where('contadorReportes', isGreaterThan: 0)
          .orderBy('contadorReportes', descending: true)
          .get();

      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return gestionPublicacion.mapToPublicacion(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error al buscar publicaciones reportadas: $e');
      return [];
    }
  }

  Future<List<Reporte>> buscarReportesPorObjeto(String objetoId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('reports')
          .where('objetoId', isEqualTo: objetoId)
          .get();

      return query.docs.map((doc) {
        return Reporte.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error al buscar reportes del objeto: $e');
      return [];
    }
  }

  Future<void> desestimarReporte({
    required String objetoId,
    required TipoObjeto tipo,
    String? publicacionId, 
  }) async {
    try {
      QuerySnapshot reportesAsociados = await _firestore
          .collection('reports')
          .where('objetoId', isEqualTo: objetoId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in reportesAsociados.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (tipo == TipoObjeto.PUBLICACION) {
        await _firestore.collection('publications').doc(objetoId).update({
          'contadorReportes': 0,
        });
      } else if (tipo == TipoObjeto.CALIFICACION) {
        if (publicacionId == null) {
          throw ArgumentError('publicacionId es obligatorio para calificaciones');
        }
        await _firestore
            .collection('publications')
            .doc(publicacionId)
            .collection('ratings')
            .doc(objetoId)
            .update({
          'contadorReportes': 0,
        });
      }
    } catch (e) {
      throw Exception('Error al desestimar el reporte: $e');
    }
  }

  /// Esta función evita que un reporte se haga dos veces sobre la misma publicación o calificación.
  /// Usar para el frontend
  Future<bool> duplicacionReporte(
    String objetoId,
    String usuarioReportoId,
  ) async {
    QuerySnapshot reporteExistente = await _firestore
        .collection('reports')
        .where('objetoId', isEqualTo: objetoId)
        .where('usuarioReportoId', isEqualTo: usuarioReportoId)
        .limit(1)
        .get();

    if (reporteExistente.docs.isNotEmpty) {
      return true;
    }
    return false;
  }
}