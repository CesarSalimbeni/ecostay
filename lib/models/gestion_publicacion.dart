//Este file contendra las funciones para la gestion de publicaciones, como crear, editar y eliminar.
//Además de funciones para agregar y obtener calificaciones de las publicaciones, utilizando una subcolección.
import 'package:cloud_firestore/cloud_firestore.dart';

class GestionPublicacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Para una publicacion se necesitan:titulo, calificacion, descripcion, precio, ubicacion, autoruid, disponibilidad, politicaCancelacion y precio.
  Future<void> crearPublicacion(String titulo, double calificacion, String descripcion, double precio, String ubicacion, String autoruid, bool disponibilidad, String politicaCancelacion) async {
    try {
      await _firestore.collection('publications').add({
        'titulo': titulo,
        'calificacion': calificacion,
        'descripcion': descripcion,
        'precio': precio,
        'ubicacion': ubicacion,
        'providerId': autoruid,
        'disponibilidad': disponibilidad,
        'politicaCancelacion': politicaCancelacion,
        'fechaCreacion': DateTime.now(),
      });
      print('Publicación creada exitosamente');
    } catch (e) {
      print('Error al crear publicación: $e');
    }
  }

  Future<void> editarPublicacion(String publicacionId, String titulo, double calificacion, String descripcion, double precio, String ubicacion, bool disponibilidad, String politicaCancelacion) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).update({
        'titulo': titulo,
        'calificacion': calificacion,
        'descripcion': descripcion,
        'precio': precio,
        'ubicacion': ubicacion,
        'disponibilidad': disponibilidad,
        'politicaCancelacion': politicaCancelacion,
        'fechaEdicion': DateTime.now(),
      });
      print('Publicación editada exitosamente');
    } catch (e) {
      print('Error al editar publicación: $e');
    }
  }

  Future<void> eliminarPublicacion(String publicacionId) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).delete();
      print('Publicación eliminada exitosamente');
    } catch (e) {
      print('Error al eliminar publicación: $e');
    }
  }

  Future<Map<String, dynamic>?> obtenerPublicacion(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('publications').doc(publicacionId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print('Publicación no encontrada');
        return null;
      }
    } catch (e) {
      print('Error al obtener publicación: $e');
      return null;
    }
  }

  //Función para agregar una calificación. Se usa una subcolección 'ratings' dentro de cada publicación para almacenar las calificaciones individuales de los usuarios.
  //Se necesita: Id del viajero, la reservación y la publicación, comentario, fecha, y la puntaje numérico.
  Future<void> agregarCalificacion(String publicacionId, String viajeroId, String reservacionId, String comentario, double puntaje) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).collection('ratings').add({
        'viajeroId': viajeroId,
        'reservacionId': reservacionId,
        'comentario': comentario,
        'puntaje': puntaje,
        'fecha': DateTime.now(),
      });
      print('Calificación agregada exitosamente');
    } catch (e) {
      print('Error al agregar calificación: $e');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerCalificaciones(String publicacionId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('publications').doc(publicacionId).collection('ratings').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener calificaciones: $e');
      return [];
    }
  }

  Future<void> eliminarCalificacion(String publicacionId, String calificacionId) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).collection('ratings').doc(calificacionId).delete();
      print('Calificación eliminada exitosamente');
    } catch (e) {
      print('Error al eliminar calificación: $e');
    }
  }

  Future<double> calcularCalificacionPromedio(String publicacionId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('publications').doc(publicacionId).collection('ratings').get();
      if (snapshot.docs.isEmpty) return 0.0;
      double totalPuntaje = snapshot.docs.fold(0.0, (sum, doc) => sum + (doc['puntaje'] as double));
      return totalPuntaje / snapshot.docs.length;
    } catch (e) {
      print('Error al calcular calificación promedio: $e');
      return 0.0;
    }
  }
}