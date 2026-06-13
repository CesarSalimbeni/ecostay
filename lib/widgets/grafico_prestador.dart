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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center
        (child: Text(" Estructura inicial"),
      ),
    );
  }
}