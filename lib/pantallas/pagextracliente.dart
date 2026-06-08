import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/publicaciones_anf.dart';
import 'package:ecostay/pantallas/registro.dart';
import 'package:ecostay/pantallas/reservas_anf.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/gestion_usuario.dart'; 

class PantallaTempcliente extends StatelessWidget {
  final PrestadorServicio prestador;

  const PantallaTempcliente({super.key, required this.prestador});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), 
      appBar: AppBar(
        title: Text('Menú Temporal - Hola ${prestador.nombre ?? 'Prestador'}'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,  MaterialPageRoute(
                    builder: (context) => PantallaReservasH(prestador: prestador),
                  ),
                );
              }, 
              child: const Text('REGISTRO RESERVAS')
            ),
            TextButton(
              onPressed: () {
                 Navigator.pushReplacement(context,  MaterialPageRoute(
                    builder: (context) => PantallaPublicaciones(prestador: prestador),
                  ),
                );
              },
              child: const Text('PUBLICACIONES')
            ),
          ],
        ),
      ),
    );
  }
}