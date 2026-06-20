import 'package:flutter/material.dart';
// Asegúrate de que esta ruta coincida con donde guardaste tu pantalla
import 'screens/locaciones_screen.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Esto quita la etiqueta de debug
      title: 'Ruta Ecoturística',
      // Aquí le decimos a Flutter que la pantalla principal sea la de Locaciones
      home: LocacionesScreen(),
    );
  }
}
