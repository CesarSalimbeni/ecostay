import 'dart:math';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/anf_publicaciones.dart';
import 'package:ecostay/pantallas/anf_reservas.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/anf_perfil.dart';
import 'package:ecostay/widgets/grafico_prestador.dart';
import 'package:ecostay/models/gestion_estadisticas.dart'; 

class HomeAnfitrion extends StatefulWidget {
  final PrestadorServicio prestador;

  const HomeAnfitrion({super.key, required this.prestador});

  @override
  State<HomeAnfitrion> createState() => _HomeAnfitrionState();
}

class _HomeAnfitrionState extends State<HomeAnfitrion> {
  final GestionDashboard _dashboardService = GestionDashboard();
  late Future<Map<String, dynamic>> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _dashboardService.obtenerDashboardHost(widget.prestador.id);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
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
            child: Text(widget.prestador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const Padding(padding: const EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
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
                  onPressed: null, 
                  icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                  label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25, fontWeight: FontWeight.w900)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: widget.prestador)));
                  }, 
                  icon: const Icon(Icons.upload, color: Color(0xFF216A44), size: 28),
                  label: const Text('Publicaciones', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed:() {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: widget.prestador)));
                  },
                  icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilAnfitrion(prestador: widget.prestador)));
                  }, 
                  icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                  label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
              ],
            ),
          ),
      
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _dashboardDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF38664D)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No hay datos disponibles'));
                }

                final datos = snapshot.data!;
                final pubActivas = datos['publicacionesActivas'].toString();
                final resMes = datos['reservasDelMes'].toString();
                final ingresos = '\$${(datos['ingresosMesActual'] as double).toStringAsFixed(1)}';
                final calificacion = datos['calificacionPromedioGeneral'].toString();
                final historico = datos['ingresosMensualesHistoricos'] as Map<int, double>;

                return SingleChildScrollView(
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
                                Expanded(child: _buildStatCard(Icons.business_center, pubActivas, 'Publicaciones activas')),
                                const SizedBox(width: 16), 
                                Expanded(child: _buildStatCard(Icons.calendar_today, resMes, 'Reservas este mes')),
                                const SizedBox(width: 16), 
                                Expanded(child: _buildStatCard(Icons.attach_money, ingresos, 'Ingresos')),
                                const SizedBox(width: 16), 
                                Expanded(child: _buildStatCard(Icons.star_border, calificacion, 'Calificación Promedio')),
                              ],
                            ),
                            
                            const SizedBox(height: 24), 
                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Enviamos los ingresos históricos reales al gráfico
                                Expanded(flex: 6, child: _buildChartCard(historico)),
                                const SizedBox(width: 16), 
                                Expanded(flex: 4, child: _buildRequestsCard()),
                              ],
                            )
                          ]
                        )
                      )
                    )
                  ),
                );
              },
            ),
          )
        ]
      )
    );
  }


  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(padding: const EdgeInsets.all(19.2), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(color: const Color(0xFF38664D), borderRadius: BorderRadius.circular(9.6)), 
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

  Widget _buildChartCard(Map<int, double> historico) {
    return Container(height: 304, padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), 
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ingresos Mensuales', style: TextStyle(fontFamily: 'Idiqlat', fontSize: 25.6, color: Colors.black)), 
          const Text('Últimos 6 meses', style: TextStyle(color: Color(0xFF6E867A), fontSize: 12.8)), 
          const SizedBox(height: 24), 
          Expanded(
            child: GraficoPrestadorWidget(datosHistoricos: historico), 
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsCard() {
    return Container(height: 304, padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Solicitudes Pendientes', style: TextStyle(fontFamily: 'Idiqlat', fontSize: 25.6, color: Colors.black)),
          const Text('Requieren tu aprobación', style: TextStyle(color: Color(0xFF6E867A), fontSize: 12.8)), 
          const SizedBox(height: 24), 
          
          Container(padding: const EdgeInsets.all(19.2), 
            decoration: BoxDecoration(color: const Color(0xFFF5F7F2), borderRadius: BorderRadius.circular(20)), 
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pedro Ruís', style: TextStyle(fontSize: 14.4, color: Colors.black, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4.8), 
                const Text('Cabaña frente al mar 02-05 Jun 2026', style: TextStyle(color: Color(0xFF6E867A), fontSize: 12)), 
                const SizedBox(height: 16), 
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () { /* Acción para actualizar estado en Firebase */ },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38664D),
                        foregroundColor: Colors.white, 
                        elevation: 0, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), 
                        padding: const EdgeInsets.symmetric(horizontal: 19.2, vertical: 12.8), 
                      ),
                      child: const Text('Aceptar', style: TextStyle(fontSize: 12.8, fontWeight: FontWeight.bold)), 
                    ),
                    const SizedBox(width: 9.6), 
                    ElevatedButton(
                      onPressed: () { /* Acción para denegar estado en Firebase */ },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, 
                        foregroundColor: const Color(0xFF38664D), 
                        elevation: 0,
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