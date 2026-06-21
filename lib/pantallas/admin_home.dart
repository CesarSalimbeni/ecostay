import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HomeAdmin extends StatelessWidget {
  final Administrador administrador;

  const HomeAdmin({super.key, required this.administrador});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
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
            child: Text(administrador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
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
                      MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: administrador)),
                    );
                  }, 
                  icon: const Icon(Icons.person_add_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Usuarios', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed:() {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => AdminModeracion(administrador: administrador),
                        ),
                      );
                    },
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Moderación', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
              ],
            ),
          ),
          
          // --- NEW: Title Header Section ---
          Padding(
            padding: const EdgeInsets.only(left: 60.0, top: 40.0, bottom: 20.0),
            child: const Text(
              'Resumen de la plataforma', style: TextStyle(fontSize: 32, fontFamily: 'Idiqlat',
                color: Colors.black, fontWeight: FontWeight.w800,
              ),
            ),
          ),

          
          Center(
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
                              Expanded(child: _buildStatCard(Icons.people_outline, '23', 'Usuarios Activos')),
                              const SizedBox(width: 20),
                              Expanded(child: _buildStatCard(Icons.attach_money, '\$1004.3', 'Volumen de Reservas')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _buildStatCard(Icons.explore_outlined, '14', 'Destinos Totales')),
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
                    child: Container(
                      padding: const EdgeInsets.all(30.0),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Destinos más buscados',
                            style: TextStyle(fontSize: 28, fontFamily: 'Idiqlat', fontWeight: FontWeight.bold, 
                            color: Colors.black),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Por número de busquedas mensuales',
                            style: TextStyle(fontSize: 14, color: Color(0xFF7A8E89)),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    // Vertical dashed gridlines background
                                    Positioned.fill(
                                      child: Padding(padding: const EdgeInsets.only(left: 90.0, bottom: 25.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: List.generate(5, (index) => Container(
                                            width: 1, color: Colors.grey.shade100,
                                          )),
                                        ),
                                      ),
                                    ),
                                    // Custom Bars Layer
                                    Column(
                                      children: [
                                        Expanded(child: _buildBarRow('Mérida', 1250, 1400)),
                                        Expanded(child: _buildBarRow('Los Roques', 950, 1400)),
                                        Expanded(child: _buildBarRow('Canaima', 850, 1400)),
                                        Expanded(child: _buildBarRow('Choroní', 600, 1400)),
                                        Expanded(child: _buildBarRow('Margarita', 450, 1400)),
                                        const SizedBox(height: 25), 
                                      ],
                                    ),
                                    // X-Axis numerical metrics baseline
                                    Positioned(left: 90.0, right: 0, bottom: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: ['0', '350', '700', '1050', '1400'].map((val) => Text(
                                          val,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CB0AA)),
                                        )).toList(),
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
          )
        ]
      )
    );
  }

  // --- NEW: Helper Builder Row Method for the Chart Bars ---
  Widget _buildBarRow(String label, double value, double maxVal) {
    return Row(
      children: [
        SizedBox(width: 80,
          child: Text(label,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, color: Color(0xFF526F75)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Align(alignment: Alignment.centerLeft,
            child: FractionallySizedBox(widthFactor: value / maxVal,
              child: Container(height: 26,
                decoration: BoxDecoration(color: const Color(0xFF4C8A64), 
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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