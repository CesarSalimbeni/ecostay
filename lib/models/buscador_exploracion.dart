//Este file contendra las funciones para la busqueda y exploracion de publicaciones, utilizando filtros como titulo,
//ubicacion, calificacion minima, precio minimo y precio maximo.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'publicacion.dart';

class BuscadorExploracion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GestionPublicacion gestionPublicacion = GestionPublicacion();

  //Esta función sirve para buscar publicaciones utilizando varios filtros.
  //Tambien se puede usar para explorar publicaciones sin filtros, simplemente dejando los parametros como null.
  Future<List<Publicacion>> buscarPublicaciones({
    String? titulo,
    String? ubicacion,
    String? estilo,
    double? calificacionMin,
    double? precioMin,
    double? precioMax,
    bool? disponibilidadtransporte,
  }) async {
    try {
      // 1. Consulta Base Limpia: Traemos la colección (Evitamos problemas de índices en Firebase Web)
      Query query = _firestore.collection('publications');

      // Ejecutamos la consulta en Firestore
      QuerySnapshot snapshot = await query.get();

      // Mapeamos a objetos Publicacion incluyendo TODOS los campos requeridos por la vista
      List<Publicacion> publicaciones = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return gestionPublicacion.mapToPublicacion(doc.id, data);
      }).toList();

      // 2. FILTROS Y ORDENAMIENTO EN MEMORIA (Dart - 100% Flexible y Rápido)
      
      // Filtro por ubicación exacta (obtenida de los filtros dinámicos)
      if (ubicacion != null && ubicacion.isNotEmpty) {
        publicaciones = publicaciones.where((pub) => pub.ubicacion.trim() == ubicacion.trim()).toList();
      }

      // Filtro por estilo
      if (estilo != null && estilo.isNotEmpty) {
        publicaciones = publicaciones.where((pub) => pub.ubicacion.trim() == estilo.trim()).toList();
      }

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

      if (disponibilidadtransporte != null) {
        publicaciones = publicaciones.where((pub) => pub.disponibilidadtransporte).toList();
      }

      // Filtro por coincidencia de texto en el título (ignora mayúsculas y espacios)
      if (titulo != null && titulo.isNotEmpty) {
        String queryMinuscula = titulo.toLowerCase().trim();
        publicaciones = publicaciones.where((pub) {
          return pub.titulo.toLowerCase().contains(queryMinuscula);
        }).toList();
      }

      // 3. ORDENAMIENTO POR DEFECTO: Mayor calificación primero (Reemplaza al orderBy conflictivo)
      publicaciones.sort((a, b) => b.calificacionPromedio.compareTo(a.calificacionPromedio));

      return publicaciones;
    } catch (e) {
      print('Error en la búsqueda: $e'); 
      return [];
    }
  }
}