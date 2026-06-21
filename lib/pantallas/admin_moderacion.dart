import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart';
import 'package:ecostay/pantallas/estilo.dart';
import '../controllers/moderacion_controller.dart';

class AdminModeracion extends StatelessWidget {
  final Administrador administrador;
  final ModeracionController _controller = ModeracionController();

  AdminModeracion({super.key, required this.administrador});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        toolbarHeight: 90,
        leadingWidth: 120,
        centerTitle: true,
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
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              administrador.nombre,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF216A44),
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MENÚ DE NAVEGACIÓN SUPERIOR
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeAdmin(administrador: administrador)),
                    );
                  },
                  icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                  label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: administrador)),
                    );
                  },
                  icon: const Icon(Icons.person_add_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Usuarios', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text(
                    'Moderación',
                    style: TextStyle(
                      color: Color(0xFF216A44),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SECCIÓN DE REPORTES
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
              children: [
                const Text(
                  'Reportes',
                  style: TextStyle(
                    color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'Idiqlat'
                  ),
                ),
                const SizedBox(height: 25),

                // Reporte 1: Pedro R.
                _buildCardReporte(
                  context: context,
                  usuario: 'Pedro R.',
                  destino: 'Posada Los Frailes',
                  tiempo: 'Hace 2h',
                  cantidadReportes: 1,
                  comentario: 'Excelente servicio, volvería allí.',
                ),
                
                const SizedBox(height: 25),

                // Reporte 2: Luis P.
                _buildCardReporte(
                  context: context,
                  usuario: 'Luis P.',
                  destino: 'Posada Los Frailes',
                  tiempo: 'Hace 15h',
                  cantidadReportes: 3,
                  comentario: 'Estupida posada',
                ),
                
                const SizedBox(height: 25), // Espacio al final de la lista
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HELPER PARA CONSTRUIR TARJETAS DE REPORTE
  Widget _buildCardReporte({
    required BuildContext context,
    required String usuario,
    required String destino,
    required String tiempo,
    required int cantidadReportes,
    required String comentario,
  }) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(
                      children: [
                        TextSpan(text: '$usuario ', style: const TextStyle(color: Colors.black,
                            fontSize: 20, fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: 'en $destino', style: const TextStyle(color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(tiempo, style: const TextStyle(color: Colors.grey, fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB72E2E), borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Reportes: $cantidadReportes',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // Caja de Comentario Reportado
          Container(width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F2), borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              comentario,
              style: const TextStyle(color: Colors.black, fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Fila de Botones de Acción
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _controller.ignorarReporte(),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Ignorar', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF216A44),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 15),

              // Botón Eliminar
              ElevatedButton.icon(
                onPressed: () => _controller.eliminarReporte(),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Eliminar', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB72E2E),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 15),

              // Botón Ver Perfil
              OutlinedButton.icon(
                onPressed: () => _controller.verPerfil(context),
                icon: const Icon(Icons.info_outline, color: Colors.black),
                label: const Text('Ver Perfil', style: TextStyle(fontSize: 18, color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}