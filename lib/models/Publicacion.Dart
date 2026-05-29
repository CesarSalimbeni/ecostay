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

  void editarPublicacion() {
    // TODO: Agregar lógica para modificar los datos en memoria o base de datos
  }

  void eliminarPublicacion() {
    // TODO: Agregar lógica para dar de baja la publicación
  }
}
