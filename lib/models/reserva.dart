import 'package:cloud_firestore/cloud_firestore.dart';

import 'estadoreserva.dart';

class Reserva {
  final String id;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final EstadoReserva estado;
  final double total; //dinero
  final int cupos;

  Reserva({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.total,
    required this.cupos
  });

  Map<String, dynamic> toMap() {
    return {
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'estado': estado.name,
      'total': total,
      'cupos': cupos,
    };
  }
}