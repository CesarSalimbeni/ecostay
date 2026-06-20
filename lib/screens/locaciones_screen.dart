import 'package:flutter/material.dart';
import '../controllers/locaciones_controller.dart'; // Asegúrate de que la ruta sea correcta

class LocacionesScreen extends StatelessWidget {
  final LocacionesController _controller = LocacionesController();

  LocacionesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: ListView(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: Container(
              width: 1586,
              height: 895,
              child: Stack(
                children: [
                  // --- FONDO PRINCIPAL ---
                  Positioned(
                    left: 0,
                    top: 3,
                    child: Container(
                      width: 1586,
                      height: 892,
                      decoration: const BoxDecoration(color: Color(0xFFF5F7F2)),
                    ),
                  ),

                  // --- BARRA BLANCA SUPERIOR ---
                  Positioned(
                    left: 0,
                    top: 3,
                    child: Container(
                      width: 1586,
                      height: 137,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE5E5E5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --- LOGO ---
                  Positioned(
                    left: 60,
                    top: 20,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        'assets/png/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // --- PERFIL ADMIN ---
                  Positioned(
                    left: 1400,
                    top: 25,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF216A44),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 1250,
                    top: 40,
                    child: Text(
                      'Admin1',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                  const Positioned(
                    left: 1250,
                    top: 65,
                    child: Text(
                      'Administrador',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
                    ),
                  ),

                  // --- BARRA DE BÚSQUEDA ---
                  Positioned(
                    left: 320,
                    top: 38,
                    child: Container(
                      width: 850,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7F2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.search,
                            color: Color(0xFF526F75),
                            size: 30,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Buscar...',
                            style: TextStyle(
                              color: Color(0xFF526F75),
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==========================================
                  // MENÚ DE NAVEGACIÓN
                  // ==========================================
                  Positioned(
                    left: 180,
                    top: 160,
                    child: InkWell(
                      onTap: () => _controller.irADashboard(context),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/png/icondash.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              color: Color(0xFF216A44),
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 480,
                    top: 160,
                    child: InkWell(
                      onTap: () => _controller.irAUsuarios(context),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/png/iconusu.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Usuarios',
                            style: TextStyle(
                              color: Color(0xFF216A44),
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 750,
                    top: 160,
                    child: InkWell(
                      onTap: () => _controller.irAModeracion(context),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/png/iconmode.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Moderación',
                            style: TextStyle(
                              color: Color(0xFF216A44),
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 1080,
                    top: 160,
                    child: Row(
                      children: [
                        // Aquí "Locaciones" es la pestaña activa (negrita)
                        Image.asset(
                          'assets/png/iconloca.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Locaciones',
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- TÍTULO SECCIÓN ---
                  const Positioned(
                    left: 230,
                    top: 250,
                    child: Text(
                      'Locaciones',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // ==========================================
                  // TABLA DE LOCACIONES
                  // ==========================================
                  Positioned(
                    left: 230,
                    top: 320,
                    child: Container(
                      width: 1080,
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
                                  padding: EdgeInsets.only(left: 60),
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
                                  padding: EdgeInsets.only(right: 70),
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

                          // Filas de datos usando nuestro método helper
                          _buildFilaLocacion('Merida'),
                          _buildFilaLocacion('Miranda'),
                          _buildFilaLocacion('Trujillo'),
                          _buildFilaLocacion('Maracaybo'),
                          _buildFilaLocacion('Falcon'),

                          // Fila final con el botón de agregar
                          Container(
                            height: 60,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 50),
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
                  ),
                ],
              ),
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
            padding: const EdgeInsets.only(left: 60),
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
            padding: const EdgeInsets.only(right: 50),
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
