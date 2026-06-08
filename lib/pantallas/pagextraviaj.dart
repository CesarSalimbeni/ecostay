import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/mis_reservas_viaj.dart';
import 'package:ecostay/pantallas/registro.dart';
import 'package:ecostay/pantallas/reserva_viaj.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/gestion_usuario.dart'; 

class PantallaTempviaj extends StatelessWidget {
  final Viajero viajero; 

  const PantallaTempviaj({super.key, required this.viajero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), 
      appBar: AppBar(
        title: Text('Menú Temporal - Hola ${viajero.nombre ?? 'Viajero'}'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,  MaterialPageRoute(
                    builder: (context) => PantallaMisReservas(viajero: viajero),
                  ),
                );
              }, 
              child: const Text('HISTORIAL RESERVAS')
            ),
            TextButton(
              onPressed: () {
                /*Navigator.pushReplacement(context,  MaterialPageRoute(
                    builder: (context) => PantallaReserva(viajero: viajero),
                  ),
                );*/
              },
              child: const Text('RESERVA')
            ),
          ],
        ),
      ),
    );
  }
}