import 'usuario.dart';

class Viajero extends Usuario {
  String telefono;
  String cedula;
  String ciudad; // ciudad
  List<dynamic> historialReservas; // List<Reserva>

  Viajero({
    required super.id,
    required super.nombre,
    required super.email,
    required super.fechaRegistro,
    required super.suspendido,
    super.imagenUrl,
    required this.telefono,
    required this.cedula,
    required this.ciudad,
    required this.historialReservas,
  }): super(rol: 'cliente');

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'telefono': telefono,
      'cedula': cedula,
      'ciudad': ciudad,
      'supendido': suspendido
    };
  }
}