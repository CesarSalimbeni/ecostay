import 'package:ecostay/models/estadoreserva.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/reserva.dart'; 
import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaMisReservas extends StatelessWidget {
  final Viajero viajero; 

  const PantallaMisReservas({super.key, required this.viajero});

  Color _obtenerColorEstado(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.CONFIRMADA:
        return const Color(0xFFBEDA78);
      case EstadoReserva.CANCELADA:
        return Colors.redAccent;
      case EstadoReserva.PENDIENTE:
        return Colors.orangeAccent;
      case EstadoReserva.COMPLETADA:
        return Colors.blueAccent;
    }
  }

  String _obtenerTextoEstado(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.CONFIRMADA:
        return 'Confirmada';
      case EstadoReserva.CANCELADA:
        return 'Cancelada';
      case EstadoReserva.PENDIENTE:
        return 'Pendiente';
      case EstadoReserva.COMPLETADA:
        return 'Completada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        toolbarHeight: 90, 
        leadingWidth: 120, 
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain,),
        ),
        title: SearchBar(
          hintText: 'Buscar...', 
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 20)),
          ),
          const CircleAvatar()
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // MENÚ SUPERIOR
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  TextButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                    label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                    label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25, fontWeight: FontWeight.w900)),
                  ),
                  TextButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                    label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                ],
              ),
            ),

            // TÍTULO
            const Padding(
              padding: EdgeInsets.only(left: 175, top: 40, bottom: 20),
              child: Text(
                'Mis Reservas', 
                style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat', fontWeight: FontWeight.w800, fontSize: 30),
              ),
            ),

            // LISTVIEW DINÁMICO
            Expanded(
              child: viajero.historialReservas.isEmpty
                  ? const Center(
                      child: Text(
                        'Aún no tienes ninguna reserva.', 
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: viajero.historialReservas.length,
                      itemBuilder: (context, index) {
                        final Reserva reserva = viajero.historialReservas[index] as Reserva;

                        // Formateo de fecha: DD/MM/AAAA
                        final String fechaStr = "${reserva.fechaInicio.day}/${reserva.fechaInicio.month}/${reserva.fechaInicio.year}";

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 10),
                          child: Center(
                            child: Container(width: 1240, height: 140, decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(25)),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                              crossAxisAlignment: CrossAxisAlignment.center, children: [
                                  // IMAGEN
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20), 
                                    child: Container(width: 200, height: 110, decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20), image: const DecorationImage(
                                        image: AssetImage('assets/images/fondo.jpg'), fit: BoxFit.cover,),
                                      ),
                                    ),
                                  ),
                                  
                                  // DETALLES DE LA RESERVA
                                  Expanded(
                                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, 
                                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        const Padding(padding: EdgeInsets.only(left: 20),
                                          child: Text('Posada Ecoturística', style: TextStyle(fontSize: 25, 
                                          fontFamily: 'Idiqlat', fontWeight: FontWeight.w800)),),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start, 
                                          children: [
                                            // LUGAR
                                            Padding(padding: const EdgeInsets.only(left: 20),
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                                children: [
                                                  const Padding(padding: EdgeInsets.only(bottom: 10), 
                                                  child: Text('Lugar', style: TextStyle(fontSize: 20))),
                                                  Padding(padding: const EdgeInsets.only(bottom: 10), 
                                                  child: Text(viajero.ciudad, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, maxLines: 1)),
                                                ]
                                              ),
                                            ),
                                            
                                            // FECHA
                                            Expanded(child: Padding(padding: const EdgeInsets.only(left: 20),
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                                children: [
                                                  const Padding(padding: EdgeInsets.only(bottom: 10), 
                                                  child: Text('Fecha', style: TextStyle(fontSize: 20))),
                                                  Padding(padding: const EdgeInsets.only(bottom: 10), 
                                                  child: Text(fechaStr, style: const TextStyle(fontSize: 15, 
                                                  fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, 
                                                  maxLines: 1)),
                                                ]
                                              ),),
                                            ),
                                            
                                            // ANFITRIÓN
                                            const Expanded(child: Padding(padding: EdgeInsets.only(left: 20),
                                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                                  children: [
                                                    Padding(padding: EdgeInsets.only(bottom: 10), 
                                                    child: Text('Anfitrión', style: TextStyle(fontSize: 20))),
                                                    Padding(padding: EdgeInsets.only(bottom: 10), 
                                                    child: Text('Soporte Ecostay', style: TextStyle(fontSize: 15, 
                                                    fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, 
                                                    maxLines: 1)),
                                                  ]
                                                ),
                                              ),
                                            ),
                                            
                                            // TOTAL
                                            Expanded(child: Padding(padding: const EdgeInsets.only(left: 20),
                                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                                  children: [
                                                    const Padding(padding: EdgeInsets.only(bottom: 10), 
                                                    child: Text('Total', style: TextStyle(fontSize: 20))),
                                                    Padding(padding: const EdgeInsets.only(bottom: 10), 
                                                    child: Text('\$${reserva.total.toStringAsFixed(2)}', 
                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), 
                                                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                                                  ]
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  
                                  // ESTATUS DINÁMICO
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    decoration: BoxDecoration(color: _obtenerColorEstado(reserva.estado), 
                                      borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: Text(_obtenerTextoEstado(reserva.estado), style: const TextStyle(
                                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)
                                    ),
                                  ),
                                  
                                  // BOTONES
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                                      children: [
                                        OutlinedButton.icon(onPressed: () {}, 
                                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                                          label: const Text('Contactar', style: TextStyle(fontSize: 25, 
                                          color: Colors.black)), 
                                          style: OutlinedButton.styleFrom(fixedSize: const Size(180, 40), 
                                          side: const BorderSide(color: Colors.black)),
                                        ),
                                        FilledButton.icon(onPressed: () {}, 
                                          icon: const Icon(Icons.info_outline, color: Colors.white),
                                          label: const Text('Detalles', style: TextStyle(fontSize: 25, 
                                          color: Color(0xFFFFFFFF))), 
                                          style: FilledButton.styleFrom(fixedSize: const Size(180, 40), 
                                          backgroundColor: const Color(0xFF216A44)),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}