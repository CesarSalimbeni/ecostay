import 'package:flutter/material.dart';
import 'dart:math';

// Importaciones de tu modelo y pantallas
import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart';
import 'package:ecostay/pantallas/estilo.dart';
import '../controllers/locaciones_controller.dart'; // Asegúrate de que la ruta sea correcta

class AdminLocaciones extends StatelessWidget {
  final Administrador administrador;
  final LocacionesController _controller = LocacionesController();

  AdminLocaciones({super.key, required this.administrador});

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
          // ==========================================
          // MENÚ DE NAVEGACIÓN SUPERIOR
          // ==========================================
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
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AdminModeracion(administrador: administrador)),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Moderación', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
                TextButton.icon(
                  onPressed: null, // Deshabilitado porque ya estamos aquí
                  icon: const Icon(Icons.layers_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text(
                    'Locaciones', style: TextStyle(color: Color(0xFF216A44),
                      fontSize: 25, fontWeight: FontWeight.w900
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // CONTENIDO PRINCIPAL (TABLA Y TÍTULO)
          // ==========================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
              children: [
                const Text(
                  'Locaciones',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.bold, fontFamily: 'Idiqlat'
                  ),
                ),
                const SizedBox(height: 20),
                
                // Tabla de Locaciones
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE5E5E5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Cabecera de la tabla
                      Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF4F7F2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE5E5E5),
                              width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 40),
                          child: Text(
                            'Lugar',
                            style: TextStyle(
                              color: Color(0xFF526F75),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 50),
                          child: Text(
                            'Acciones',
                            style: TextStyle(
                              color: Color(0xFF526F75),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filas de datos usando el método helper
                  _buildFilaLocacion('Mérida'),
                  _buildFilaLocacion('Miranda'),
                  _buildFilaLocacion('Trujillo'),
                  _buildFilaLocacion('Maracaibo'),
                  _buildFilaLocacion('Falcón'),

                  // Fila final con el botón de agregar
                  Container(
                    height: 60,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 35),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed: () => _controller.agregarLocacion(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
}

  // ==========================================
  // FUNCIÓN AUXILIAR PARA CREAR LAS FILAS
  // ==========================================
  Widget _buildFilaLocacion(String lugar) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nombre del lugar
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              lugar,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Iconos de acciones
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_square,
                    color: Colors.black54,
                    size: 28,
                  ),
                  onPressed: () => _controller.editarLocacion(lugar),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: Color(0xFFB72E2E),
                    size: 28,
                  ),
                  onPressed: () => _controller.eliminarLocacion(lugar),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}