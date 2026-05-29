import 'package:ecostay/models/gestion_publicacion.dart';

import 'usuario.dart';

class Viajero extends Usuario {
  String rol = "cliente";
  String telefono;
  String cedula;
  String ciudad; // ciudad
  List<dynamic> historialReservas; // List<Reserva>

  Viajero({
    required super.rol,
    required super.id,
    required super.nombre,
    required super.email,
    required super.password,
    required super.fechaRegistro,
    required this.telefono,
    required this.cedula,
    required this.ciudad,
    required this.historialReservas,
  });

  void solicitarReserva(dynamic publicacion) {
    print('$nombre (Viajero) solicitó una reserva.');
  }

  void calificarServicio(String publicacionId, String reservacionId, String comentario, double puntaje) {
    GestionPublicacion gestionPublicacion = GestionPublicacion();
    gestionPublicacion.agregarCalificacion(publicacionId, id, reservacionId, comentario, puntaje);
  }

  dynamic descargarComprobante(dynamic reserva) {
    print('$nombre (Viajero) descargando comprobante PDF...');
    return "comprobante_reserva.pdf"; // Simulación de PDF
  }
}