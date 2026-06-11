import 'package:ecostay/models/estadoreserva.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'reserva.dart';
import 'gestion_reservacion.dart';
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
    required this.telefono,
    required this.cedula,
    required this.ciudad,
    required this.historialReservas,
  }): super(rol: 'cliente');

  void solicitarReserva(DateTime fechaInicio, DateTime fechaFin, double total, String publicacionId) {
    Reserva nuevaReserva = Reserva(
      id: '', // Se asignará al guardar en Firestore
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      estado: EstadoReserva.PENDIENTE,
      total: total,
    );
    GestionReservacion().crearReserva(nuevaReserva, id, publicacionId);
    
  }

  void calificarServicio(String publicacionId, String reservacionId, String comentario, double puntaje) {
    GestionCalificacion gestionCalificacion = GestionCalificacion();
    gestionCalificacion.agregarCalificacion(
      publicacionId: publicacionId,
      viajeroId: id,
      reservacionId: reservacionId,
      comentario: comentario,
      puntaje: puntaje,
      nombreUsuario: nombre,
    );
  }

  dynamic descargarComprobante(dynamic reserva) {
    print('$nombre (Viajero) descargando comprobante PDF...');
    return "comprobante_reserva.pdf"; // Simulación de PDF
  }

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