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

  bool _verificarSuspensionYAlertar() {
    if (widget.prestador.suspendido) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acción bloqueada: Tu cuenta se encuentra suspendida por la administración.'),
          backgroundColor: Color(0xFF903030),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
      return true;
    }
    return false;
  }

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

  Future<void> _logout() async {
    try {
      await _gestionUsuario.cerrarSesion();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada con éxito')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaInicio()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  List<Widget> _buildNavItems(BuildContext context, {bool isVertical = false}) {
    final double fontSize = isVertical ? 18 : 22;
    return [
      TextButton.icon(
        onPressed: null, 
        icon: Icon(Icons.dns, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Dashboard', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize, fontWeight: FontWeight.w900)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaPublicaciones(prestador: widget.prestador)));
        }, 
        icon: Icon(Icons.upload, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Publicaciones', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: widget.prestador)));
        },
        icon: Icon(Icons.send_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Reservas', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilAnfitrion(prestador: widget.prestador)));
        }, 
        icon: Icon(Icons.person_outline, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Perfil', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double anchoPantalla = MediaQuery.of(context).size.width;
    bool esDesktop = anchoPantalla > 950;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), 
        toolbarHeight: esDesktop ? 90 : 70, 
        centerTitle: esDesktop ? true : false,
        leadingWidth: esDesktop ? 120 : null,
        leading: esDesktop 
          ? Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
            )
          : null,
        title: esDesktop 
          ? SizedBox(
              width: 400,
              child: SearchBar(
                hintText: 'Buscar...', 
                hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
                leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
                backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
                elevation: const WidgetStatePropertyAll(0),
              ),
            )
          : const Text('Dashboard Anfitrión', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: esDesktop ? 20.0 : 10.0),
            child: Tooltip(
              message: 'Cerrar sesión', 
              preferBelow: true, 
              verticalOffset: 25,
              textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: BoxDecoration(
                color: const Color(0xFF216A44).withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: _logout,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (esDesktop) ...[
                        Text(
                          widget.prestador.nombre, 
                          overflow: TextOverflow.ellipsis, 
                          maxLines: 1, 
                          style: const TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                      ],
                      CircleAvatar(
                        backgroundColor: const Color(0xFF216A44),
                        backgroundImage: (widget.prestador.imagenUrl != null && widget.prestador.imagenUrl!.isNotEmpty)
                            ? NetworkImage(widget.prestador.imagenUrl!)
                            : null,
                        child: (widget.prestador.imagenUrl == null || widget.prestador.imagenUrl!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: !esDesktop 
        ? Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF216A44)),
                  accountName: Text(widget.prestador.nombre),
                  accountEmail: const Text("Anfitrión / Prestador de Servicio"),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: (widget.prestador.imagenUrl != null && widget.prestador.imagenUrl!.isNotEmpty)
                        ? NetworkImage(widget.prestador.imagenUrl!)
                        : null,
                    child: (widget.prestador.imagenUrl == null || widget.prestador.imagenUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                ..._buildNavItems(context, isVertical: true),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                )
              ],
            ),
          )
        : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          if (esDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: _buildNavItems(context),
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

                int totalColumnasTarjetas = anchoPantalla > 900 ? 4 : (anchoPantalla > 550 ? 2 : 1);

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: esDesktop ? 40.0 : 16.0, 
                    vertical: 30.0
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 992),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumen de tu negocio', 
                            style: TextStyle(fontSize: 32, fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 24), 
                          
                          // SECCIÓN DE TARJETAS ESTADÍSTICAS ADAPTATIVAS (GRIDVIEW)
                          GridView.count(
                            crossAxisCount: totalColumnasTarjetas,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            childAspectRatio: anchoPantalla > 550 ? 1.4 : 1.7,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildStatCard(Icons.business_center, pubActivas, 'Publicaciones activas'),
                              _buildStatCard(Icons.calendar_today, resMes, 'Reservas este mes'),
                              _buildStatCard(Icons.attach_money, ingresos, 'Ingresos'),
                              _buildStatCard(Icons.star_border, calificacion, 'Calificación Promedio'),
                            ],
                          ),
                          
                          const SizedBox(height: 24), 
                          
                          // SECCIÓN DE GRÁFICO Y SOLICITUDES (FLEX DINÁMICO)
                          Flex(
                            direction: anchoPantalla > 850 ? Axis.horizontal : Axis.vertical,
                            crossAxisAlignment: anchoPantalla > 850 ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: anchoPantalla > 850 ? 6 : 0, 
                                child: _buildChartCard(historico)
                              ),
                              SizedBox(width: anchoPantalla > 850 ? 16 : 0, height: anchoPantalla > 850 ? 0 : 24), 
                              Expanded(
                                flex: anchoPantalla > 850 ? 4 : 0, 
                                child: _buildRequestsCard()
                              ),
                            ],
                          )
                        ]
                      ),
                    ),
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
    return Container(
      padding: const EdgeInsets.all(16.0), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(color: const Color(0xFF38664D), borderRadius: BorderRadius.circular(9.6)), 
            child: Icon(icon, color: Colors.white, size: 24), 
          ),
          const SizedBox(height: 10), 
          Flexible(
            child: Text(
              value, 
              style: const TextStyle(fontSize: 26, color: Colors.black, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ), 
          const SizedBox(height: 2), 
          Text(
            label, 
            style: const TextStyle(fontSize: 12.8, color: Color(0xFF6E867A)),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ), 
        ],
      ),
    );
  }

  Widget _buildChartCard(Map<int, double> historico) {
    return Container(
      height: 304, 
      padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    return Container(
      height: 304, 
      padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      margin: const EdgeInsets.only(bottom: 12), 
                      padding: const EdgeInsets.all(14), 
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F2), borderRadius: BorderRadius.circular(20)
                      ), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nombreViajero, 
                            style: const TextStyle(fontSize: 14.4, color: Colors.black, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.8), 
                          Text(
                            '${item.tituloPublicacion} ($stringFecha)', 
                            style: const TextStyle(color: Color(0xFF6E867A), fontSize: 12), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                          ), 
                          const SizedBox(height: 12), 
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (_verificarSuspensionYAlertar()) return;

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
                                  if (_verificarSuspensionYAlertar()) return;

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