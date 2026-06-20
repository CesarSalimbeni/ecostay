import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/reserva.dart';
import '../models/estadoreserva.dart';

class GraficoPrestadorWidget extends StatefulWidget {
  const GraficoPrestadorWidget({super.key});

  @override
  State<GraficoPrestadorWidget> createState() => _GraficoPrestadorWidgetState();
}

class _GraficoPrestadorWidgetState extends State<GraficoPrestadorWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Función para obtener las reservas desde Firestore
  Stream<List<Reserva>> _getReservasStream() {
    String? uid = _auth.currentUser?.uid;

    if (uid == null) {
      return Stream.value([]);
    }

    return _firestore.collection('reservas').snapshots().map((snapshot) {
      List<Reserva> reservasFiltradas = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();

        bool esMiReserva = data['prestadorId'] == uid;
        bool estaPagada = data['estado'] == 'pagado';

        if (esMiReserva && estaPagada) {
          Reserva nuevaReserva = Reserva(
            id: doc.id,
            fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
            fechaFin: (data['fechaFin'] as Timestamp).toDate(),
            total: (data['total'] as num).toDouble(),
            estado: EstadoReserva.COMPLETADA, 
            cupos: (data['cupos'] as num?)?.toInt() ?? 0,
          );

          reservasFiltradas.add(nuevaReserva);
        }
      }

      return reservasFiltradas;
    });
  }

  // Proceso los datos mensuales mapeándolos de Enero (1) a Diciembre (12)
  List<FlSpot> _procesarDatosMensuales(List<Reserva> reservas) {
    Map<int, double> montosPorMes = {};
    for (int i = 1; i <= 12; i++) {
      montosPorMes[i] = 0.0;
    }

    for (var r in reservas) {
      int mes = r.fechaInicio.month;
      montosPorMes[mes] = (montosPorMes[mes] ?? 0.0) + r.total;
    }

    List<FlSpot> puntos = [];
    for (int mes = 1; mes <= 12; mes++) {
      puntos.add(FlSpot(mes.toDouble(), montosPorMes[mes] ?? 0.0));
    }

    return puntos;
  }

  Widget _buildGraficoLinea(List<FlSpot> spots) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true, 
          drawVerticalLine: true, 
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade100, 
            strokeWidth: 1,
            dashArray: [4, 4], // Líneas horizontales discontinuas tenues
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade100, 
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 300, // Intervalos fijos en el eje Y (ej: 0, 300, 600, 900, 1200)
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, 
              interval: 1,
              getTitlesWidget: (value, meta) {
                List<String> abreviaciones = [
                  '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
                ];

                int indice = value.toInt();
                if (indice < 1 || indice > 12) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    abreviaciones[indice],
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                );
              },
            ),
          ),
        ),
        // Ocultamos bordes superior y derecho idéntico a tu mockup
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.shade400, width: 1),
            bottom: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots, 
            isCurved: true, // Curvatura suave de la línea
            preventCurveOverShooting: true,
            barWidth: 2.5,
            color: const Color(0xFF1E4D3A), // Color verde oscuro de tu paleta
            dotData: const FlDotData(show: false), // Desactiva los círculos de los nodos para una línea limpia
            belowBarData: BarAreaData(
              show: true,
              // Degradado desvanecido inferior
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1E4D3A).withValues(alpha: 0.15),
                  const Color(0xFF1E4D3A).withValues(alpha: 0.00),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Reserva>>(
      stream: _getReservasStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E4D3A)),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Error al cargar datos estadísticos'),
          );
        }

        List<Reserva> todasLasReservas = snapshot.data ?? [];
        List<FlSpot> spots = _procesarDatosMensuales(todasLasReservas);

        return Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 10.0),
          child: SizedBox(
            height: 140, // Altura óptima que previene cualquier desbordamiento
            child: _buildGraficoLinea(spots),
          ),
        );
      },
    );
  }
}