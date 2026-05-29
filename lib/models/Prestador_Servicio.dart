import 'package:ecostay/models/gestion_publicacion.dart';

import 'usuario.dart';

class PrestadorServicio extends Usuario {
  String rol = "prestador";
  String rif;
  String telefono;
  String direccion;
  String cuentaPayPal;
  List<dynamic> estadisticas; // List<Estadistica>

  PrestadorServicio({
    required super.rol,
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
    GestionPublicacion gestion = GestionPublicacion();
    gestion.crearPublicacion(datos['titulo'], datos['calificacion'], datos['descripcion'], datos['precio'], datos['ubicacion'], id, datos['disponibilidad'], datos['politicaCancelacion']);
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