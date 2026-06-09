import 'package:flutter/material.dart';
import 'perfil_anfitrion_screen.dart'; // Importación para poder navegar al perfil

class HomeAnfitrion extends StatefulWidget {
  const HomeAnfitrion({super.key});

  @override
  State<HomeAnfitrion> createState() => _HomeAnfitrionState();
}

class _HomeAnfitrionState extends State<HomeAnfitrion> {
  @override
  Widget build(BuildContext context) {
    // 1. Scaffold: Provee la base de Material Design para evitar recuadros rojos
    return Scaffold(
      // 2. SingleChildScrollView doble: Evita las franjas amarillas/negras si la pantalla es pequeña
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: 1440,
            height: 1024,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFFF5F7F2)),
            child: Stack(
              children: [
                // ==========================================
                // BARRA SUPERIOR
                // ==========================================
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 1440,
                    height: 116,
                    decoration: const BoxDecoration(color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 174,
                  top: 36,
                  child: Container(
                    width: 443,
                    height: 44,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF5F7F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 233,
                  top: 48,
                  child: const SizedBox(
                    width: 354,
                    height: 22,
                    child: Text(
                      'Buscar reservas, fechas...',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                // ÍCONO DE PERFIL (ARRIBA A LA DERECHA) - CLICKEABLE
                Positioned(
                  left: 1216,
                  top: 34,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PerfilAnfitrionScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 48,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF216A44),
                        shape: OvalBorder(),
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  left: 1017,
                  top: 47,
                  child: const SizedBox(
                    width: 178,
                    height: 22,
                    child: Text(
                      'Miguel Ángel',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // ==========================================
                // MENÚ DE NAVEGACIÓN
                // ==========================================
                Positioned(
                  left: 397,
                  top: 140,
                  child: SizedBox(
                    width: 250,
                    height: 80,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.dashboard,
                          color: Color(0xFF216A44),
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Panel',
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 36,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 704,
                  top: 140,
                  child: SizedBox(
                    width: 280,
                    height: 80,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.home_work,
                          color: Color(0xFF216A44),
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Propiedades',
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 36,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTÓN "PERFIL" DEL MENÚ - CLICKEABLE HACIA EL PERFIL DEL ANFITRIÓN
                Positioned(
                  left: 1022,
                  top: 140,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PerfilAnfitrionScreen(),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 246,
                      height: 80,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.account_circle,
                            color: Color(0xFF216A44),
                            size: 32,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Perfil',
                            style: TextStyle(
                              color: Color(0xFF216A44),
                              fontSize: 36,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==========================================
                // CONTENIDO CENTRAL (DASHBOARD DEL ANFITRIÓN)
                // ==========================================
                Positioned(
                  left: 174,
                  top: 250,
                  child: const Text(
                    'Panel de Administración',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  left: 174,
                  top: 320,
                  child: Container(
                    width: 1092,
                    height: 250,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF216A44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Tienes 3 nuevas solicitudes de reserva hoy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // ==========================================
                // SECCIÓN INFERIOR
                // ==========================================
                Positioned(
                  left: 174,
                  top: 610,
                  child: Container(
                    width: 1092,
                    height: 300,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Resumen de actividad',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '• Ingresos del mes: \$1,250',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '• Calificación promedio: 4.8 ⭐',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '• Mensajes sin leer: 2',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.analytics,
                          size: 120,
                          color: Color(0xFF216A44),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
