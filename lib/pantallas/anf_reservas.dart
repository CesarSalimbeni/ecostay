import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/models/reserva.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/anf_publicaciones.dart';
import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/anf_perfil.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaReservasH extends StatelessWidget {
  final PrestadorServicio prestador;

  const PantallaReservasH({super.key, required this.prestador});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
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
            child: Text(prestador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
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
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Padding(padding: const EdgeInsets.only(top: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  TextButton.icon(
                    onPressed: () {Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeAnfitrion(prestador: prestador)),
                      );
                    },   
                    icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                    label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: prestador)),
                      );
                    }, 
                    icon: const Icon(Icons.upload, color: Color(0xFF216A44), size: 28),
                    label: const Text('Publicaciones', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                    label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                    fontWeight: FontWeight.w900)),
                  ),
                  TextButton.icon(
                    onPressed: () {Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PerfilAnfitrion(prestador: prestador)),
                      );
                    }, 
                    icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                    label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                ],
              ),
            ),

            // --- MAIN CONTENT CONTAINER ---
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(width: 1240, height: 520, 
                  decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(25),), 
                  child: Padding(padding: const EdgeInsets.all(30.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reservas Recibidas', style: TextStyle(fontSize: 32, 
                          fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 20),
                        
                        // --- DYNAMIC LIST VIEW OF BOOKINGS ---
                        Expanded(
                          child: prestador.reservas.isEmpty
                              ? const Center(
                                  child: Text('No has recibido ninguna reserva todavía.', 
                                    style: TextStyle(fontSize: 22, color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: prestador.reservas.length,
                                  itemBuilder: (context, index) {
                                    final reserva = prestador.reservas[index];
                                    return _buildReservaRowItem(reserva);
                                  },
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- COMPONENT: ROW CUSTOM RENDERER ---
  Widget _buildReservaRowItem(Reserva reserva) {
    // Styling states based on status types
    Color statusColor = Colors.orange;
    if (reserva.estado.name == 'CONFIRMADA') statusColor = const Color(0xFF216A44);
    if (reserva.estado.name == 'CANCELADA') statusColor = Colors.red.shade700;

    return Container(margin: const EdgeInsets.symmetric(vertical: 8.0),padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(color: const Color(0xFFF9FBFB), borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Color(0xFF216A44), size: 20),
          const SizedBox(width: 20),
          
          // Dates Frame
          Expanded(flex: 2,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fechas de Estadía', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  '${reserva.fechaInicio.day}/${reserva.fechaInicio.month}/${reserva.fechaInicio.year} - ${reserva.fechaFin.day}/${reserva.fechaFin.month}/${reserva.fechaFin.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Total Cost Frame
          Expanded(
            flex: 1,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Recibido', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  '\$${reserva.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF216A44)),
                ),
              ],
            ),
          ),

          // Status Badge Frame
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              reserva.estado.name,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}