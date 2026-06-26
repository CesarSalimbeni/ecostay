import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/pantallas/admin_explorar.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_perfil.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ecostay/models/gestion_estadisticas.dart'; 

class HomeAdmin extends StatefulWidget {
  final Administrador administrador;

  const HomeAdmin({super.key, required this.administrador});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  final GestionDashboard _dashboardService = GestionDashboard();
  late Future<List<dynamic>> _adminDataFuture;
  final GestionUsuario _gestionUsuario = GestionUsuario();

  @override
  void initState() {
    super.initState();
    
    final ahora = DateTime.now();
    final anoMesActual = "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}";

    _adminDataFuture = Future.wait([
      _dashboardService.obtenerMetricasGenerales(),
      _dashboardService.obtenerDestinosMasBuscados(anoMes: anoMesActual, limite: 5),
    ]);
  }

  @override
  Widget build(BuildContext context) {
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
                      Text(widget.administrador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF216A44),
                        backgroundImage: widget.administrador.imagenUrl != null && widget.administrador.imagenUrl!.isNotEmpty
                            ? NetworkImage(widget.administrador.imagenUrl!)
                            : null,
                        child: widget.administrador.imagenUrl == null || widget.administrador.imagenUrl!.isEmpty
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AdminExplorar(administrador: widget.administrador)),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: widget.administrador)));
                  }, 
                  icon: const Icon(Icons.person_add_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Usuarios', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed:() {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminModeracion(administrador: widget.administrador)));
                  },
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Moderación', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PerfilAdministrador(administrador: widget.administrador)),
                    );
                  },
                  icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                  label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                  fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          
          Padding(padding: const EdgeInsets.only(left: 60.0, top: 40.0, bottom: 20.0),
            child: const Text(
              'Resumen de la plataforma', 
              style: TextStyle(fontSize: 32, fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _adminDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF38664D)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar métricas: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('Sin información disponible por el momento'));
                }

                final metricasGenerales = snapshot.data![0] as Map<String, dynamic>;
                final destinosMasBuscados = snapshot.data![1] as List<Map<String, dynamic>>;

                final totalUsuarios = metricasGenerales['usuariosActivos'].toString();
                final volumenReservas = '\$${(metricasGenerales['volumenTransacciones'] as double).toStringAsFixed(1)}';
                final destinosTotales = metricasGenerales['publicacionesActivas'].toString();

                // CAMBIO AQUÍ: Escala 100% adaptativa según el valor más alto del arreglo
                double maxValGrafico = 10.0; // Valor mínimo por defecto si no hay datos
                if (destinosMasBuscados.isNotEmpty) {
                  // Obtenemos el valor más alto del destino más buscado
                  final maxContadorReal = destinosMasBuscados
                      .map((item) => (item['contador'] as num?)?.toDouble() ?? 0.0)
                      .reduce(max);
                  
                  if (maxContadorReal > 0) {
                    maxValGrafico = maxContadorReal * 1.1; 
                  }
                }

                return SingleChildScrollView(
                  child: Center(
                    child: SizedBox(width: 1240, height: 400,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 460,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(child: _buildStatCard(Icons.people_outline, totalUsuarios, 'Usuarios Activos')),
                                      const SizedBox(width: 20),
                                      Expanded(child: _buildStatCard(Icons.attach_money, volumenReservas, 'Volumen de Reservas')),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(child: _buildStatCard(Icons.explore_outlined, destinosTotales, 'Destinos Totales')),
                                      const SizedBox(width: 20),
                                      Expanded(child: _buildStatCard(Icons.local_offer_outlined, '\$134', 'Reportes de Costos')),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),

                          Expanded(
                            child: Container(padding: const EdgeInsets.all(30.0),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Destinos más buscados',
                                    style: TextStyle(fontSize: 28, fontFamily: 'Idiqlat', fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Por número de búsquedas mensuales',
                                    style: TextStyle(fontSize: 14, color: Color(0xFF7A8E89)),
                                  ),
                                  const SizedBox(height: 20),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Padding(padding: const EdgeInsets.only(left: 90.0, bottom: 25.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: List.generate(5, (index) => Container(width: 1, color: Colors.grey.shade100)),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                ...destinosMasBuscados.map((item) {
                                                  final nombreDestino = item['destino']?.toString() ?? 'Desconocido';
                                                  final contadorBusquedas = (item['contador'] as num?)?.toDouble() ?? 0.0;
                                                  return Expanded(child: _buildBarRow(nombreDestino, contadorBusquedas, maxValGrafico));
                                                }),
                                                if (destinosMasBuscados.length < 5)
                                                  ...List.generate(5 - destinosMasBuscados.length, (index) => const Expanded(
                                                    child: SizedBox())),
                                                const SizedBox(height: 25), 
                                              ],
                                            ),
                                            Positioned(left: 90.0, right: 0, bottom: 0,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  '0', 
                                                  (maxValGrafico * 0.25).round().toString(), 
                                                  (maxValGrafico * 0.5).round().toString(), 
                                                  (maxValGrafico * 0.75).round().toString(), 
                                                  maxValGrafico.round().toString()
                                                ].map((val) => Text(val, style: const TextStyle(fontSize: 12, 
                                                color: Color(0xFF9CB0AA)))).toList(),
                                              ),
                                            )
                                          ],
                                        );
                                      }
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
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

  Widget _buildBarRow(String label, double value, double maxVal) {
    return Row(
      children: [
        SizedBox(width: 80,
          child: Text(label, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF526F75)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Align(alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: maxVal > 0 ? (value / maxVal).clamp(0.0, 1.0) : 0.0,
              child: Container(height: 26,
                decoration: BoxDecoration(color: const Color(0xFF4C8A64), borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
      ],
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
}