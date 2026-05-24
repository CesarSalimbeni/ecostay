import 'package:ecostay/estilo.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaVistaPerfil extends StatelessWidget {
  const PantallaVistaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        toolbarHeight: 75,
        leading: Container(color: Color.fromARGB(255, 0, 0, 0),),
        title: SearchBar(
          hintText: 'Buscar...', hintStyle: WidgetStateProperty.all(
          const TextStyle(color: Color(0xFF526F75)),),
          leading: const Icon(Icons.search, color: Color(0xFF526F75),), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: WidgetStatePropertyAll(0),),
        actions: [
          Text('Usuario'),
          const CircleAvatar()
        ],
      ),
    );
  }
}