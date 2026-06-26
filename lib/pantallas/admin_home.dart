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

  // Helper para cerrar sesión
  Future<void> _logout(BuildContext context) async {
    try {
      await _gestionUsuario.cerrarSesion();
      if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  // Lista de items de navegación superior/lateral
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminExplorar(administrador: widget.administrador)),
          );
        },
        icon: Icon(Icons.search, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Explorar', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: widget.administrador)));
        }, 
        icon: Icon(Icons.person_add_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Usuarios', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed:() {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminModeracion(administrador: widget.administrador)));
        },
        icon: Icon(Icons.shield_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Moderación', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PerfilAdministrador(administrador: widget.administrador)),
          );
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
        leading: esDesktop 
          ? Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
            )
          : null, // Muestra automáticamente el icono hamburguesa en móviles si hay un Drawer
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
          : const Text('EcoStay Admin', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: esDesktop ? 20.0 : 10.0),
            child: InkWell(
              onTap: () => _logout(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (esDesktop) ...[
                      Text(
                        widget.administrador.nombre, 
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 1, 
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                    ],
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
        ],
      ),
      // Panel lateral colapsable (Drawer) para móviles
      drawer: !esDesktop 
        ? Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF216A44)),
                  accountName: Text(widget.administrador.nombre),
                  accountEmail: const Text("Administrador"),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: widget.administrador.imagenUrl != null && widget.administrador.imagenUrl!.isNotEmpty
                        ? NetworkImage(widget.administrador.imagenUrl!)
                        : null,
                    child: widget.administrador.imagenUrl == null || widget.administrador.imagenUrl!.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                ..._buildNavItems(context, isVertical: true),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  onTap: () => _logout(context),
                )
              ],
            ),
          )
        : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // Menú de navegación horizontal superior (Solo para pantallas grandes)
          if (esDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: _buildNavItems(context),
              ),
            ),
          
          Padding(
            padding: EdgeInsets.only(
              left: esDesktop ? 60.0 : 20.0, 
              top: esDesktop ? 40.0 : 25.0, 
              bottom: 20.0
            ),
            child: Text(
              'Resumen de la plataforma', 
              style: TextStyle(
                fontSize: esDesktop ? 32 : 26, 
                fontFamily: 'Idiqlat', 
                color: Colors.black, 
                fontWeight: FontWeight.w800
              ),
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

                double maxValGrafico = 10.0; 
                if (destinosMasBuscados.isNotEmpty) {
                  final maxContadorReal = destinosMasBuscados
                      .map((item) => (item['contador'] as num?)?.toDouble() ?? 0.0)
                      .reduce(max);
                  
                  if (maxContadorReal > 0) {
                    maxValGrafico = maxContadorReal * 1.1; 
                  }
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        // Flex dinámico: Row en computadoras, Column en dispositivos móviles
                        child: Flex(
                          direction: esDesktop ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            // SECCIÓN DE TARJETAS DE MÉTRICAS
                            SizedBox(
                              width: esDesktop ? 460 : double.infinity,
                              child: GridView.count(
                                crossAxisCount: anchoPantalla > 550 ? 2 : 1, // 2 columnas en tablet/PC, 1 en celulares chicos
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(), // Desactiva scroll interno
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 1.6, // Mantiene la proporción estética de los ítems
                                children: [
                                  _buildStatCard(Icons.people_outline, totalUsuarios, 'Usuarios Activos'),
                                  _buildStatCard(Icons.attach_money, volumenReservas, 'Volumen de Reservas'),
                                  _buildStatCard(Icons.explore_outlined, destinosTotales, 'Destinos Totales'),
                                  _buildStatCard(Icons.local_offer_outlined, '\$134', 'Reportes de Costos'),
                                ],
                              ),
                            ),
                            
                            // Espaciado adaptativo
                            esDesktop ? const SizedBox(width: 40) : const SizedBox(height: 30),

                            // SECCIÓN DEL GRÁFICO (DESTINOS MÁS BUSCADOS)
                            Expanded(
                              flex: esDesktop ? 1 : 0,
                              child: Container(
                                height: 400, // Fijamos altura únicamente al contenedor del gráfico para el LayoutBuilder interno
                                width: double.infinity,
                                padding: EdgeInsets.all(esDesktop ? 30.0 : 20.0),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Destinos más buscados',
                                      style: TextStyle(fontSize: 24, fontFamily: 'Idiqlat', fontWeight: FontWeight.bold, color: Colors.black),
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
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 90.0, bottom: 25.0),
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
                                                    ...List.generate(5 - destinosMasBuscados.length, (index) => const Expanded(child: SizedBox())),
                                                  const SizedBox(height: 25), 
                                                ],
                                              ),
                                              Positioned(
                                                left: 90.0, right: 0, bottom: 0,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    '0', 
                                                    (maxValGrafico * 0.25).round().toString(), 
                                                    (maxValGrafico * 0.5).round().toString(), 
                                                    (maxValGrafico * 0.75).round().toString(), 
                                                    maxValGrafico.round().toString()
                                                  ].map((val) => Text(val, style: const TextStyle(fontSize: 12, color: Color(0xFF9CB0AA)))).toList(),
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
        SizedBox(
          width: 80,
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
    return Container(
      padding: const EdgeInsets.all(16.0), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6), 
            decoration: BoxDecoration(color: const Color(0xFF38664D), borderRadius: BorderRadius.circular(9.6)), 
            child: Icon(icon, color: Colors.white, size: 22), 
          ),
          const SizedBox(height: 8), 
          Text(value, style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis), 
          const SizedBox(height: 2), 
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6E867A)), overflow: TextOverflow.ellipsis), 
        ],
      ),
    );
  }
}