import 'calificacion.dart';

class Publicacion {
  final String id;
  final String titulo;
  final String descripcion;
  final double precio; // Precio por noche o por servicio
  final String ubicacion;
  final bool disponibilidadtransporte; //Transporte disponible o no.
  final double calificacionPromedio;
  final List<Calificacion> calificaciones;
  final String politicaCancelacion;
  final String estilo; //Playa, montaña, bosque, etc
  final String nombreAnfitrion;
  final int cuposMax;
  final int cuposActual;
  final String? imagenUrl;

  Publicacion({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.ubicacion,
    required this.disponibilidadtransporte,
    required this.calificacionPromedio,
    required this.calificaciones,
    required this.politicaCancelacion,
    required this.estilo,
    required this.cuposMax,
    required this.cuposActual,
    required this.nombreAnfitrion,
    this.imagenUrl,
  });

  //Agregar un toMap para optimizar y facilitar codigo.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'ubicacion': ubicacion,
      'disponibilidadtransporte': disponibilidadtransporte,
      'calificacionPromedio': calificacionPromedio,
      'politicaCancelacion': politicaCancelacion,
      'estilo': estilo,
      'cuposMax': cuposMax,
      'cuposActual': cuposActual,
      'nombreAnfitrion': nombreAnfitrion
    };
  }
}