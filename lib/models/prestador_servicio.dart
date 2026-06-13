import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:ecostay/models/reserva.dart';

import 'usuario.dart';

class PrestadorServicio extends Usuario {
  String rol = "host";
  String rif;
  String telefono;
  String direccion;
  String cuentaPayPal;
  List<dynamic> estadisticas;

  List<Publicacion> publicaciones = [];
  List<Reserva> reservas = [];

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

  Future<void> cargarMisDatos() async {
    try {
      GestionPublicacion gestionPub = GestionPublicacion();
      publicaciones = await gestionPub.obtenerPublicacionesPorProveedor(id);

      GestionReservacion gestionRes = GestionReservacion();
      List<Reserva> listaTemporalReservas = [];

      for (Publicacion pub in publicaciones) {
        List<Reserva> reservasDePub = await gestionRes.obtenerReservasPorPublicacion(pub.id);
        listaTemporalReservas.addAll(reservasDePub);
      }

      reservas = listaTemporalReservas;
    } catch (e) {
      throw Exception('Error al cargar datos del prestador: $e');
    }
  }

  void crearPublicacion(Map<String, dynamic> datos) {
    GestionPublicacion gestion = GestionPublicacion();
    gestion.crearPublicacion(
      titulo: datos['titulo'],
      descripcion: datos['descripcion'],
      precio: datos['precio'],
      ubicacion: datos['ubicacion'],
      autoruid: id,
      disponibilidadtransporte: datos['disponibilidad'],
      politicaCancelacion: datos['politicaCancelacion'],
      nombreAnfitrion: nombre,
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