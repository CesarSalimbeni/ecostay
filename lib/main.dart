import 'package:flutter/material.dart';
import 'screens/busqueda_screen.dart'; // Importa tu pantalla de búsqueda

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prueba de Búsqueda',
      theme: ThemeData(primarySwatch: Colors.green),

      home: const BusquedaScreen(),
    );
  }
}
