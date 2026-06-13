import 'package:cloud_firestore/cloud_firestore.dart';
import 'calificacion.dart';
import 'publicacion.dart';

class GestionPublicacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> crearPublicacion({
    required String titulo, 
    required String descripcion, 
    required double precio, 
    required String ubicacion, 
    required String autoruid, 
    required bool disponibilidadtransporte, 
    required String politicaCancelacion,
    required String nombreAnfitrion 
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('publications').add({
        'titulo': titulo,
        'descripcion': descripcion,
        'precio': precio,
        'ubicacion': ubicacion,
        'providerId': autoruid,
        'transporte': disponibilidadtransporte,
        'calificacionPromedio': 0.0,
        'politicaCancelacion': politicaCancelacion,
        'nombreAnfitrion': nombreAnfitrion,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'contadorReportes': 0,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear publicación: $e');
    }
  }

  Future<void> editarPublicacion(String publicacionId, Map<String, dynamic> datosActualizados) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).update(datosActualizados);
    } catch (e) {
      throw Exception('Error al editar publicación: $e');
    }
  }


  Future<void> eliminarPublicacion(String publicacionId) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).delete();
    } catch (e) {
      throw Exception('Error al eliminar publicación: $e');
    }
  }

  Future<Publicacion?> obtenerPublicacionPorId(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('publications').doc(publicacionId).get();
      if (!doc.exists) return null;
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return Publicacion(
        id: doc.id,
        titulo: data['titulo'] ?? '',
        descripcion: data['descripcion'] ?? '',
        precio: (data['precio'] as num).toDouble(),
        ubicacion: data['ubicacion'] ?? '',
        disponibilidadtransporte: data['transporte'] ?? false,
        calificacionPromedio: (data['calificacionPromedio'] as num?)?.toDouble() ?? 0.0,
        calificaciones: [], 
        politicaCancelacion: data['politicaCancelacion'] ?? '',
        nombreAnfitrion: data['nombreAnfitrion'] ?? '',
        imagenUrl: data['imagenUrl'],
        contadorReportes: data['contadorReportes'] ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> obtenerProveedor(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('publications').doc(publicacionId).get();
      if (!doc.exists) return null;
      
      String providerId = doc['providerId'];
      return providerId;
    } catch (e) {
      return null;
    }
  }

  Future<List<Publicacion>> obtenerPublicacionesPorProveedor(String providerId) async {
    try {
      QuerySnapshot query = await _firestore.collection('publications').where('providerId', isEqualTo: providerId).get();
      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Publicacion(
          id: doc.id,
          titulo: data['titulo'] ?? '',
          descripcion: data['descripcion'] ?? '',
          precio: (data['precio'] as num).toDouble(),
          ubicacion: data['ubicacion'] ?? '',
          disponibilidadtransporte: data['transporte'] ?? false,
          calificacionPromedio: (data['calificacionPromedio'] as num?)?.toDouble() ?? 0.0,
          calificaciones: [], 
          politicaCancelacion: data['politicaCancelacion'] ?? '',
          nombreAnfitrion: data['nombreAnfitrion'] ?? '',
          imagenUrl: data['imagenUrl'],
          contadorReportes: data['contadorReportes'] ?? 0, 
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

class GestionCalificacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> agregarCalificacion({
    required String publicacionId, 
    required String viajeroId, 
    required String reservacionId, 
    required String comentario, 
    required double puntaje,
    required String nombreUsuario
  }) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).collection('ratings').add({
        'viajeroId': viajeroId,
        'reservacionId': reservacionId,
        'comentario': comentario,
        'puntaje': puntaje,
        'nombreUsuario': nombreUsuario,
        'fecha': FieldValue.serverTimestamp(),
        'contadorReportes': 0, 
      });
      await calcularCalificacionPromedio(publicacionId);
    } catch (e) {
      throw Exception('Error al calificar: $e');
    }
  }


  Future<List<Calificacion>> obtenerCalificaciones(String publicacionId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('publications').doc(publicacionId).collection('ratings').get();
      return snapshot.docs.map((doc) {
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
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> eliminarCalificacion(String publicacionId, String calificacionId) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).collection('ratings').doc(calificacionId).delete();
      await calcularCalificacionPromedio(publicacionId);
      print('Calificación eliminada exitosamente');
    } catch (e) {
      print('Error al eliminar calificación: $e');
    }
  }
  Future<void> calcularCalificacionPromedio(String publicacionId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('publications').doc(publicacionId).collection('ratings').get();
      if (snapshot.docs.isEmpty) {
        await _firestore.collection('publications').doc(publicacionId).update({'calificacionPromedio': 0.0});
        return;
      }
      double suma = 0;
      for (var doc in snapshot.docs) {
        suma += (doc['puntaje'] as num).toDouble();
      }
      double promedio = suma / snapshot.docs.length;
      await _firestore.collection('publications').doc(publicacionId).update({'calificacionPromedio': promedio});
    } catch (e) {
      print('Error al calcular promedio: $e');
    }
  }
}
