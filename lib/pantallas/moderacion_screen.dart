import 'package:flutter/material.dart';
import '../controllers/moderacion_controller.dart';

class ModeracionScreen extends StatelessWidget {
  final ModeracionController _controller = ModeracionController();

  ModeracionScreen({Key? key}) : super(key: key);

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

                  // ==========================================
                  // TU LOGO EXACTO
                  // ==========================================
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
                  // TUS ÍCONOS CON EL NUEVO NOMBRE 'iconusu.png'
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
                          // Cambiado aquí a 'iconusu.png' con BoxFit.contain
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 1080,
                    top: 160,
                    child: InkWell(
                      onTap: () => _controller.irALocaciones(context),
                      child: Row(
                        children: [
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- TÍTULO SECCIÓN ---
                  const Positioned(
                    left: 256,
                    top: 250,
                    child: Text(
                      'Reportes',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // --- REPORTE 1 (Pedro R.) ---
                  Positioned(
                    left: 256,
                    top: 310,
                    child: Container(
                      width: 1074,
                      height: 230,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            left: 30,
                            top: 20,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Pedro R. ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'en Posada Los Frailes',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 30,
                            top: 45,
                            child: Text(
                              'Hace 2h',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          Positioned(
                            right: 30,
                            top: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB72E2E),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                'Reportes: 1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 30,
                            top: 75,
                            child: Container(
                              width: 1014,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7F2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Text(
                                'Excelente servicio, volvería allí.',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 30,
                            top: 150,
                            child: GestureDetector(
                              onTap: () => _controller.ignorarReporte(),
                              child: Container(
                                width: 140,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF216A44),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.check, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Ignorar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 185,
                            top: 150,
                            child: GestureDetector(
                              onTap: () => _controller.eliminarReporte(),
                              child: Container(
                                width: 140,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB72E2E),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.close, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Eliminar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 340,
                            top: 150,
                            child: GestureDetector(
                              onTap: () => _controller.verPerfil(context),
                              child: Container(
                                width: 150,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Ver Perfil',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- REPORTE 2 (Luis P.) ---
                  Positioned(
                    left: 256,
                    top: 570,
                    child: Container(
                      width: 1074,
                      height: 230,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            left: 30,
                            top: 20,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Luis P. ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'en Posada Los Frailes',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 30,
                            top: 45,
                            child: Text(
                              'Hace 15h',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          Positioned(
                            right: 30,
                            top: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB72E2E),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                'Reportes: 3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 30,
                            top: 75,
                            child: Container(
                              width: 1014,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7F2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Text(
                                'Estupida posada',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 30,
                            top: 150,
                            child: GestureDetector(
                              onTap: () => _controller.ignorarReporte(),
                              child: Container(
                                width: 140,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF216A44),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.check, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Ignorar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 185,
                            top: 150,
                            child: GestureDetector(
                              onTap: () => _controller.eliminarReporte(),
                              child: Container(
                                width: 140,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB72E2E),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.close, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Eliminar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 340,
                            top: 150,
                            child: GestureDetector(
                              onTap: () => _controller.verPerfil(context),
                              child: Container(
                                width: 150,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Ver Perfil',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
}
