//Este file contendra las funciones para la gestion de publicaciones, como crear, editar y eliminar.
//Además de funciones para agregar y obtener calificaciones de las publicaciones, utilizando una subcolección.
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'calificacion.dart';
import 'publicacion.dart';

class GestionPublicacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Esta función sirve para crear una nueva publicación en Firestore, con los datos proporcionados por el usuario.
  Future<void> crearPublicacion({
    required String titulo, 
    required String descripcion, 
    required double precio, 
    required String ubicacion, 
    required String autoruid, 
    required bool disponibilidad, 
    required String politicaCancelacion,
    required String nombreAnfitrion 
  }) async {
    try {
      await _firestore.collection('publications').add({
        'titulo': titulo,
        'descripcion': descripcion,
        'precio': precio,
        'ubicacion': ubicacion,
        'providerId': autoruid,
        'disponibilidad': disponibilidad,
        'calificacionPromedio': 0.0,
        'politicaCancelacion': politicaCancelacion,
        'nombreAnfitrion': nombreAnfitrion,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al crear publicación: $e');
    }
  }

  //Esta función sirve para editar una publicación existente en Firestore, utilizando el ID de la publicación y los datos actualizados.
  Future<void> editarPublicacion(String publicacionId, Map<String, dynamic> datosActualizados) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).update(datosActualizados);
    } catch (e) {
      throw Exception('Error al editar publicación: $e');
    }
  }

  //Esta función sirve para eliminar una publicación existente en Firestore, utilizando el ID de la publicación.
  Future<void> eliminarPublicacion(String publicacionId) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).delete();
      GestionImagenPublicacion gestionImagen = GestionImagenPublicacion();
      await gestionImagen.eliminarImagen(publicacionId);
    } catch (e) {
      throw Exception('Error al eliminar publicación: $e');
    }
  }

  //Esta función sirve para obtener una publicación específica de Firestore, utilizando el ID de la publicación.
  //Si se quiere obtener la imagen de la publicación, se puede usar la función obtenerImagenUrl de la 
  //clase GestionImagenPublicacion, pasando el mismo ID de la publicación.
  //Por cuestiones de optimización, esta función no trae las calificaciones de la publicación, solo los datos principales.
  //Para obtener las calificaciones, se debe usar la función obtenerCalificaciones de la clase GestionCalificacion.
  Future<Publicacion?> obtenerPublicacionPorId(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('publications').doc(publicacionId).get();
      if (!doc.exists) return null;
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      List<Calificacion> listaCalificaciones = await GestionCalificacion().obtenerCalificaciones(publicacionId);

      return Publicacion(
        id: doc.id,
        titulo: data['titulo'] ?? '',
        descripcion: data['descripcion'] ?? '',
        precio: (data['precio'] as num).toDouble(),
        ubicacion: data['ubicacion'] ?? '',
        disponibilidad: data['disponibilidad'] ?? false,
        calificacionPromedio: (data['calificacionPromedio'] as num?)?.toDouble() ?? 0.0,
        calificaciones: listaCalificaciones,
        politicaCancelacion: data['politicaCancelacion'] ?? '',
        nombreAnfitrion: data['nombreAnfitrion'] ?? 'Anfitrión Desconocido', 
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
}

class GestionCalificacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Actualizado para recibir y guardar el "nombreUsuario" en la base de datos
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
      });
      await calcularCalificacionPromedio(publicacionId);
    } catch (e) {
      throw Exception('Error al calificar: $e');
    }
  }

  //Esta función sirve para obtener todas las calificaciones de una publicación específica en Firestore.
  Future<List<Calificacion>> obtenerCalificaciones(String publicacionId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('publications').doc(publicacionId).collection('ratings').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Manejo ultra seguro de fechas nulas de Firebase server timestamps
        DateTime fechaDoc = DateTime.now();
        if (data['fecha'] != null && data['fecha'] is Timestamp) {
          fechaDoc = (data['fecha'] as Timestamp).toDate();
        }

        return Calificacion(
          id: doc.id,
          puntaje: (data['puntaje'] as num).toDouble(),
          comentario: data['comentario'] ?? '',
          fecha: fechaDoc, 
          nombreUsuario: data['nombreUsuario'] ?? 'Usuario anónimo',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  //Esta función sirve para eliminar una calificación existente en Firestore, utilizando el ID de la publicación y el ID de la calificación.
  Future<void> eliminarCalificacion(String publicacionId, String calificacionId) async {
    try {
      await _firestore.collection('publications').doc(publicacionId).collection('ratings').doc(calificacionId).delete();
      await calcularCalificacionPromedio(publicacionId);
      print('Calificación eliminada exitosamente');
    } catch (e) {
      print('Error al eliminar calificación: $e');
    }
  }

  //Esta función sirve para calcular y actualizar la calificación promedio de una publicación específica en 
  //Firestore, utilizando el ID de la publicación.
  Future<void> calcularCalificacionPromedio(String publicacionId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('publications').doc(publicacionId).collection('ratings').get();
      if (snapshot.docs.isEmpty) {
        await _firestore.collection('publications').doc(publicacionId).update({'calificacionPromedio': 0.0});
        return;
      }
      double totalPuntaje = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + ((data['puntaje'] ?? 0.0) as num).toDouble();
      });
      double promedio = totalPuntaje / snapshot.docs.length;
      await _firestore.collection('publications').doc(publicacionId).update({'calificacionPromedio': promedio});
    } catch (e) {
      print('Error al calcular calificación promedio: $e');
    }
  }
}

//Por cuestiones de modulacion, se hará esta clase por separado.
class GestionImagenPublicacion { 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //Esta función sirve para subir una imagen a Firebase Storage y asociarla a una publicación 
  //específica en Firestore, utilizando el ID de la publicación y el archivo de la imagen.
  Future<String?> subirImagen(String publicacionId, File imagen) async {
    try {
      String filePath = 'publicaciones/$publicacionId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = _storage.ref().child(filePath).putFile(imagen);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore.collection('publications').doc(publicacionId).update({'imagenUrl': downloadUrl});
      print('Imagen subida exitosamente');
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  //Esta función sirve para eliminar la imagen asociada a una publicación específica en Firestore, 
  //utilizando el ID de la publicación.
  Future<void> eliminarImagen(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('publications').doc(publicacionId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['imagenUrl'] != null) {
          String imageUrl = data['imagenUrl'];
          await _storage.refFromURL(imageUrl).delete();
          await _firestore.collection('publications').doc(publicacionId).update({'imagenUrl': FieldValue.delete()});
          print('Imagen eliminada exitosamente');
        }
      } else {
        print('No se encontró imagen para eliminar');
      }
    } catch (e) {
      print('Error al eliminar imagen: $e');
    }
  }

  //Esta función sirve para obtener el URL de la imagen asociada a una publicación específica en Firestore, 
  //utilizando el ID de la publicación.
  Future<String?> obtenerImagenUrl(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('publications').doc(publicacionId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['imagenUrl'] != null) {
          return data['imagenUrl'];
        }
      }
      print('No se encontró imagen para esta publicación');
      return null;
    } catch (e) {
      print('Error al obtener URL de imagen: $e');
      return null;
    }
  }
}