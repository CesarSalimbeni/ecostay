import 'dart:math';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/anf_publicaciones.dart';
import 'package:ecostay/pantallas/anf_reservas.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/anf_perfil.dart';
import 'package:ecostay/widgets/grafico_prestador.dart';

class HomeAnfitrion extends StatelessWidget {
  final PrestadorServicio prestador;

  const HomeAnfitrion({super.key, required this.prestador});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Base para tipografía adaptativa, es decir, se adapta tanto para telefono como para computadora.
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // La barra de botones se queda fija aquí arriba fuera de la vista con scroll
          Padding(padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                TextButton.icon(
                  onPressed: null, 
                  icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                  label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                  fontWeight: FontWeight.w900)),
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
                  onPressed:() {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: prestador),
                        ),
                      );
                    },
                  icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
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
      
          // El scrollview se envuelve en un Expanded para abarcar el espacio inferior de forma dinámica
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(padding: const EdgeInsets.only(top: 40, bottom: 40),
                  child: SizedBox(width: 992, 
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resumen de tu negocio', style: TextStyle(fontSize: 32, 
                          fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 24), 
                        
                        Row(
                          children: [
                            Expanded(child: _buildStatCard(Icons.business_center, '2', 'Publicaciones activas')),
                            const SizedBox(width: 16), 
                            Expanded(child: _buildStatCard(Icons.calendar_today, '14', 'Reservas este mes')),
                            const SizedBox(width: 16), 
                            Expanded(child: _buildStatCard(Icons.attach_money, '\$1004.3', 'Ingresos')),
                            const SizedBox(width: 16), 
                            Expanded(child: _buildStatCard(Icons.star_border, '4.8', 'Calificación Promedio')),
                          ],
                        ),
                        
                        const SizedBox(height: 24), 
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: _buildChartCard()),
                            const SizedBox(width: 16), 
                            Expanded(flex: 4, child: _buildRequestsCard()),
                          ],
                        )
                      ]
                    )
                  )
                )
              ),
            ),
          )
        ]
      )
    );
  }

  // --- Helper Methods para construir la UI ---

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(padding: const EdgeInsets.all(19.2), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), 
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(color: const Color(0xFF38664D), borderRadius: BorderRadius.circular(9.6),), 
            child: Icon(icon, color: Colors.white, size: 25.6), 
          ),
          const SizedBox(height: 12.8), 
          Text(value, style: const TextStyle(fontSize: 30.4, color: Colors.black, fontWeight: FontWeight.w500)), 
          const SizedBox(height: 3.2), 
          Text(label, style: const TextStyle(fontSize: 12.8, color: Color(0xFF6E867A))), 
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(height: 304, padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),), 
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ingresos Mensuales', style: TextStyle(fontFamily: 'Idiqlat', fontSize: 25.6, color: Colors.black)), 
          const Text('Últimos 6 meses', style: TextStyle(color: Color(0xFF6E867A), fontSize: 12.8)), 
          const SizedBox(height: 24), 
          // CAMBIO DE INTEGRACIÓN: Se quita el contenedor provisional gris y se añade el gráfico real de fl_chart.
          Expanded(
            child: GraficoPrestadorWidget(), // widget heredó automáticamente el comportamiento elástico. Así la gráfica se estira 
                                            // o encoge sola para llenar la tarjeta blanca sin empujar los textos ni romper los márgenes.
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsCard() {
    return Container(height: 304, padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), 
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Solicitudes Pendientes', style: TextStyle(fontFamily: 'Idiqlat', fontSize: 25.6, 
          color: Colors.black)),
          const Text('Requieren tu aprobación', style: TextStyle(color: Color(0xFF6E867A), fontSize: 12.8)), 
          const SizedBox(height: 24), 
          
          Container(padding: const EdgeInsets.all(19.2), 
            decoration: BoxDecoration(color: const Color(0xFFF5F7F2), borderRadius: BorderRadius.circular(20),), 
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pedro Ruís', style: TextStyle(fontSize: 14.4, color: Colors.black, 
                fontWeight: FontWeight.w600)),
                const SizedBox(height: 4.8), 
                const Text('Cabaña frente al mar 02-05 Jun 2026', style: TextStyle(color: Color(0xFF6E867A), 
                fontSize: 12)), 
                const SizedBox(height: 16), 
                Row(
                  children: [
                    ElevatedButton(onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38664D),
                        foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(horizontal: 19.2, 
                        vertical: 12.8), 
                      ),
                      child: const Text('Aceptar', style: TextStyle(fontSize: 12.8, fontWeight: FontWeight.bold)), 
                    ),
                    const SizedBox(width: 9.6), 
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, 
                      foregroundColor: const Color(0xFF38664D), elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), 
                        padding: const EdgeInsets.symmetric(horizontal: 19.2, vertical: 12.8), 
                      ),
                      child: const Text('Rechazar', style: TextStyle(fontSize: 12.8, fontWeight: FontWeight.bold)), 
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}