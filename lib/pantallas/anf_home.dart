import 'dart:math';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/anf_publicaciones.dart';
import 'package:ecostay/pantallas/anf_reservas.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/anf_perfil.dart';
import 'package:ecostay/widgets/grafico_prestador.dart';
import 'package:ecostay/models/gestion_estadisticas.dart'; 
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/estadoreserva.dart';

class HomeAnfitrion extends StatefulWidget {
  final PrestadorServicio prestador;

  const HomeAnfitrion({super.key, required this.prestador});

  @override
  State<HomeAnfitrion> createState() => _HomeAnfitrionState();
}

class _HomeAnfitrionState extends State<HomeAnfitrion> {
  final GestionDashboard _dashboardService = GestionDashboard();
  final GestionReservacion _gestionReservacion = GestionReservacion();
  
  late Future<Map<String, dynamic>> _dashboardDataFuture;
  late Future<List<ReservaUIWrapper>> _futureSolicitudesPendientes;
  final GestionUsuario _gestionUsuario = GestionUsuario();

  @override
  void initState() {
    super.initState();
    _refrescarDashboard();
  }

  void _refrescarDashboard() {
    setState(() {
      _dashboardDataFuture = _dashboardService.obtenerDashboardHost(widget.prestador.id);
      _futureSolicitudesPendientes = _obtenerSolicitudesPendientes();
    });
  }

  // --- LÓGICA IDÉNTICA A LA PRIMERA PANTALLA ADAPTADA A SOLO PENDIENTES ---
  Future<List<ReservaUIWrapper>> _obtenerSolicitudesPendientes() async {
    List<ReservaUIWrapper> solicitudesPendientes = [];
    try {
      final queryPublicaciones = await FirebaseFirestore.instance
          .collection('publications')
          .where('providerId', isEqualTo: widget.prestador.id)
          .get();

      Map<String, String> infoPublicaciones = {};
      for (var doc in queryPublicaciones.docs) {
        infoPublicaciones[doc.id] = doc.data()['titulo'] ?? 'Sin título';
      }

      if (infoPublicaciones.isEmpty) return [];

      final queryReservas = await FirebaseFirestore.instance
          .collection('reservations')
          .where('publicacionId', whereIn: infoPublicaciones.keys.toList())
          .where('estado', isEqualTo: 'PENDIENTE')
          .get();

      for (var doc in queryReservas.docs) {
        final data = doc.data();
        final reserva = _gestionReservacion.mapToReserva(doc.id, data);
        
        if (reserva.estado != EstadoReserva.PENDIENTE) continue;

        final viajeroId = data['viajeroId'] ?? '';
        final publicacionId = data['publicacionId'] ?? '';

        String nombreViajero = 'Usuario EcoStay';
        if (viajeroId.isNotEmpty) {
          final docViajero = await FirebaseFirestore.instance
              .collection('users') 
              .doc(viajeroId)
              .get();
          if (docViajero.exists) {
            nombreViajero = docViajero.data()?['nombre'] ?? 'Usuario EcoStay';
          }
        }

        solicitudesPendientes.add(
          ReservaUIWrapper(
            reserva: reserva,
            nombreViajero: nombreViajero,
            tituloPublicacion: infoPublicaciones[publicacionId] ?? 'Destino Desconocido',
          ),
        );
      }

      solicitudesPendientes.sort((a, b) => b.reserva.fechaInicio.compareTo(a.reserva.fechaInicio));
      
    } catch (e) {
      debugPrint("Error al mapear solicitudes pendientes en Home: $e");
    }
    return solicitudesPendientes;
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
          Padding(padding: const EdgeInsets.only(right: 20.0),
            child: Tooltip(message: 'Cerrar sesión', preferBelow: true, verticalOffset: 25,
              textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: BoxDecoration(color: const Color(0xFF216A44).withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () async {
                  try {
                    await _gestionUsuario.cerrarSesion();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sesión cerrada con éxito')),
                      );
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) => const PantallaInicio()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar sesión: $e')),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(mainAxisSize: MainAxisSize.min,
                    children: [
                      Text( widget.prestador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      const CircleAvatar(
                        backgroundColor: Color(0xFF216A44),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, 
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
                            
                            Row(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
          const SizedBox(height: 16), 
          
          Expanded(
            child: FutureBuilder<List<ReservaUIWrapper>>(
              future: _futureSolicitudesPendientes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF38664D)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 12, color: Colors.red)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay solicitudes pendientes', style: TextStyle(color: Color(0xFF6E867A), fontSize: 14)),
                  );
                }

                final solicitudes = snapshot.data!;

                return ListView.builder(
                  itemCount: solicitudes.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = solicitudes[index];
                    final reserva = item.reserva;
                    
                    List<String> meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
                    String stringFecha = "${reserva.fechaInicio.day}-${meses[reserva.fechaInicio.month - 1]}";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), 
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F2), borderRadius: BorderRadius.circular(20)
                      ), 
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nombreViajero, 
                            style: const TextStyle(fontSize: 14.4, color: Colors.black, fontWeight: FontWeight.w600)
                          ),
                          const SizedBox(height: 4.8), 
                          Text(
                            '${item.tituloPublicacion} ($stringFecha)', style: const TextStyle(
                              color: Color(0xFF6E867A), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis,
                          ), 
                          const SizedBox(height: 12), 
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await _gestionReservacion.confirmarReserva(reserva.id);
                                  _refrescarDashboard();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF38664D), foregroundColor: Colors.white, 
                                  elevation: 0, 
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), 
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                                ),
                                child: const Text('Aceptar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), 
                              ),
                              const SizedBox(width: 8), 
                              ElevatedButton(
                                onPressed: () async {
                                  await _gestionReservacion.cancelarReserva(reserva.id);
                                  _refrescarDashboard();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, foregroundColor: const Color(0xFF8A1C14),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)), elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), 
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                                ),
                                child: const Text('Rechazar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), 
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}