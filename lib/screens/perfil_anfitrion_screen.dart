import 'package:flutter/material.dart';

class PerfilAnfitrionScreen extends StatefulWidget {
  const PerfilAnfitrionScreen({super.key});

  @override
  State<PerfilAnfitrionScreen> createState() => _PerfilAnfitrionScreenState();
}

class _PerfilAnfitrionScreenState extends State<PerfilAnfitrionScreen> {
  final TextEditingController _responsableController = TextEditingController(
    text: 'Miguel Ángel',
  );
  final TextEditingController _correoController = TextEditingController(
    text: 'miguel.anfitrion@gmail.com',
  );
  final TextEditingController _telefonoController = TextEditingController(
    text: '+51 987 654 321',
  );
  final TextEditingController _rifController = TextEditingController(
    text: 'V-12345678-9',
  );

  @override
  void dispose() {
    _responsableController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _rifController.dispose();
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
    // AQUÍ ESTÁ EL SCAFFOLD QUE EVITA EL ERROR ROJO
    return Scaffold(
      // AQUÍ ESTÁN LOS SCROLLS QUE EVITAN LAS LÍNEAS AMARILLAS
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

                // TARJETA DE PERFIL IZQUIERDA
                Positioned(
                  left: 174,
                  top: 150,
                  child: SizedBox(
                    width: 477,
                    height: 604,
                    child: Stack(
                      children: [
                        Container(
                          width: 477,
                          height: 420,
                          margin: const EdgeInsets.only(top: 84),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Container(
                                width: 120,
                                height: 120,
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
                              const SizedBox(height: 16),
                              const Text(
                                'Miguel Ángel',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Anfitrión',
                                style: TextStyle(
                                  color: Color(0xFF526F75),
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFB3B3B3),
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Text(
                                  'Cambiar Foto',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          top: 10,
                          child: Text(
                            'Mi Perfil',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        // BOTÓN PARA REGRESAR AL HOME
                        Positioned(
                          left: 0,
                          top: 550,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              ); // Esto te devuelve a la pantalla anterior
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Volver al Home',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF216A44),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // FORMULARIO DE EDICIÓN DERECHA
                Positioned(
                  left: 690,
                  top: 234,
                  child: Container(
                    width: 600,
                    height: 480,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Responsable',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 16,
                          ),
                        ),
                        TextField(
                          controller: _responsableController,
                          style: _buildInputFieldStyle(),
                          decoration: _buildInputDecoration(),
                        ),
                        const Divider(height: 30, color: Color(0xFF8E8E93)),

                        const Text(
                          'Correo',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 16,
                          ),
                        ),
                        TextField(
                          controller: _correoController,
                          style: _buildInputFieldStyle(),
                          decoration: _buildInputDecoration(),
                        ),
                        const Divider(height: 30, color: Color(0xFF8E8E93)),

                        const Text(
                          'Teléfono',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 16,
                          ),
                        ),
                        TextField(
                          controller: _telefonoController,
                          style: _buildInputFieldStyle(),
                          decoration: _buildInputDecoration(),
                        ),
                        const Divider(height: 30, color: Color(0xFF8E8E93)),

                        const Text(
                          'Rif',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 16,
                          ),
                        ),
                        TextField(
                          controller: _rifController,
                          style: _buildInputFieldStyle(),
                          decoration: _buildInputDecoration(),
                        ),
                        const Divider(height: 40, color: Color(0xFF8E8E93)),

                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cambios guardados con éxito'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF216A44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            'Guardar Cambios',
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
