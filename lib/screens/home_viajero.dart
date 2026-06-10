import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/mis_reservas_viaj.dart';
import 'package:ecostay/pantallas/reserva_viaj.dart';
import 'package:flutter/material.dart';
import 'perfil_viajero_screen.dart';

class HomeViajero extends StatelessWidget {
  final Viajero viajero; 

  const HomeViajero({super.key, required this.viajero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, 
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
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: Text(viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
            style: const TextStyle(fontSize: 20)),
          ),
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF216A44),
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // MENÚ SUPERIOR
          Padding(padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                TextButton.icon(onPressed: null, 
                  icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                  label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                  fontWeight: FontWeight.w900)),
                ),
                TextButton.icon(onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: viajero),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25, )),
                ),
                TextButton.icon(onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PerfilViajero(viajero: viajero),
                      ),
                    );
                  }, 
                  icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                  label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
              ],
            ),
          ),

          // CONTENIDO PRINCIPAL CON SCROLL
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(padding: const EdgeInsets.only(top: 30, bottom: 40),
                  child: SizedBox(width: 992,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // BARRA DE BÚSQUEDA INTERNA Y FILTROS
                        Container(padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 4,
                                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const TextField(
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.search, color: Color(0xFF526F75)),
                                      hintText: '¿A donde vas?',
                                      hintStyle: TextStyle(color: Color(0xFF526F75)),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(flex: 2,
                                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(color: const Color(0xFFF5F7F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('Presupuesto', style: TextStyle(color: Color(0xFF526F75))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black, width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                ),
                                child: const Text('Filtros', style: TextStyle(color: Colors.black, fontSize: 16, 
                                fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF216A44),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                ),
                                child: const Text('Buscar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 35),

                        // FLUJO DINÁMICO DE TARJETAS DE DESTINO CONECTADO A FIRESTORE
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance.collection('publications').get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(color: Color(0xFF216A44)),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error al cargar publicaciones: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Padding(padding: EdgeInsets.all(20.0),
                                  child: Text('No hay publicaciones disponibles', 
                                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                                ),
                              );
                            }

                            final docs = snapshot.data!.docs;

                            return Wrap(spacing: 16, runSpacing: 16,
                              children: docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                
                                final publicacion = Publicacion(
                                  id: doc.id,
                                  titulo: data['titulo'] ?? 'Sin título',
                                  descripcion: data['descripcion'] ?? '',
                                  precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
                                  ubicacion: data['ubicacion'] ?? 'Sin ubicación',
                                  disponibilidadtransporte: data['transporte'] ?? false,
                                  calificacionPromedio: (data['calificacionPromedio'] as num?)?.toDouble() ?? 0.0,
                                  calificaciones: const [], 
                                  politicaCancelacion: data['politicaCancelacion'] ?? '',
                                  nombreAnfitrion: data['nombreAnfitrion'] ?? '',
                                  imagenUrl: data['imagenUrl'],
                                );

                                return SizedBox(
                                  width: (992 - 32) / 3, 
                                  child: GestureDetector(
                                    onTap: () {Navigator.push( context,
                                      MaterialPageRoute(builder: (context) => PantallaReserva(
                                        publicacion: publicacion, viajero: viajero,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildDestinationCard(
                                      publicacion.titulo, 
                                      publicacion.ubicacion, 
                                      '\$${publicacion.precio}', 
                                      publicacion.imagenUrl ?? 'assets/images/los_roques.jpg',
                                      publicacion.calificacionPromedio.toStringAsFixed(1),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]
      )
    );
  }

  // Helper para construir las tarjetas de los destinos
  Widget _buildDestinationCard(String title, String location, String price, String imagePath, String rating) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath, height: 200, width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(height: 200, color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          );
                        },
                      )
                    : Image.asset(
                        imagePath, height: 200, width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(height: 200, color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          );
                        },
                      ),
              ),
              Positioned(top: 12, right: 12,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC2DC77),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rating, 
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontFamily: 'Idiqlat', color: Colors.black, 
                  fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(location, style: const TextStyle(color: Color(0xFF6E867A), fontSize: 14),
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    price,
                    style: const TextStyle(color: Color(0xFF216A44), fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Clase espejo actualizada para recibir la publicación completa sin errores de compilación
class PantallaDetallePublicacion extends StatelessWidget {
  final Publicacion publicacion;
  final Viajero viajero;

  const PantallaDetallePublicacion({super.key, required this.publicacion, required this.viajero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(publicacion.titulo)),
      body: Center(child: Text("Cargando detalles de: ${publicacion.descripcion}")),
    );
  }
}