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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center
        (child: Text(" Estructura inicial"),
      ),
    );
  }
}