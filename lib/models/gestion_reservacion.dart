import 'Reserva.Dart';
import 'Estadoreserva.Dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Esta clase se encarga de gestionar las reservas realizadas por los usuarios.
/// Funcionará con firestore para almacenar y recuperar las reservas.
class GestionReservacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crea una nueva reserva en Firestore.
  Future<void> crearReserva(Reserva reserva, String viajeroId, String publicacionId) async {
    try {
      await _firestore.collection('reservations').add({
        'fechaInicio': reserva.fechaInicio,
        'fechaFin': reserva.fechaFin,
        'estado': reserva.estado.toString(),
        'total': reserva.total,
        'viajeroId': viajeroId,
        'publicacionId': publicacionId,
      });
    } catch (e) {
      print('Error al crear la reserva: $e');
    }
  }

  // Actualiza el estado de una reserva a confirmada.
  Future<void> confirmarReserva(String reservaId) async {
    try {
      await _firestore.collection('reservations').doc(reservaId).update({
        'estado': EstadoReserva.CONFIRMADA.toString(),
      });
    } catch (e) {
      print('Error al confirmar la reserva: $e');
    }
  }

  // Cancela una reserva existente.
  Future<void> cancelarReserva(String reservaId) async {
    try {
      await _firestore.collection('reservations').doc(reservaId).update({
        'estado': EstadoReserva.CANCELADA.toString(),
      });
    } catch (e) {
      print('Error al cancelar la reserva: $e');
    }
  }

  // Marca una reserva como completada.
  Future<void> completarReserva(String reservaId) async {
    try {
      await _firestore.collection('reservations').doc(reservaId).update({
        'estado': EstadoReserva.COMPLETADA.toString(),
      });
    } catch (e) {
      print('Error al completar la reserva: $e');
    }
  }

  // Obtiene la información de una reserva específica.
  //Incluye las ids del viajero y la publicación para facilitar su uso posterior.
  Future<(Reserva, String, String)> obtenerInformacion(String reservaId) async {
    try { DocumentSnapshot doc = await _firestore.collection('reservations').doc(reservaId).get();
      if (doc.exists) {
        return (
          Reserva(
            id: doc.id,
            fechaInicio: (doc['fechaInicio'] as Timestamp).toDate(),
            fechaFin: (doc['fechaFin'] as Timestamp).toDate(),
            estado: EstadoReserva.values.firstWhere((e) => e.toString() == doc['estado']),
            total: doc['total'],
          ),
          doc['viajeroId'] as String,
          doc['publicacionId'] as String
        );
      }
    } catch (e) {
      print('Error al obtener la reserva: $e');
    }
    throw Exception('Reserva no encontrada');
  }
}

