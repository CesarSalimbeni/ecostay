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
  List<String> _nombresMeses = [
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

  //Calculo el total general sumando todas las reservas
  double _calcularTotalGeneral(List<Reserva> reservas) {
    double total = 0.0;
    for (var reserva in reservas) {
      total = total + reserva.total;
    }

    return total;
  }

  //Calculo cuántas reservas hay por mes
  Map<int, int> _contarReservasPorMes(List<Reserva> reservas) {
    Map<int, int> conteo = {};

    // Inicializo todos los meses en 0
    for (int mes = 1; mes <= 12; mes++) {
      conteo[mes] = 0;
    }

    //reservas de cada mes
    for (var reserva in reservas) {
      int mes = reserva.fechaInicio.month;
      conteo[mes] = conteo[mes]! + 1;
    }

    return conteo;
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

  //Proceso los datos mensuales y filtro si el usuario eligió un mes
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

    // mapa a una lista de puntos para el gráfico
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
    // se convierte a entero para quitar decimales
    int montoEntero = monto.toInt();
    String texto = montoEntero.toString();
    String resultado = '';
    int contador = 0;

    for (int i = texto.length - 1; i >= 0; i--) {
      if (contador > 0 && contador % 3 == 0) {
        resultado = '.' + resultado;
      }
      resultado = texto[i] + resultado;
      contador++;
    }

    return '\$$resultado';
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center
        (child: Text(" Estructura inicial"),
      ),
    );
  }
}