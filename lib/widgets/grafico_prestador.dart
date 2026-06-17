import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/reserva.dart';
import '../models/estadoreserva.dart';

class GraficoPrestadorWidget extends StatefulWidget {
  const GraficoPrestadorWidget({super.key});

  @override
  State<GraficoPrestadorWidget> createState(){
    return _GraficoPrestadorWidgetState();
  }
}

class _GraficoPrestadorWidgetState extends State<GraficoPrestadorWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Guardo el mes seleccionado para filtrar (0 = todos los meses)
  int _mesSeleccionado = 0;

  // Lista de nombres de meses para mostrar en pantalla
  final List<String> _nombresMeses = [
    'Todos',
    'Enero', 'Febrero', 'Marzo', 'Abril',
    'Mayo', 'Junio', 'Julio', 'Agosto',
    'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  // Guardo si quiero ver el gráfico de línea o de barras
  bool _mostrarGraficoLinea = true;

  // Función para obtener las reservas desde Firestore
  Stream<List<Reserva>> _getReservasStream() {
    String? uid = _auth.currentUser?.uid;

    // Si no hay usuario, devuelvo una lista vacía
    if (uid == null) {
      return Stream.value([]);
    }

    return _firestore.collection('reservas').snapshots().map((snapshot) {
      // Creo una lista vacía donde voy a guardar las reservas filtradas
      List<Reserva> reservasFiltradas = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();

        // Verifico que el prestador sea el usuario actual Y que esté pagado
        bool esMiReserva = data['prestadorId'] == uid;
        bool estaPagada = data['estado'] == 'pagado';

        if (esMiReserva && estaPagada) {
          Reserva nuevaReserva = Reserva(
            id: doc.id,
            fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
            fechaFin: (data['fechaFin'] as Timestamp).toDate(),
            total: (data['total'] as num).toDouble(),
            estado: EstadoReserva.COMPLETADA, 
          );

          // Agrego la reserva a mi lista
          reservasFiltradas.add(nuevaReserva);
        }
      }

      return reservasFiltradas;
    });
  }

  // Calculo el total general sumando todas las reservas
  double _calcularTotalGeneral(List<Reserva> reservas) {
    double total = 0.0;
    for (var reserva in reservas) {
      total = total + reserva.total;
    }
    return total;
  }

  // Encuentro el mes con más ingresos
  int _encontrarMejorMes(Map<int, double> montosPorMes) {
    int mejorMes = 1;
    double montoMaximo = 0.0;

    for (int mes = 1; mes <= 12; mes++) {
      double montoActual = montosPorMes[mes] ?? 0.0;

      if (montoActual > montoMaximo) {
        montoMaximo = montoActual;
        mejorMes = mes;
      }
    }

    return mejorMes;
  }

  // Proceso los datos mensuales y filtro si el usuario eligió un mes
  List<FlSpot> _procesarDatosMensuales(List<Reserva> reservas) {
    Map<int, double> montosPorMes = {};
    for (int i = 1; i <= 12; i++) {
      montosPorMes[i] = 0.0;
    }

    // Suma total de cada reserva en su mes correspondiente
    for (var reserva in reservas) {
      int mes = reserva.fechaInicio.month;
      double totalActual = montosPorMes[mes] ?? 0.0;
      montosPorMes[mes] = totalActual + reserva.total;
    }

    // Mapa a una lista de puntos para el gráfico
    List<FlSpot> puntos = [];
    for (int mes = 1; mes <= 12; mes++) {
      double monto = montosPorMes[mes] ?? 0.0;
      FlSpot punto = FlSpot(mes.toDouble(), monto);
      puntos.add(punto);
    }

    return puntos;
  }

  // Filtro de las reservas según el mes seleccionado
  List<Reserva> _filtrarPorMes(List<Reserva> reservas) {
    if (_mesSeleccionado == 0) {
      return reservas;
    }

    // Se crea una lista nueva solo con las reservas del mes elegido
    List<Reserva> reservasFiltradas = [];

    for (var reserva in reservas) {
      if (reserva.fechaInicio.month == _mesSeleccionado) {
        reservasFiltradas.add(reserva);
      }
    }

    return reservasFiltradas;
  }

  // Formato simple para mostrar dinero 
  String _formatearDinero(double monto) {
    int montoEntero = monto.toInt();
    String texto = montoEntero.toString();
    String resultado = '';
    int contador = 0;

    for (int i = texto.length - 1; i >= 0; i--) {
      if (contador > 0 && contador % 3 == 0) {
        resultado = '.$resultado';
      }
      resultado = texto[i] + resultado;
      contador++;
    }

    return '\$$resultado';
  }



  Widget _buildTarjetaResumen(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titulo, 
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(valor, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSelectorMes() {
    return SizedBox(
      height: 36, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _nombresMeses.length,
        itemBuilder: (context, index) {
          bool estaSeleccionado = _mesSeleccionado == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _mesSeleccionado = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: estaSeleccionado ? Colors.green : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: estaSeleccionado ? Colors.green : Colors.grey.shade300,
                ),
              ),
              child: Text(
                _nombresMeses[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: estaSeleccionado ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGraficoLinea(List<FlSpot> spots) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true, 
          drawVerticalLine: false, 
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, 
              interval: 1,
              getTitlesWidget: (value, meta) {
                List<String> abreviaciones = [
                  '', 'E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'
                ];

                int indice = value.toInt();
                if (indice < 1 || indice > 12) return const SizedBox();

                return Text(
                  abreviaciones[indice],
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300), 
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots, 
            isCurved: true, 
            barWidth: 3,
            color: Colors.green,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                bool esMesActual = spot.x.toInt() == _mesSeleccionado;
                return FlDotCirclePainter(
                  radius: esMesActual ? 6 : 3,
                  color: esMesActual ? Colors.orange : Colors.green,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoBarras(List<FlSpot> spots) {
    List<BarChartGroupData> barras = [];

    for (var spot in spots) {
      int mes = spot.x.toInt();
      bool esMesSeleccionado = mes == _mesSeleccionado;

      barras.add(
        BarChartGroupData(
          x: mes,
          barRods: [
            BarChartRodData(
              toY: spot.y,
              color: esMesSeleccionado ? Colors.orange : Colors.green,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                List<String> abreviaciones = [
                  '', 'E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'
                ];
                int indice = value.toInt();
                if (indice < 1 || indice > 12) return const SizedBox();
                return Text(
                  abreviaciones[indice],
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        barGroups: barras,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos StreamBuilder devolviendo una columna expandible limpia
    return StreamBuilder<List<Reserva>>(
      stream: _getReservasStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Error al cargar datos estadísticos'),
          );
        }

        List<Reserva> todasLasReservas = snapshot.data ?? [];
        List<Reserva> reservasFiltradas = _filtrarPorMes(todasLasReservas);

        double totalGeneral = _calcularTotalGeneral(reservasFiltradas);
        int cantidadReservas = reservasFiltradas.length;
        List<FlSpot> spots = _procesarDatosMensuales(todasLasReservas);

        double promedio = 0.0;
        if (cantidadReservas > 0) {
          promedio = totalGeneral / cantidadReservas;
        }

        Map<int, double> montosPorMes = {};
        for (int i = 1; i <= 12; i++) {
          montosPorMes[i] = 0.0;
        }
        for (var r in todasLasReservas) {
          int mes = r.fechaInicio.month;
          montosPorMes[mes] = (montosPorMes[mes] ?? 0.0) + r.total;
        }
        int mejorMes = _encontrarMejorMes(montosPorMes);
        String nombreMejorMes = _nombresMeses[mejorMes];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingresos por mes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _mostrarGraficoLinea = !_mostrarGraficoLinea;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _mostrarGraficoLinea ? Icons.bar_chart : Icons.show_chart,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _mostrarGraficoLinea ? 'Barras' : 'Línea',
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTarjetaResumen(
                    'Total',
                    _formatearDinero(totalGeneral),
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTarjetaResumen(
                    'Reservas',
                    '$cantidadReservas',
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTarjetaResumen(
                    'Promedio',
                    _formatearDinero(promedio),
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (todasLasReservas.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Mejor mes: $nombreMejorMes  •  ${_formatearDinero(montosPorMes[mejorMes] ?? 0)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            _buildSelectorMes(),
            const SizedBox(height: 12),

            SizedBox(
              height: 180, 
              child: _mostrarGraficoLinea
                  ? _buildGraficoLinea(spots)
                  : _buildGraficoBarras(spots),
            ),
            if (reservasFiltradas.isEmpty) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _mesSeleccionado == 0
                      ? 'No hay reservas pagadas aún'
                      : 'No hay reservas en ${_nombresMeses[_mesSeleccionado]}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}