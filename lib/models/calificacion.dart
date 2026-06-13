class Calificacion {
  final String id;
  final double puntaje;
  final String comentario;
  final DateTime fecha;
  final String nombreUsuario;
  final int contadorReportes; 

  Calificacion({
    required this.id,
    required this.puntaje,
    required this.comentario,
    required this.fecha,
    required this.nombreUsuario,
    this.contadorReportes = 0, 
  });
}
