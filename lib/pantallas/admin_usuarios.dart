import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AdminUsuarios extends StatelessWidget {
  final Administrador administrador;

  const AdminUsuarios({super.key, required this.administrador});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
        ),
        title: SearchBar(
          hintText: 'Buscar...', 
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
        ),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: Text(administrador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
            style: const TextStyle(fontSize: 20),
            ),
          ),
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF216A44),
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                TextButton.icon(
                  onPressed: () {Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeAdmin(administrador: administrador)),
                    );
                  },  
                  icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                  label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,)),
                ),
                TextButton.icon(onPressed: null,
                  icon: const Icon(Icons.person_add_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Usuarios', style: TextStyle(color: Color(0xFF216A44), fontSize: 25, 
                  fontWeight: FontWeight.w900)),
                ),
                TextButton.icon(
                  onPressed:() {
                      /*Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: prestador),
                        ),
                      );*/
                    },
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Moderacion', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed: () {
                    /*Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PerfilAnfitrion(prestador: prestador)),
                    );*/
                  }, 
                  icon: const Icon(Icons.layers_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Locaciones', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
              ],
            ),
          ),
        ]
      )
    );
  }
}