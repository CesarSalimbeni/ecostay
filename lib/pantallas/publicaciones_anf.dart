import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/reservas_anf.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaPublicaciones extends StatelessWidget {
  final PrestadorServicio prestador;
  const PantallaPublicaciones({super.key, required this.prestador});

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
          const CircleAvatar(
            backgroundColor: Color(0xFF216A44),
            child: Icon(Icons.person, color: Colors.white),
          )
        ],
      ),
      
      // Using FutureBuilder to dynamically fire off our data load assignment
      body: FutureBuilder<void>(
        future: prestador.cargarMisDatos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF216A44)),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar datos: ${snapshot.error}'),
            );
          }

          return Column(crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              // --- TOP NAVIGATION SECTION ---
              Padding(padding: const EdgeInsets.only(top: 15),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Action to return to dashboard/home
                      }, 
                      icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                      label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                    ),
                    TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.upload, color: Color(0xFF216A44), size: 28),
                      label: const Text('Publicaciones', style: TextStyle(color: Color(0xFF216A44), fontSize: 25, 
                      fontWeight: FontWeight.w900)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => PantallaReservasH(prestador: prestador),
                          ),
                        );
                      }, 
                      icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                      label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                    ),
                    TextButton.icon(
                      onPressed: () {}, 
                      icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                      label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                    ),
                  ],
                ),
              ),
              
              // --- REFRESHED CONTENT REGION ---
              Expanded(
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: prestador.publicaciones.isEmpty
                          ? const Center(
                              child: Text(
                                'Aún no tienes publicaciones creadas.',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(left: 40.0, top: 40.0, bottom: 40.0, right: 120.0),
                              child: Wrap(alignment: WrapAlignment.center, spacing: 30.0, runSpacing: 30.0,
                                children: prestador.publicaciones.map((pub) {
                                  return _buildPublicacionCard(
                                    titulo: pub.titulo,
                                    subtitulo: pub.ubicacion,
                                    precio: pub.precio,
                                    puntuacion: pub.calificacionPromedio,
                                    imagenUrl: 'https://images.unsplash.com/photo-1506929562872-bb421503ef21?q=80&w=600&auto=format&fit=crop', 
                                  );
                                }).toList(),
                              ),
                            ),
                    ),

                    // FLOATING ACTION BUTTON
                    Align(alignment: Alignment.centerRight,
                      child: Padding(padding: const EdgeInsets.only(right: 40.0),
                        child: SizedBox(width: 65, height: 65,
                          child: FloatingActionButton(backgroundColor: const Color(0xFF1E6144), 
                            onPressed: () {
                              // Action route to open creation form
                            },
                            shape: const CircleBorder(), 
                            child: const Icon(Icons.note_add_outlined, color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- CARD GENERATOR INTERFACE ---
  Widget _buildPublicacionCard({
    required String titulo,
    required String subtitulo,
    required double precio,
    required double puntuacion,
    required String imagenUrl,
  }) {
    return Container(
      width: 350, 
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
                ),
                child: Image.network(imagenUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(top: 15, right: 15,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFC7E08F), borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(puntuacion.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),

          Padding(padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Idiqlat'),
                ),
                const SizedBox(height: 4),
                Text(subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Idiqlat'),
                ),
              ],
            ),
          ),
          
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
          ),
          
          Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Align(alignment: Alignment.centerRight,
              child: Text('\$$precio', maxLines: 1, overflow: TextOverflow.ellipsis, 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF216A44)),
              ),
            ),
          ),
          
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
          ),
          
          Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionBtn(Icons.visibility_outlined, const Color(0xFF216A44), () { /* Read view action */ }),
                _buildActionBtn(Icons.edit_outlined, const Color(0xFF216A44), () { /* Update entry action */ }),
                _buildActionBtn(Icons.delete_outline, const Color(0xFF903030), () { /* Destroy record action */ }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        constraints: const BoxConstraints(), 
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}