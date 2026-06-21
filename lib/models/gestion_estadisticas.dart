import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/estadoreserva.dart';

class GestionDashboard {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1. Obtiene SOLO los usuarios cuyo estado sea 'activo' (Excluye suspendidos)
  Future<int> obtenerUsuariosActivos() async {
    try {
      AggregateQuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('suspendido', isEqualTo: false) // Filtro de estado
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw('Error al obtener usuarios activos: $e');
    }
  }

  /// Obtiene las publicaciones activas
  Future<int> obtenerPublicacionesActivas() async {
    try {
      
      AggregateQuerySnapshot snapshot = await _firestore
          .collection('publications')
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      throw('Error al obtener publicaciones activas: $e');
    }
  }

  /// 3. Obtiene la cantidad de reservas vigentes (PENDIENTES y CONFIRMADAS)
  Future<int> obtenerReservasActivas() async {
    try {
      // Usamos whereIn para agrupar los estados activos en una sola consulta estructurada
      AggregateQuerySnapshot snapshot = await _firestore
          .collection('reservations')
          .where('estado', whereIn: [
            EstadoReserva.PENDIENTE.name,
            EstadoReserva.CONFIRMADA.name,
          ])
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw('Error al obtener reservas activas: $e');
    }
  }

  /// 4. Calcula el volumen financiero de transacciones exitosas
  Future<double> obtenerVolumenTransacciones() async {
    double volumenTotal = 0.0;
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reservations')
          .where('estado', whereIn: [
            EstadoReserva.CONFIRMADA.name,
            EstadoReserva.COMPLETADA.name,
          ])
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double totalReserva = (data['total'] as num?)?.toDouble() ?? 0.0;
        volumenTotal += totalReserva;
      }

      return volumenTotal;
    } catch (e) {
      throw('Error al calcular el volumen de transacciones: $e');
    }
  }

  /// Consolidado general de métricas ejecutado en paralelo
  Future<Map<String, dynamic>> obtenerMetricasGenerales() async {
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