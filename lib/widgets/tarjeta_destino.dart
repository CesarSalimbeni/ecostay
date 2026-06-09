import 'package:flutter/material.dart';
import '../models/destino.dart';

class TarjetaDestino extends StatelessWidget {
  final Destino destino;

  const TarjetaDestino({Key? key, required this.destino}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 400,
      ), // Evita que sea gigante en web
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- MITAD SUPERIOR: IMAGEN Y CALIFICACIÓN ---
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                child: Image.network(
                  destino.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Si la imagen de internet falla, mostramos un fondo gris elegante
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
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
                    color: const Color(0xFFBEDA78),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    destino.calificacion.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- MITAD INFERIOR: TEXTOS Y PRECIO ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        destino.nombre,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Libertinus Serif',
                        ),
                      ),
                    ),
                    const Text(
                      'Explorar',
                      style: TextStyle(
                        color: Color(0xFF216A44),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  destino.ubicacion,
                  style: const TextStyle(
                    color: Color(0xFF595959),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF979797), thickness: 1),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '\$${destino.precio.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF19573A),
                      fontSize: 32,
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
