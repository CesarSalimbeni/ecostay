import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/registro.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/gestion_usuario.dart'; 

class PantallaTempcliente extends StatelessWidget {
  const PantallaTempcliente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xFFFFFFFF), 
    body: Column(crossAxisAlignment: CrossAxisAlignment.center, 
    children: [
      TextButton(onPressed: () {}, child: Text('REGISTRACIONES RESERVAS')),
      TextButton(onPressed: () {}, child: Text('PUBLICACIONES')),
    ],),);
  }
}