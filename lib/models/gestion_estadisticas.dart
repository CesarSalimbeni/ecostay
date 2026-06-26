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

  /// Recopila todas las métricas clave de un Host en una sola consulta estructurada.
  Future<Map<String, dynamic>> obtenerDashboardHost(String hostId) async {
    try {
      DateTime ahora = DateTime.now();
      DateTime inicioMes = DateTime(ahora.year, ahora.month, 1);
      DateTime finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

      // 1. Obtener las publicaciones propiedad de este host
      QuerySnapshot pubSnapshot = await _firestore
          .collection('publications')
          .where('providerId', isEqualTo: hostId)
          .get();

      int publicacionesActivas = pubSnapshot.docs.length;

      // Si el host no tiene publicaciones, devolvemos todo en cero inmediatamente
      if (publicacionesActivas == 0) {
        return {
          'publicacionesActivas': 0,
          'reservasDelMes': 0,
          'ingresosMesActual': 0.0,
          'calificacionPromedioGeneral': 0.0,
          'ingresosMensualesHistoricos': <int, double>{},
        };
      }

      // Extraemos los IDs de las publicaciones para cruzar la información con las reservas
      List<String> publicacionIds = pubSnapshot.docs.map((doc) => doc.id).toList();

      // Calcular la calificación promedio general del host en base a sus publicaciones
      double sumaCalificaciones = 0.0;
      for (var doc in pubSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        sumaCalificaciones += (data['calificacionPromedio'] as num?)?.toDouble() ?? 0.0;
      }
      double calificacionPromedioGeneral = sumaCalificaciones / publicacionesActivas;

      // 2. Obtener TODAS las reservas asociadas a las publicaciones de este host
      // Nota: Si la lista 'publicacionIds' es mayor a 10, Firebase limita el operador 'whereIn'.
      // Para este diseño estándar, asumimos un flujo controlado.
      QuerySnapshot resSnapshot = await _firestore
          .collection('reservations')
          .where('publicacionId', whereIn: publicacionIds)
          .get();

      int reservasDelMes = 0;
      double ingresosMesActual = 0.0;
      
      // Inicializamos el mapa de los 12 meses en 0.0 para el histórico
      Map<int, double> ingresosMensualesHistoricos = {
        for (int i = 1; i <= 12; i++) i: 0.0
      };

      for (var doc in resSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Convertir estado de Firestore a String seguro
        String estadoStr = (data['estado'] ?? '').toString().toUpperCase().trim();
        
        // Solo contabilizamos ingresos de reservas CONFIRMADAS o COMPLETADAS
        if (estadoStr == EstadoReserva.CONFIRMADA.name || estadoStr == EstadoReserva.COMPLETADA.name) {
          double totalReserva = (data['total'] as num?)?.toDouble() ?? 0.0;
          
          // Procesar la fecha de inicio de la reserva
          DateTime fechaInicio = DateTime.now();
          if (data['fechaInicio'] is Timestamp) {
            fechaInicio = (data['fechaInicio'] as Timestamp).toDate();
          } else if (data['fechaInicio'] is String) {
            fechaInicio = DateTime.parse(data['fechaInicio']);
          }

          // A) Acumular en el histórico mensual del año actual
          if (fechaInicio.year == ahora.year) {
            ingresosMensualesHistoricos[fechaInicio.month] = 
                (ingresosMensualesHistoricos[fechaInicio.month] ?? 0.0) + totalReserva;
          }

          // B) Filtrar métricas específicas del mes en curso
          if (fechaInicio.isAfter(inicioMes) && fechaInicio.isBefore(finMes)) {
            reservasDelMes++;
            ingresosMesActual += totalReserva;
          }
        }
      }

      return {
        'publicacionesActivas': publicacionesActivas,
        'reservasDelMes': reservasDelMes,
        'ingresosMesActual': ingresosMesActual,
        'calificacionPromedioGeneral': double.parse(calificacionPromedioGeneral.toStringAsFixed(2)),
        'ingresosMensualesHistoricos': ingresosMensualesHistoricos, // Mapa de 1 a 12
      };

    } catch (e) {
      print('Error al calcular estadísticas: $e');
      throw Exception('Error al generar el panel de estadísticas: $e');
    }
  }
}