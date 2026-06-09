import 'package:flutter/material.dart';
import '../models/destino.dart'; // Importamos los datos de prueba
import '../widgets/tarjeta_destino.dart'; // Importamos tu diseño de Figma

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({Key? key}) : super(key: key);

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  // Esta variable guardará los destinos que coincidan con la búsqueda
  List<Destino> destinosFiltrados = [];

  @override
  void initState() {
    super.initState();
    // Al principio, mostramos todos los destinos de prueba
    destinosFiltrados = destinosDePrueba;
  }

  // Esta función se ejecuta cada vez que escribes algo en la barra
  void filtrarBusqueda(String texto) {
    setState(() {
      if (texto.isEmpty) {
        destinosFiltrados = destinosDePrueba;
      } else {
        destinosFiltrados = destinosDePrueba
            .where(
              (destino) =>
                  destino.nombre.toLowerCase().contains(texto.toLowerCase()) ||
                  destino.ubicacion.toLowerCase().contains(texto.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Encuentra tu destino',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // --- BARRA DE BÚSQUEDA ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: filtrarBusqueda, // Llama a la función al escribir
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o lugar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // --- LISTA DE TARJETAS ---
          Expanded(
            child: destinosFiltrados.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron destinos 😢',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: destinosFiltrados.length,
                    itemBuilder: (context, index) {
                      final destinoActual = destinosFiltrados[index];
                      // Aquí llamamos a tu tarjeta y le pasamos los datos
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        child: Center(
                          child: TarjetaDestino(destino: destinoActual),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
