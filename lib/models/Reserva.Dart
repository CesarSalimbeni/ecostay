import 'estado_reserva.dart';

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
    // TODO: Cambiar estado a EstadoReserva.CONFIRMADA
  }

  void cancelar() {
    // TODO: Cambiar estado a EstadoReserva.CANCELADA
  }
}
