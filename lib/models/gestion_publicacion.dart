//Este file contendra las funciones para la gestion de publicaciones, como crear, editar y eliminar.
//Además de funciones para agregar y obtener calificaciones de las publicaciones, utilizando una subcolección.
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'calificacion.dart';
import 'publicacion.dart';

class GestionPublicacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearPublicacion({
    required String titulo, 
    required String descripcion, 
    required double precio, 
    required String ubicacion, 
    required String autoruid, 
    required bool disponibilidad, 
    required String politicaCancelacion
  }) async {
    try {
      await _firestore.collection('publications').add({
        'titulo': titulo,
        'descripcion': descripcion,
        'precio': precio,
        'ubicacion': ubicacion,
        'providerId': autoruid,
        'disponibilidad': disponibilidad,
        'politicaCancelacion': politicaCancelacion,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
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
        disponibilidad: data['disponibilidad'] ?? false,
        calificacionPromedio: data['calificacionPromedio'] ?? 0.0,
        calificaciones: [],
        politicaCancelacion: data['politicaCancelacion'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }
}

class GestionCalificacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> agregarCalificacion(String publicacionId, String viajeroId, String reservacionId, String comentario, double puntaje) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).collection('ratings').add({
        'viajeroId': viajeroId,
        'reservacionId': reservacionId,
        'comentario': comentario,
        'puntaje': puntaje,
        'fecha': FieldValue.serverTimestamp(),
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
        return Calificacion(
          id: doc.id,
          puntaje: data['puntaje'],
          comentario: data['comentario'] ?? '',
          // Conversión crucial de Timestamp a DateTime
          fecha: (data['fecha'] as Timestamp).toDate(), 
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
      double totalPuntaje = snapshot.docs.fold(0.0, (sum, doc) => sum + (doc['puntaje'] as double));
      double promedio = totalPuntaje / snapshot.docs.length;
      await _firestore.collection('publications').doc(publicacionId).update({'calificacionPromedio': promedio});
    } catch (e) {
      print('Error al calcular calificación promedio: $e');
    }
  }
}

//Por cuestiones de modulacion, se hará esta clase por separado.
//Este va a manejar la gestión de las imágenes de las publicaciones, como subir, eliminar 
//y obtener URLs de las imágenes asociadas a cada publicación. Se usará Firebase Storage para esto.
//Solo habrá una imagen por publicación, por lo que se guardará el URL de la imagen en el documento de la publicación en Firestore.
class GestionImagenPublicacion { 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> subirImagen(String publicacionId, File imagen) async {
    try {
      String filePath = 'publicaciones/$publicacionId/${DateTime.now().millisecondsSinceEpoch}.jpg';//Ruta única para cada imagen, usando el ID de la publicación y un timestamp.
      UploadTask uploadTask = _storage.ref().child(filePath).putFile(imagen);//Sube la imagen a Firebase Storage.
      TaskSnapshot snapshot = await uploadTask;//Espera a que la subida termine y obtiene el snapshot.
      String downloadUrl = await snapshot.ref.getDownloadURL();//Obtiene el URL de descarga de la imagen subida.
      await _firestore.collection('publications').doc(publicacionId).update({'imagenUrl': downloadUrl});
      print('Imagen subida exitosamente');
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  Future<void> eliminarImagen(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('publications').doc(publicacionId).get();
      if (doc.exists && doc['imagenUrl'] != null) {
        String imageUrl = doc['imagenUrl'];
        await _storage.refFromURL(imageUrl).delete();
        await _firestore.collection('publications').doc(publicacionId).update({'imagenUrl': FieldValue.delete()});
        print('Imagen eliminada exitosamente');
      } else {
        print('No se encontró imagen para eliminar');
      }
    } catch (e) {
      print('Error al eliminar imagen: $e');
    }
  }

  Future<String?> obtenerImagenUrl(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('publications').doc(publicacionId).get();
      if (doc.exists && doc['imagenUrl'] != null) {
        return doc['imagenUrl'];
      } else {
        print('No se encontró imagen para esta publicación');
        return null;
      }
    } catch (e) {
      print('Error al obtener URL de imagen: $e');
      return null;
    }
  }
}