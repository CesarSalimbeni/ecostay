import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoPrestadorWidget extends StatefulWidget {
  // 1. Agregamos el parámetro requerido al constructor
  final Map<int, double> datosHistoricos;

  const GraficoPrestadorWidget({
    super.key, 
    required this.datosHistoricos,
  });

  @override
  State<GraficoPrestadorWidget> createState() => _GraficoPrestadorWidgetState();
}

class _GraficoPrestadorWidgetState extends State<GraficoPrestadorWidget> {
  List<FlSpot> _procesarDatosMensuales(Map<int, double> historico) {
    List<FlSpot> puntos = [];
    
    for (int mes = 1; mes <= 12; mes++) {
      double monto = historico[mes] ?? 0.0;
      puntos.add(FlSpot(mes.toDouble(), monto));
    }

    return puntos;
  }

  Widget _buildGraficoLinea(List<FlSpot> spots) {
    double maxMonto = 1200.0;
    for (var spot in spots) {
      if (spot.y > maxMonto) {
        maxMonto = spot.y;
      }
    }
    maxMonto = (maxMonto / 300).ceil() * 300.0;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxMonto,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true, 
          drawVerticalLine: true, 
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade100, 
            strokeWidth: 1,
            dashArray: [4, 4],
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
              reservedSize: 40,
              interval: 300, 
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
            isCurved: true, 
            preventCurveOverShooting: true,
            barWidth: 2.5,
            color: const Color(0xFF1E4D3A), 
            dotData: const FlDotData(show: false), 
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1E4D3A).withAlpha(38),
                  const Color(0xFF1E4D3A).withAlpha(0),
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
    List<FlSpot> spots = _procesarDatosMensuales(widget.datosHistoricos);

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, right: 10.0),
      child: SizedBox(
        height: 140, 
        child: _buildGraficoLinea(spots),
      ),
    );
  }
}