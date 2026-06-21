//Este file contendra las funciones para la gestion de publicaciones, como crear, editar y eliminar.
//Además de funciones para agregar y obtener calificaciones de las publicaciones, utilizando una subcolección.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/estadoreserva.dart';
import 'package:ecostay/models/gestion_reportes.dart';
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:ecostay/models/reserva.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'calificacion.dart';
import 'publicacion.dart';

class GestionPublicacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Esta función sirve para crear una nueva publicación en Firestore, con los datos proporcionados por el usuario.
  //Se recomienda usar la clase Publicacion rellenar los campos asegurandose de que no falta nada y usar la función toMap()
  Future<String> crearPublicacion(Map<String, dynamic> datos) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('publications')
          .add(datos);
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear publicación: $e');
    }
  }

  //Esta función sirve para editar una publicación existente en Firestore, utilizando el ID de la publicación y los datos actualizados.
  Future<void> editarPublicacion(
    String publicacionId,
    Map<String, dynamic> datosActualizados,
  ) async {
    try {
      await _firestore
          .collection('publications')
          .doc(publicacionId)
          .update(datosActualizados);
    } catch (e) {
      throw Exception('Error al editar publicación: $e');
    }
  }

  //Esta función sirve para eliminar una publicación existente en Firestore, utilizando el ID de la publicación.
  //Ahora incluye validación de seguridad para reservas activas y limpieza integral de imágenes y reportes.
  Future<void> eliminarPublicacion(String publicacionId) async {
    try {
      // 1. CONDICIONAL: Verificar si hay reservas pendientes o confirmadas (activas)
      final GestionReservacion gestionReservas = GestionReservacion();
      List<Reserva> reservasAsociadas = await gestionReservas.obtenerReservasPorPublicacion(publicacionId);
      
      // Buscamos si existe alguna reserva que no esté ni CANCELADA ni COMPLETADA
      bool tieneReservasActivas = reservasAsociadas.any((reserva) => 
        reserva.estado == EstadoReserva.PENDIENTE || 
        reserva.estado == EstadoReserva.CONFIRMADA
      );

      if (tieneReservasActivas) {
        throw Exception(
          'No se puede eliminar la publicación porque tiene reservas activas (pendientes o confirmadas).'
        );
      }

      // 2. ELIMINAR REPORTES ASOCIADOS (Reutilizando la lógica de desestimar)
      // Como queremos borrar la publicación por completo, desestimar sus reportes limpia la colección 'reports'
      final GestionReportes gestionReportes = GestionReportes();
      await gestionReportes.desestimarReporte(
        objetoId: publicacionId, 
        tipo: TipoObjeto.PUBLICACION
      );

      // 3. ELIMINAR IMAGEN ASOCIADA (Firebase Storage)
      GestionImagenPublicacion gestionImagen = GestionImagenPublicacion();
      await gestionImagen.eliminarImagen(publicacionId);

      // 4. ELIMINAR DOCUMENTO PRINCIPAL DE FIRESTORE
      await _firestore.collection('publications').doc(publicacionId).delete();

    } catch (e) {
      throw Exception('Error al eliminar publicación: $e');
    }
  }

  Publicacion mapToPublicacion(String id, Map<String, dynamic> data) {
    return Publicacion(
      id: id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] as num).toDouble(),
      ubicacion: data['ubicacion'] ?? '',
      disponibilidadtransporte: data['disponibilidadtransporte'] ?? false,
      calificacionPromedio:
          (data['calificacionPromedio'] as num?)?.toDouble() ?? 0.0,
      calificaciones:
          [], // Para optimización, no traemos las calificaciones en esta consulta masiva
      politicaCancelacion: data['politicaCancelacion'] ?? '',
      estilo: data['estilo'] ?? 'Otros',
      cuposActual: data['cuposActual'] ?? 0,
      cuposMax: (data['cuposMax'] as num?)?.toInt() ?? 1,
      nombreAnfitrion: data['nombreAnfitrion'] ?? '',
      imagenUrl: data['imagenUrl'], 
    );
  }

  //Esta función sirve para obtener una publicación específica de Firestore, utilizando el ID de la publicación.
  //Si se quiere obtener la imagen de la publicación, se puede usar la función obtenerImagenUrl de la
  //clase GestionImagenPublicacion, pasando el mismo ID de la publicación.
  //Por cuestiones de optimización, esta función no trae las calificaciones de la publicación, solo los datos principales.
  //Para obtener las calificaciones, se debe usar la función obtenerCalificaciones de la clase GestionCalificacion.
  Future<Publicacion?> obtenerPublicacionPorId(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('publications')
          .doc(publicacionId)
          .get();
      if (!doc.exists) return null;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return mapToPublicacion(doc.id, data);
    } catch (e) {
      return null;
    }
  }

  Future<String?> obtenerProveedor(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('publications')
          .doc(publicacionId)
          .get();
      if (!doc.exists) return null;

      String providerId = doc['providerId'];
      return providerId;
    } catch (e) {
      return null;
    }
  }

  //Esta función busca las publicaciones de un proveedor específico, utilizando el ID del proveedor, y devuelve una lista de publicaciones asociadas a ese proveedor.
  Future<List<Publicacion>> obtenerPublicacionesPorProveedor(
    String providerId,
  ) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('publications')
          .where('providerId', isEqualTo: providerId)
          .get();
      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return mapToPublicacion(doc.id, data);
      }).toList();
    } catch (e) {
      return [];
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
    required String nombreUsuario,
  }) async {
    try {
      await _firestore
          .collection('publications')
          .doc(publicacionId)
          .collection('ratings')
          .add({
            'viajeroId': viajeroId,
            'usuarioId': viajeroId,
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
      QuerySnapshot snapshot = await _firestore
          .collection('publications')
          .doc(publicacionId)
          .collection('ratings')
          .get();
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
          nombreUsuario: data['nombreUsuario'] ?? '',
          usuarioId: data['usuarioId'] ?? data['viajeroId'] ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  //Esta función sirve para eliminar una calificación existente en Firestore, utilizando el ID de la publicación y el ID de la calificación.
  Future<void> eliminarCalificacion(
    String publicacionId,
    String calificacionId,
  ) async {
    try {
      await _firestore
          .collection('publications')
          .doc(publicacionId)
          .collection('ratings')
          .doc(calificacionId)
          .delete();
      await calcularCalificacionPromedio(publicacionId);
    } catch (e) {
      throw('Error al eliminar calificación: $e');
    }
  }

  //Esta función sirve para calcular y actualizar la calificación promedio de una publicación específica en
  //Firestore, utilizando el ID de la publicación.
  Future<void> calcularCalificacionPromedio(String publicacionId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('publications')
          .doc(publicacionId)
          .collection('ratings')
          .get();
      if (snapshot.docs.isEmpty) {
        await _firestore.collection('publications').doc(publicacionId).update({
          'calificacionPromedio': 0.0,
        });
        return;
      }
      double totalPuntaje = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + ((data['puntaje'] ?? 0.0) as num).toDouble();
      });
      double promedio = totalPuntaje / snapshot.docs.length;
      await _firestore.collection('publications').doc(publicacionId).update({
        'calificacionPromedio': promedio,
      });
    } catch (e) {
      throw('Error al calcular calificación promedio: $e');
    }
  }
}

//Por cuestiones de modulacion, se hará esta clase por separado.
class GestionImagenPublicacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //Esta función sirve para subir una imagen a Firebase Storage y asociarla a una publicación
  //específica en Firestore, utilizando el ID de la publicación y el archivo de la imagen.
  Future<String?> subirImagen(String publicacionId, XFile imagen) async {
    // <-- Cambiado a XFile
    try {
      String filePath =
          'publicaciones/$publicacionId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await imagen.readAsBytes();

      UploadTask uploadTask = _storage.ref().child(filePath).putData(bytes);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore.collection('publications').doc(publicacionId).update({
        'imagenUrl': downloadUrl,
      });
      return downloadUrl;
    } catch (e) {
      throw('Error al subir imagen: $e');
    }
  }

  //Esta función sirve para eliminar la imagen asociada a una publicación específica en Firestore,
  //utilizando el ID de la publicación.
  Future<void> eliminarImagen(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('publications')
          .doc(publicacionId)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['imagenUrl'] != null) {
          String imageUrl = data['imagenUrl'];
          await _storage.refFromURL(imageUrl).delete();
          await _firestore.collection('publications').doc(publicacionId).update(
            {'imagenUrl': FieldValue.delete()},
          );
        }
      } else {

      }
    } catch (e) {
      throw ('Error al eliminar imagen: $e');
    }
  }

  //Esta función sirve para obtener el URL de la imagen asociada a una publicación específica en Firestore,
  //utilizando el ID de la publicación.
  Future<String?> obtenerImagenUrl(String publicacionId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('publications')
          .doc(publicacionId)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['imagenUrl'] != null) {
          return data['imagenUrl'];
        }
      }
      return null;
    } catch (e) {
      throw('Error al obtener URL de imagen: $e');
    }
  }
}
