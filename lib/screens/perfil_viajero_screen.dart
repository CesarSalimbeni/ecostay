import 'package:flutter/material.dart';

class PerfilViajeroScreen extends StatefulWidget {
  const PerfilViajeroScreen({super.key});

  @override
  State<PerfilViajeroScreen> createState() => _PerfilViajeroScreenState();
}

class _PerfilViajeroScreenState extends State<PerfilViajeroScreen> {
  final TextEditingController _nombreController = TextEditingController(
    text: 'María Gonzáles',
  );
  final TextEditingController _correoController = TextEditingController(
    text: 'marianagz@gmail.com',
  );
  final TextEditingController _telefonoController = TextEditingController(
    text: '+51 987 654 321',
  );
  final TextEditingController _contrasenaController = TextEditingController(
    text: '********',
  );

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration() {
    return const InputDecoration(
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  TextStyle _buildInputFieldStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // BARRA SUPERIOR
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
                      'Buscar por hotel, aeropuerto...',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 1216,
                  top: 34,
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
                // LÍNEA 120 CORREGIDA AQUÍ (Se cambió Alignment.centerRight por TextAlign.right)
                Positioned(
                  left: 1017,
                  top: 47,
                  child: const SizedBox(
                    width: 178,
                    height: 22,
                    child: Text(
                      'María Gonzáles',
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

                // MENÚ DE NAVEGACIÓN PRINCIPAL
                Positioned(
                  left: 397,
                  top: 140,
                  child: SizedBox(
                    width: 218,
                    height: 80,
                    child: Row(
                      children: const [
                        Icon(Icons.explore, color: Color(0xFF216A44), size: 32),
                        SizedBox(width: 12),
                        Text(
                          'Explorar',
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
                Positioned(
                  left: 704,
                  top: 140,
                  child: SizedBox(
                    width: 229,
                    height: 80,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.book_online,
                          color: Color(0xFF216A44),
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Reservas',
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
                Positioned(
                  left: 1022,
                  top: 140,
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // TARJETA DE PERFIL (IZQUIERDA)
                Positioned(
                  left: 174,
                  top: 232,
                  child: SizedBox(
                    width: 477,
                    height: 604,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 83.76,
                          child: SizedBox(
                            width: 477,
                            height: 520.24,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: 477,
                                    height: 420.66,
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 161.73,
                                  top: 25.10,
                                  child: Container(
                                    width: 152.51,
                                    height: 131.22,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFF216A44),
                                      shape: OvalBorder(),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 58,
                                  top: 156.35,
                                  child: const SizedBox(
                                    width: 354,
                                    height: 52.12,
                                    child: Text(
                                      'María Gonzáles',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 40,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180.39,
                                  top: 206.49,
                                  child: const Text(
                                    'Viajero',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF526F75),
                                      fontSize: 24,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 21.50,
                                  top: 260.55,
                                  child: Container(
                                    width: 434.01,
                                    height: 50.21,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF5F7F2),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFB3B3B3),
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 136.29,
                                  top: 270.08,
                                  child: const SizedBox(
                                    width: 203.35,
                                    height: 31.16,
                                    child: Text(
                                      'Cambiar Foto',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.50,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: -2,
                          child: const Text(
                            'Mi Perfil',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 321,
                  top: 638,
                  child: InkWell(
                    onTap: () {},
                    child: const SizedBox(
                      width: 184,
                      height: 44,
                      child: Text(
                        'Cerrar Sesión',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                ),

                // FORMULARIO DE EDICIÓN (DERECHA)
                Positioned(
                  left: 545,
                  top: 316,
                  child: Container(
                    width: 721,
                    height: 452,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 15,
                          top: 24.33,
                          child: const Text(
                            'Nombre completo',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 45.10,
                          child: SizedBox(
                            width: 690,
                            child: TextField(
                              controller: _nombreController,
                              style: _buildInputFieldStyle(),
                              decoration: _buildInputDecoration(),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 104,
                          child: const Text(
                            'Correo electrónico',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 125,
                          child: SizedBox(
                            width: 690,
                            child: TextField(
                              controller: _correoController,
                              style: _buildInputFieldStyle(),
                              decoration: _buildInputDecoration(),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 177,
                          child: const Text(
                            'Teléfono móvil',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 198,
                          child: SizedBox(
                            width: 690,
                            child: TextField(
                              controller: _telefonoController,
                              style: _buildInputFieldStyle(),
                              decoration: _buildInputDecoration(),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 254.15,
                          child: const Text(
                            'Contraseña',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 274.91,
                          child: SizedBox(
                            width: 690,
                            child: TextField(
                              controller: _contrasenaController,
                              style: _buildInputFieldStyle(),
                              decoration: _buildInputDecoration(),
                              obscureText: true,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 228.99,
                          child: Container(
                            width: 721,
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 304.65,
                          child: Container(
                            width: 721,
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 380.32,
                          child: InkWell(
                            onTap: () {
                              final nuevoNombre = _nombreController.text;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Guardando cambios para $nuevoNombre...',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 191,
                              height: 45.80,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF216A44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Guardar Cambios',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                ),
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
      ),
    );
  }
}
