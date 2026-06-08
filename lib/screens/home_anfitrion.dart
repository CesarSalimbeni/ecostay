import 'package:flutter/material.dart';
import 'perfil_anfitrion_screen.dart';

class HomeAnfitrionScreen extends StatelessWidget {
  const HomeAnfitrionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: ListView(
        children: [
          Column(
            children: [
              Container(
                width: 1612,
                height: 895,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 1612,
                        height: 895,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 1586,
                                height: 892,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        width: 1586,
                                        height: 892,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF5F7F2),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        width: 1586,
                                        height: 137,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 1452,
                                      top: 19,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: const ShapeDecoration(
                                          color: Color(0xFF216A44),
                                          shape: OvalBorder(),
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      left: 1286,
                                      top: 40,
                                      child: SizedBox(
                                        width: 166,
                                        height: 29,
                                        child: Text(
                                          'Miguel Angle',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      left: 1289,
                                      top: 69,
                                      child: Text(
                                        'Anfitrión',
                                        style: TextStyle(
                                          color: Color(0xFF8E8E93),
                                          fontSize: 20,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.40,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 322,
                                      top: 35,
                                      child: Container(
                                        width: 941,
                                        height: 79,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFF4F7F2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      left: 401,
                                      top: 55,
                                      child: Text(
                                        'Buscar...',
                                        style: TextStyle(
                                          color: Color(0xFF526F75),
                                          fontSize: 32,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.40,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: 137,
                                      child: Container(
                                        width: 1586,
                                        decoration: const ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              strokeAlign:
                                                  BorderSide.strokeAlignCenter,
                                              color: Color(0xFF8E8E93),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 92,
                                      top: 0,
                                      child: Container(
                                        width: 139,
                                        height: 137,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              "https://placehold.co/139x137",
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // --- DASHBOARD ---
                                    const Positioned(
                                      left: 171,
                                      top: 137,
                                      child: SizedBox(
                                        width: 278,
                                        height: 87,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: 72.33,
                                              top: 27,
                                              child: SizedBox(
                                                width: 192.11,
                                                height: 30,
                                                child: Text(
                                                  'Dashboard',
                                                  style: TextStyle(
                                                    color: Color(0xFFF5F7F2),
                                                    fontSize: 36,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // --- PUBLICACIONES ---
                                    const Positioned(
                                      left: 465,
                                      top: 137,
                                      child: SizedBox(
                                        width: 350,
                                        height: 87,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: 91.06,
                                              top: 27,
                                              child: SizedBox(
                                                width: 241.87,
                                                height: 30,
                                                child: Text(
                                                  'Publicaciones',
                                                  style: TextStyle(
                                                    color: Color(0xFF216A44),
                                                    fontSize: 36,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // --- BOTÓN DE PERFIL (¡AQUÍ ESTÁ LA LÓGICA!) ---
                                    Positioned(
                                      left: 1093,
                                      top: 137,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Esto nos lleva a la pantalla de edición
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PerfilAnfitrionScreen(),
                                            ),
                                          );
                                        },
                                        // Le puse un color transparente de fondo para que el área táctil sea más grande y fácil de presionar
                                        child: Container(
                                          width: 170,
                                          height: 87,
                                          color: Colors.transparent,
                                          child: const Stack(
                                            children: [
                                              Positioned(
                                                left: 44.23,
                                                top: 27,
                                                child: SizedBox(
                                                  width: 117.48,
                                                  height: 30,
                                                  child: Text(
                                                    'Perfil',
                                                    style: TextStyle(
                                                      color: Color(0xFF216A44),
                                                      fontSize: 36,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // --- RESERVAS ---
                                    const Positioned(
                                      left: 831,
                                      top: 137,
                                      child: SizedBox(
                                        width: 246,
                                        height: 87,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: 64,
                                              top: 27,
                                              child: SizedBox(
                                                width: 170,
                                                height: 30,
                                                child: Text(
                                                  'Reservas',
                                                  style: TextStyle(
                                                    color: Color(0xFF216A44),
                                                    fontSize: 36,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.40,
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
                      ),
                    ),
                    const Positioned(
                      left: 254,
                      top: 166,
                      child: SizedBox(
                        width: 241.87,
                        height: 30,
                        child: Text(
                          'Dashboard',
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 36,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
