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

  void calificarServicio(dynamic servicio, dynamic calif) {
    print('$nombre (Viajero) calificó el servicio.');
  }

  dynamic descargarComprobante(dynamic reserva) {
    print('$nombre (Viajero) descargando comprobante PDF...');
    return "comprobante_reserva.pdf"; // Simulación de PDF
  }
}