import 'package:cloud_firestore/cloud_firestore.dart';

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


  Future<List<Map<String, dynamic>>> buscarCalificacionesReportadas() async {
    try {
      QuerySnapshot query = await _firestore
          .collectionGroup('ratings')
          .where('contadorReportes', isGreaterThan: 0)
          .orderBy('contadorReportes', descending: true)
          .get();

      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        data['publicacionId'] = doc.reference.parent.parent?.id; 
        return data;
      }).toList();
    } catch (e) {
      print('Error al buscar calificaciones reportadas: $e');
      return [];
    }
  }


  Future<List<Map<String, dynamic>>> buscarPublicacionesReportadas() async {
    try {
      QuerySnapshot query = await _firestore
          .collection('publications')
          .where('contadorReportes', isGreaterThan: 0)
          .orderBy('contadorReportes', descending: true)
          .get();

      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al buscar publicaciones reportadas: $e');
      return [];
    }
  }


  Future<List<Map<String, dynamic>>> buscarReportesPorObjeto(String objetoId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('reports')
          .where('objetoId', isEqualTo: objetoId)
          .get();

      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
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
          throw ArgumentError('publicacionId es requerido para desestimar una calificación');
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
}
