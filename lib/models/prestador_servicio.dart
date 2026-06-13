import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:ecostay/models/reserva.dart';

import 'usuario.dart';

class PrestadorServicio extends Usuario {
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
    required super.fechaRegistro,
    required super.suspendido,
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
  
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'rif': rif,
      'telefono': telefono,
      'direccion': direccion,
      'cuentaPayPal': cuentaPayPal,
      'supendido': suspendido
    };
  }
}