import 'package:flutter/material.dart';
import '../models/destino.dart';

class TarjetaDestino extends StatelessWidget {
  final Destino destino;

  const TarjetaDestino({Key? key, required this.destino}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGEN Y CALIFICACIÓN ---
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  destino.imageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0E070),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    destino.calificacion.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // --- TEXTOS INFERIORES ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destino.nombre,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Libertinus Serif', // Usa tu fuente serif
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  destino.ubicacion,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 16,
                    fontFamily: 'Libertinus Serif',
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFCFCFCF), thickness: 1),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '\$${destino.precio.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF216A44), // El verde de tu Figma
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Libertinus Serif',
                    ),
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
