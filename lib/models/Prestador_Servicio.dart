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
  }) : super(rol: 'host');

  void crearPublicacion(Map<String, dynamic> datos) {
    GestionPublicacion gestion = GestionPublicacion();
    gestion.crearPublicacion(
      titulo: datos['titulo'],
      descripcion: datos['descripcion'],
      precio: datos['precio'],
      ubicacion: datos['ubicacion'],
      autoruid: id,
      disponibilidad: datos['disponibilidad'],
      politicaCancelacion: datos['politicaCancelacion'],
    );
  }

  void gestionarCancelacion(Map<String, dynamic> reserva) {
    print('$nombre (Prestador) gestionó una cancelación.');
  }

  void verDashboard() {
    print('Mostrando Dashboard para $nombre.');
  }

  void verEstadisticasGlobales() {
    print('Mostrando estadísticas globales del Prestador.');
  }
  
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'rif': rif,
      'telefono': telefono,
      'direccion': direccion,
      'cuentaPayPal': cuentaPayPal,
    };
  }
}