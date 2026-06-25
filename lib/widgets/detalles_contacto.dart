import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/pantallas/estilo.dart';

class InfoContactoPrestadorDialog extends StatelessWidget {
  final String publicacionId;
  final String nombreAnfitrion;

  const InfoContactoPrestadorDialog({
    super.key,
    required this.publicacionId,
    required this.nombreAnfitrion,
  });

  Future<Map<String, String>> _obtenerContactoPrestador() async {
    try {
      final GestionPublicacion gestionPublicacion = GestionPublicacion();
      
      String? providerId = await gestionPublicacion.obtenerProveedor(publicacionId);

      if (providerId == null || providerId.isEmpty) {
        throw Exception('No se encontró el ID del proveedor.');
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') 
          .doc(providerId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> datosUsuario = userDoc.data() as Map<String, dynamic>;
        
        return {
          'telefono': datosUsuario['telefono'] ?? 'No especificado',
          'correo': datosUsuario['correo'] ?? datosUsuario['email'] ?? 'No especificado',
        };
      }

      return {
        'telefono': 'No disponible',
        'correo': 'No disponible',
      };
    } catch (e) {
      throw Exception('Error al cargar datos de contacto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: ColorPalette.bg,
      title: Text(
        'Contacto de $nombreAnfitrion',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          fontFamily: 'Idiqlat',
          color: Color(0xFF216A44),
        ),
      ),
      content: SizedBox(
        width: 400,
        child: FutureBuilder<Map<String, String>>(
          future: _obtenerContactoPrestador(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF216A44))),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final datos = snapshot.data!;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFF216A44), size: 28),
                  title: const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(datos['telefono']!, style: const TextStyle(fontSize: 18)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFF216A44), size: 28),
                  title: const Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(datos['correo']!, style: const TextStyle(fontSize: 18)),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar', style: TextStyle(color: Color(0xFF216A44), fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}