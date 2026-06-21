class Calificacion {
  final String id;
  final double puntaje;
  final String comentario;
  final DateTime fecha;
  final String nombreUsuario;
  final String usuarioId;
  String? publicacionId;

  Calificacion({
    required this.id,
    required this.puntaje,
    required this.comentario,
    required this.fecha,
    required this.nombreUsuario,
    required this.usuarioId,
    this.publicacionId
  });
}