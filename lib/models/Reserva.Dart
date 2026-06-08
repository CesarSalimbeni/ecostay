import 'estado_reserva.dart';
import 'gestion_reservacion.dart';

class Reserva {
  final String id;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final EstadoReserva estado;
  final double total;

  Reserva({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.total,
  });

  void confirmar() {
    GestionReservacion().confirmarReserva(id);
  }

  void cancelar() {
    GestionReservacion().cancelarReserva(id);
  }
}