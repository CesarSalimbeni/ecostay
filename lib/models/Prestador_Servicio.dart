import 'usuario.dart';

class PrestadorServicio extends Usuario {
  String rif;
  String telefono;
  String direccion;
  String cuentaPayPal;
  List<dynamic> estadisticas; // List<Estadistica>

  PrestadorServicio({
    required super.id,
    required super.nombre,
    required super.email,
    required super.password,
    required super.fechaRegistro,
    required this.rif,
    required this.telefono,
    required this.direccion,
    required this.cuentaPayPal,
    required this.estadisticas,
  });

  void crearPublicacion(dynamic datos) {
    print('$nombre (Prestador) creó una nueva publicación.');
  }

  void gestionarCancelacion(dynamic reserva) {
    print('$nombre (Prestador) gestionó una cancelación.');
  }

  void verDashboard() {
    print('Mostrando Dashboard para $nombre.');
  }

  void verEstadisticasGlobales() {
    print('Mostrando estadísticas globales del Prestador.');
  }
}