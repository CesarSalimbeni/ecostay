import 'package:flutter/material.dart';
import '../models/destino.dart';
import '../widgets/tarjeta_destino.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({Key? key}) : super(key: key);

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  List<Destino> destinosFiltrados = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    destinosFiltrados = List.from(destinosDePrueba); // Copia inicial
  }

  // --- LÓGICA DE BÚSQUEDA ---
  void _filtrarPorTexto(String texto) {
    setState(() {
      if (texto.isEmpty) {
        destinosFiltrados = List.from(destinosDePrueba);
      } else {
        destinosFiltrados = destinosDePrueba.where((destino) {
          final nombreMatch = destino.nombre.toLowerCase().contains(
            texto.toLowerCase(),
          );
          final ubicacionMatch = destino.ubicacion.toLowerCase().contains(
            texto.toLowerCase(),
          );
          return nombreMatch || ubicacionMatch;
        }).toList();
      }
    });
  }

  // --- LÓGICA DE FILTROS ---
  void _ordenarDestinos(String criterio) {
    setState(() {
      switch (criterio) {
        case 'barato':
          destinosFiltrados.sort((a, b) => a.precio.compareTo(b.precio));
          break;
        case 'caro':
          destinosFiltrados.sort((a, b) => b.precio.compareTo(a.precio));
          break;
        case 'popular':
          destinosFiltrados.sort(
            (a, b) => b.calificacion.compareTo(a.calificacion),
          );
          break;
        case 'menos_popular':
          destinosFiltrados.sort(
            (a, b) => a.calificacion.compareTo(b.calificacion),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2), // Fondo de tu Figma
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. CABECERA SUPERIOR (Logo, Buscador, Perfil)
            // ==========================================
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: Row(
                children: [
                  // Logo Falso (Círculo)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF216A44),
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.eco, color: Color(0xFF216A44)),
                  ),
                  const SizedBox(width: 30),
                  // Barra de búsqueda superior
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7F2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  // Perfil de Usuario
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'María Gonzáles',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Viajero',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  const CircleAvatar(
                    backgroundColor: Color(0xFF216A44),
                    radius: 25,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFCFCFCF)),

            // ==========================================
            // 2. MENÚ DE NAVEGACIÓN SECUNDARIA
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavButton(Icons.search, 'Explorar', isActive: true),
                  const SizedBox(width: 40),
                  _buildNavButton(Icons.send, 'Reservas'),
                  const SizedBox(width: 40),
                  _buildNavButton(Icons.person_outline, 'Perfil'),
                ],
              ),
            ),

            // ==========================================
            // 3. BARRA DE FILTROS BLANCA
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    // Input: ¿A donde vas?
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filtrarPorTexto,
                          decoration: const InputDecoration(
                            hintText: '¿A donde vas?',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Botón: Presupuesto (Solo visual)
                    Expanded(
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Presupuesto',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Botón: Filtros (MENÚ DESPLEGABLE FUNCIONAL)
                    Expanded(
                      child: PopupMenuButton<String>(
                        onSelected: _ordenarDestinos,
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'barato',
                            child: Text('Más barato a más caro'),
                          ),
                          const PopupMenuItem(
                            value: 'caro',
                            child: Text('Más caro a más barato'),
                          ),
                          const PopupMenuItem(
                            value: 'popular',
                            child: Text('Mejor calificados'),
                          ),
                          const PopupMenuItem(
                            value: 'menos_popular',
                            child: Text('Peor calificados'),
                          ),
                        ],
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Filtros',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Botón: Buscar
                    Expanded(
                      child: InkWell(
                        onTap: () => _filtrarPorTexto(_searchController.text),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF216A44),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Buscar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ==========================================
            // 4. CUADRÍCULA DE TARJETAS HORIZONTALES
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: destinosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron destinos',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : Wrap(
                      spacing: 30, // Espacio horizontal entre tarjetas
                      runSpacing: 30, // Espacio vertical si bajan
                      alignment: WrapAlignment.center,
                      children: destinosFiltrados.map((destino) {
                        return TarjetaDestino(destino: destino);
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Pequeño widget para no repetir código en el menú de Explorar/Reservas
  Widget _buildNavButton(IconData icon, String label, {bool isActive = false}) {
    return Row(
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF216A44) : Colors.grey,
          size: 28,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF216A44) : Colors.grey,
            fontSize: 24,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
