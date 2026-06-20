import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/estadoreserva.dart';

class GestionDashboard {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1. Obtiene la cantidad total de usuarios registrados en el sistema.
  /// (Asumiendo que tu colección de usuarios se llama 'users')
  Future<int> obtenerUsuariosActivos() async {
    try {
      // Usamos .count() para una consulta ultra rápida y económica en Firestore
      AggregateQuerySnapshot snapshot = await _firestore.collection('users').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw('Error al obtener usuarios activos: $e');
    }
  }

  /// 2. Obtiene la cantidad de publicaciones creadas en la plataforma.
  Future<int> obtenerPublicacionesActivas() async {
    try {
      // Cuenta directamente todos los documentos dentro de 'publications'
      AggregateQuerySnapshot snapshot = await _firestore.collection('publications').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw('Error al obtener publicaciones activas: $e');
    }
  }

  /// 3. Obtiene la cantidad de reservas vigentes (PENDIENTES y CONFIRMADAS).
  /// Excluye las canceladas o completadas según las reglas de tu negocio.
  Future<int> obtenerReservasActivas() async {
    try {
      // Realizamos un filtrado por los estados activos definidos en tu EstadoReserva
      QuerySnapshot snapshotPendientes = await _firestore
          .collection('reservations')
          .where('estado', isEqualTo: EstadoReserva.PENDIENTE.name)
          .get();

      QuerySnapshot snapshotConfirmadas = await _firestore
          .collection('reservations')
          .where('estado', isEqualTo: EstadoReserva.CONFIRMADA.name)
          .get();

      return snapshotPendientes.docs.length + snapshotConfirmadas.docs.length;
    } catch (e) {
      throw('Error al obtener reservas activas: $e');
    }
  }

  /// 4. Calcula el volumen de transacciones (Suma total de los ingresos de reservas exitosas).
  /// Filtra por CONFIRMADA y COMPLETADA para no sumar dinero de reservas canceladas.
  Future<double> obtenerVolumenTransacciones() async {
    double volumenTotal = 0.0;
    try {
      // Traemos las reservas que representen transacciones válidas o liquidadas
      QuerySnapshot snapshot = await _firestore
          .collection('reservations')
          .where('estado', whereIn: [
            EstadoReserva.CONFIRMADA.name,
            EstadoReserva.COMPLETADA.name,
          ])
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Mapeamos el campo 'total' basándonos en tu modelo Reserva
        double totalReserva = (data['total'] as num?)?.toDouble() ?? 0.0;
        volumenTotal += totalReserva;
      }

      return volumenTotal;
    } catch (e) {
      throw('Error al calcular el volumen de transacciones: $e');
    }
  }

  /// Función auxiliar para empaquetar todos los datos del dashboard en una sola llamada.
  Future<Map<String, dynamic>> obtenerMetricasGenerales() async {
    // Ejecutamos todas las consultas en paralelo para mejorar drásticamente el rendimiento
    final resultados = await Future.wait([
      obtenerUsuariosActivos(),
      obtenerPublicacionesActivas(),
      obtenerReservasActivas(),
      obtenerVolumenTransacciones(),
    ]);

    return {
      'usuariosActivos': resultados[0] as int,
      'publicacionesActivas': resultados[1] as int,
      'reservasActivas': resultados[2] as int,
      'volumenTransacciones': resultados[3] as double,
    };
  }
  /// Registra o incrementa el contador de un destino buscado en el mes actual.
  Future<void> registrarBusquedaDestino(String ubicacion) async {
    if (ubicacion.trim().isEmpty) return;

    try {
      // 1. Obtener el año y mes actual en formato YYYY-MM
      DateTime ahora = DateTime.now();
      String anoMes = "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}";
      
      // Limpiamos el texto para evitar duplicados por espacios o mayúsculas
      String destinoLimpio = ubicacion.trim();
      String documentoId = "${anoMes}_$destinoLimpio";

      // 2. Referencia al documento único del mes + destino
      DocumentReference docRef = _firestore.collection('destinos_buscados').doc(documentoId);

      // 3. Guardar o incrementar atómicamente
      await docRef.set({
        'anoMes': anoMes,
        'destino': destinoLimpio,
        'contador': FieldValue.increment(1),
        'ultimaBusqueda': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // 'merge: true' asegura que si no existe, lo crea.
      
    } catch (e) {
      throw('Error al registrar métrica de búsqueda: $e');
    }
  }

  /// Obtiene los destinos más buscados de un mes específico ordenados de mayor a menor.
  /// Formato requerido para [anoMes]: "YYYY-MM" (Ej: "2026-06")
  Future<List<Map<String, dynamic>>> obtenerDestinosMasBuscados({
    required String anoMes, 
    int limite = 5,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('destinos_buscados')
          .where('anoMes', isEqualTo: anoMes)
          .orderBy('contador', descending: true)
          .limit(limite)
          .get();

      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      throw('Error al obtener destinos más buscados: $e');
    }
  }
}