import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaPublicaciones extends StatelessWidget {
  const PantallaPublicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg',fit: BoxFit.contain,),
        ),
        title: SearchBar(
          hintText: 'Buscar...', hintStyle: WidgetStateProperty.all(
          const TextStyle(color: Color(0xFF526F75)),),
          leading: const Icon(Icons.search, color: Color(0xFF526F75),), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: WidgetStatePropertyAll(0),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text('Usuario', overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 20),),
          ),
          const CircleAvatar()
        ],
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton.icon(onPressed: () {}, 
                icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25),),),
              TextButton.icon(onPressed: () {}, 
                icon: const Icon(Icons.upload, color: Color(0xFF216A44), size: 28),
                label: const Text('Publicaciones', style: TextStyle(color: Color(0xFF216A44), 
                fontSize: 25, fontWeight: FontWeight.w900),),),
              TextButton.icon(onPressed: () {}, 
                icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25),),),
              TextButton.icon(onPressed: () {}, 
                icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25),),),
            ],),
          ),
        ])
      )
    );
  }
}