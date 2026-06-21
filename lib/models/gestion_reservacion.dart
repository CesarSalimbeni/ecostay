import 'reserva.dart';
import 'estadoreserva.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Esta clase se encarga de gestionar las reservas realizadas por los usuarios.
/// Funcionará con firestore para almacenar y recuperar las reservas.
class GestionReservacion {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crea una nueva reserva en Firestore si hay suficientes cupos, de lo contrario, no lo hace.
  Future<String> crearReservaSegura({
    required Map<String, dynamic> data,
    required String viajeroId,
    required String publicacionId,
  }) async {
    final publicacionRef = _firestore
        .collection('publications')
        .doc(publicacionId);
    final reservaRef = _firestore
        .collection('reservations')
        .doc(); // Genera un ID automático localmente

    try {
      await _firestore.runTransaction((transaction) async {
        //Leer los datos actuales de la publicación en el servidor
        DocumentSnapshot pubSnapshot = await transaction.get(publicacionRef);
        if (!pubSnapshot.exists) throw Exception("La publicación no existe");

        int cuposMax = (pubSnapshot['cuposMax'] as num?)?.toInt() ?? 0;
        int cuposActual = (pubSnapshot['cuposActual'] as num?)?.toInt() ?? 0;
        int cuposSolicitados = data['cupos'] ?? 0;

        // 2. Verificar disponibilidad real
        if (cuposActual + cuposSolicitados > cuposMax) {
          throw Exception(
            "Lo sentimos, no hay suficientes cupos disponibles.",
          ); //Quizás modificar esto para el frontend.
        }

        // Se agrega los datos para subir.
        data['viajeroId'] = viajeroId;
        data['publicacionId'] = publicacionId;

        //Ejecuta operaciones de manera atómica
        transaction.set(reservaRef, data);
        transaction.update(publicacionRef, {
          'cuposActual': FieldValue.increment(cuposSolicitados),
        });
      });
      return reservaRef.id;
    } catch (e) {
      print('Error en la transacción de reserva: $e');
      rethrow; // Devuelve el error para que la interfaz de Flutter lo muestre al usuario
    }
  }

  // Actualiza el estado de una reserva a confirmada.
  Future<void> confirmarReserva(String reservaId) async {
    try {
      await _firestore.collection('reservations').doc(reservaId).update({
        'estado': EstadoReserva.CONFIRMADA.name,
      });
    } catch (e) {
      print('Error al confirmar la reserva: $e');
    }
  }

  // Cancela una reserva existente y devuelve los cupos a la publicación.
  Future<void> cancelarReserva(String reservaId) async {
    try {
      // 1. Obtener la información de la reserva para saber la publicación y los cupos
      var (reserva, viajeroId, publicacionId) = await obtenerInformacion(
        reservaId,
      );

      // 2. Si la reserva ya estaba cancelada, no hacemos nada para evitar duplicar la devolución
      if (reserva.estado == EstadoReserva.CANCELADA) {
        return;
      }

      // 3. Actualizar el estado de la reserva a CANCELADA
      await _firestore.collection('reservations').doc(reservaId).update({
        'estado': EstadoReserva.CANCELADA.name,
      });

      // 4. Devolver los cupos usando un incremento negativo (restamos lo que se había sumado)
      await _firestore.collection('publications').doc(publicacionId).update({
        'cuposActual': FieldValue.increment(reserva.cupos * -1),
      });
    } catch (e) {
      print('Error al cancelar la reserva y liberar cupos: $e');
      throw Exception('No se pudo cancelar la reserva: $e');
    }
  }

  // Marca una reserva como completada y libera los cupos de la publicación.
  //Misma logica con CancelarReserva, es posible una optimización.
  Future<void> completarReserva(String reservaId) async {
    try {
      var (reserva, viajeroId, publicacionId) = await obtenerInformacion(
        reservaId,
      );

      if (reserva.estado == EstadoReserva.COMPLETADA) return;

      await _firestore.collection('reservations').doc(reservaId).update({
        'estado': EstadoReserva.COMPLETADA.name,
      });

      // Liberar los cupos
      await _firestore.collection('publications').doc(publicacionId).update({
        'cuposActual': FieldValue.increment(reserva.cupos * -1),
      });
    } catch (e) {
      print('Error al completar la reserva: $e');
    }
  }

  Reserva mapToReserva(String id, Map<String, dynamic> data) {
    // Procesador inteligente de fechas
    DateTime procesarFecha(dynamic campo) {
      if (campo is Timestamp) {
        return campo.toDate();
      } else if (campo is String) {
        return DateTime.parse(campo);
      }
      return DateTime.now();
    }

    // Convertimos a String y limpiamos espacios o nulos de forma segura
    final estadoFirestore = (data['estado']?.toString() ?? '').toUpperCase().trim();

    return Reserva(
      id: id,
      fechaInicio: procesarFecha(data['fechaInicio']),
      fechaFin: procesarFecha(data['fechaFin']),
      estado: EstadoReserva.values.firstWhere(
        (e) => e.name.toUpperCase() == estadoFirestore,
        orElse: () => EstadoReserva.PENDIENTE,
      ),
      cupos: data['cupos'],
      total: (data['total'] as num).toDouble(),
    );
  }

  // Obtiene la información de una reserva específica.
  // Incluye las ids del viajero y la publicación para facilitar su uso posterior.
  Future<(Reserva, String, String)> obtenerInformacion(String reservaId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('reservations')
          .doc(reservaId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        return (
          mapToReserva(doc.id, data),
          data['viajeroId'] as String,
          data['publicacionId'] as String,
        );
      }
    } catch (e) {
      print('Error al obtener la reserva: $e');
    }
    throw Exception('Reserva no encontrada');
  }

  // Esta funcion busca una reserva a través de la idViajero y devuelve una lista de reservas asociadas a ese viajero.
  Future<List<Reserva>> obtenerReservasPorViajero(String viajeroId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('reservations')
          .where('viajeroId', isEqualTo: viajeroId)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return mapToReserva(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error al obtener reservas por viajero: $e');
      return [];
    }
  }

  //Esta funcion busca una reserva a través de la idPublicacion y devuelve una lista de reservas asociadas a esa publicación.
  //Si se quiere buscar por prestador se puede hacer una consulta a través de la idPrestador y luego obtener las
  //publicaciones asociadas a ese prestador para finalmente obtener las reservas asociadas a esas publicaciones.
  Future<List<Reserva>> obtenerReservasPorPublicacion(
    String publicacionId,
  ) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('reservations')
          .where('publicacionId', isEqualTo: publicacionId)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return mapToReserva(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error al obtener las reservas de la publicación: $e');
      return [];
    }
  }
}