import 'calificacion.dart';

class Publicacion {
  final String id;
  final String titulo;
  final String descripcion;
  final double precio; // Precio por noche o por servicio
  final String ubicacion;
  final bool disponibilidad; //Transporte disponible o no.
  final double calificacionPromedio;
  final List<Calificacion> calificaciones;
  final String politicaCancelacion;

  Publicacion({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.ubicacion,
    required this.disponibilidad,
    required this.calificacionPromedio,
    required this.calificaciones,
    required this.politicaCancelacion,
  });
}