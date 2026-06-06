//Este file contendra las funciones para la busqueda y exploracion de publicaciones, utilizando filtros como titulo,
//ubicacion, calificacion minima, precio minimo y precio maximo.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'publicacion.dart';

class BuscadorExploracion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Esta función sirve para buscar publicaciones utilizando varios filtros.
  //Tambien se puede usar para explorar publicaciones sin filtros, simplemente dejando los parametros como null.
  Future<List<Publicacion>> buscarPublicaciones({
    String? titulo,
    String? ubicacion,
    double? calificacionMin,
    double? precioMin,
    double? precioMax,
  }) async {
    try {
      // 1. Consulta Base: Trae todo ordenado por calificación
      Query query = _firestore.collection('publications').orderBy('calificacionPromedio', descending: true);

      // 2. Filtro de igualdad en Firestore
      if (ubicacion != null && ubicacion.isNotEmpty) {
        query = query.where('ubicacion', isEqualTo: ubicacion);
      }

      // Ejecutamos la consulta en Firestore
      QuerySnapshot snapshot = await query.get();

      // Mapeamos a objetos Publicacion
      List<Publicacion> publicaciones = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Publicacion(
          id: doc.id,
          titulo: data['titulo'] ?? '',
          descripcion: data['descripcion'] ?? '',
          precio: (data['precio'] as num?)?.toDouble() ?? 0.0, 
          ubicacion: data['ubicacion'] ?? '',
          disponibilidad: data['disponibilidad'] ?? false,
          calificacionPromedio: (data['calificacionPromedio'] as num?)?.toDouble() ?? 0.0,
          calificaciones: [],
          politicaCancelacion: data['politicaCancelacion'] ?? '',
        );
      }).toList();

      // 3. FILTROS EN MEMORIA (Dart)
      
      // Filtro por calificación mínima
      if (calificacionMin != null) {
        publicaciones = publicaciones.where((pub) => pub.calificacionPromedio >= calificacionMin).toList();
      }

      // Filtro por precio mínimo
      if (precioMin != null) {
        publicaciones = publicaciones.where((pub) => pub.precio >= precioMin).toList();
      }

      // Filtro por precio máximo
      if (precioMax != null) {
        publicaciones = publicaciones.where((pub) => pub.precio <= precioMax).toList();
      }

      // Filtro por coincidencia de texto en el título (ignora mayúsculas y el orden de las palabras)
      if (titulo != null && titulo.isNotEmpty) {
        String queryMinuscula = titulo.toLowerCase();
        publicaciones = publicaciones.where((pub) {
          return pub.titulo.toLowerCase().contains(queryMinuscula);
        }).toList();
      }

      return publicaciones;
    } catch (e) {
      print('Error en la búsqueda: $e'); 
      return [];
    }
  }
}