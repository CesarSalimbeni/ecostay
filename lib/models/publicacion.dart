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
  final String nombreAnfitrion;
  final String? imagenUrl;
  final int contadorReportes; // <--- NUEVO: Agregado para el sistema de moderación

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
    required this.nombreAnfitrion,
    this.imagenUrl,
    this.contadorReportes = 0, // <--- NUEVO: Por defecto inicia en 0
  });
}
