import 'calificacion.dart';

class Publicacion {
  final String id;
  final String titulo;
  final String descripcion;
  final double precio;
  final String ubicacion;
  final bool disponibilidad;
  final Calificacion calificacion;
  final String politicaCancelacion;

  Publicacion({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.ubicacion,
    required this.disponibilidad,
    required this.calificacion,
    required this.politicaCancelacion,
  });

  void editarPublicacion(String titulo, String descripcion, double precio, String ubicacion, bool disponibilidad, String politicaCancelacion) {
    GestionPublicacion gestion = GestionPublicacion();
    gestion.editarPublicacion(id, titulo, calificacion.promedio, descripcion, precio, ubicacion, disponibilidad, politicaCancelacion);
  }

  void eliminarPublicacion() {
    GestionPublicacion gestion = GestionPublicacion();
    gestion.eliminarPublicacion(id);
  }
}