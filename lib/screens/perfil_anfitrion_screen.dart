import 'package:flutter/material.dart';

class PerfilAnfitrionScreen extends StatefulWidget {
  const PerfilAnfitrionScreen({Key? key}) : super(key: key);

  @override
  State<PerfilAnfitrionScreen> createState() => _PerfilAnfitrionScreenState();
}

class _PerfilAnfitrionScreenState extends State<PerfilAnfitrionScreen> {
  // Controladores para que los campos de texto sean editables y se conecten con la gestión
  late TextEditingController nombreController;
  late TextEditingController correoController;
  late TextEditingController telefonoController;
  late TextEditingController rifController;
  late TextEditingController direccionController;
  late TextEditingController paypalController;

  @override
  void initState() {
    super.initState();
    // Inicializamos con los datos por defecto que venían en el Figma
    nombreController = TextEditingController(text: 'Miguel Angle');
    correoController = TextEditingController(text: 'miguelangle@correo.com');
    telefonoController = TextEditingController(text: '+58 414 555 7788');
    rifController = TextEditingController(text: 'J-12345678-9');
    direccionController = TextEditingController(
      text: 'Calle Real, Mérida, Venezuela',
    );
    paypalController = TextEditingController(text: 'miguel.angle@paypal.com');
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    rifController.dispose();
    direccionController.dispose();
    paypalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1440,
          height: 1024,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Color(0xFFF5F7F2)),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 1440,
                  height: 1024,
                  decoration: const BoxDecoration(color: Color(0xFFF5F7F2)),
                ),
              ),
              Positioned(
                left: 30,
                top: 290,
                child: Container(
                  width: 421,
                  height: 311,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 421,
                          height: 311,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 132,
                        top: 24,
                        child: Container(
                          width: 156.56,
                          height: 156.56,
                          decoration: const ShapeDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 144.26,
                        child: SizedBox(
                          width: 354,
                          height: 48.09,
                          child: Text(
                            nombreController.text, // Conectado al controlador
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontFamily: 'Idiqlat',
                              fontWeight: FontWeight.w400,
                              height: 1.40,
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 156.56,
                        top: 189.36,
                        child: Text(
                          'Anfitrión',
                          style: TextStyle(
                            color: Color(0xFF526F75),
                            fontSize: 24,
                            fontFamily: 'Jacques Francois',
                            fontWeight: FontWeight.w400,
                            height: 1.40,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18.97,
                        top: 240.40,
                        child: Container(
                          width: 383.06,
                          height: 46.32,
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
                        left: 120.29,
                        top: 249.18,
                        child: GestureDetector(
                          onTap: () {
                            // Aquí conectarás la función para cambiar foto del otro archivo
                          },
                          child: const SizedBox(
                            width: 179.47,
                            height: 28.75,
                            child: Text(
                              'Cambiar Foto', // Error tipográfico 'Carmbiar' corregido
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
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 676,
                top: 290,
                child: Container(
                  width: 721,
                  height: 559,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 721,
                          height: 559,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 37,
                        top: 26,
                        child: Text(
                          'Responsable',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 65,
                        top: 102,
                        child: Text(
                          'Correo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 57,
                        top: 178,
                        child: Text(
                          'Teléfono',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 85,
                        top: 250,
                        child: Text(
                          'Rif',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 34,
                        top: 406,
                        child: Text(
                          'Cuenta PayPal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 23,
                        top: 330,
                        child: Text(
                          'Dirección Fiscal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF216A44),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),

                      // --- CAMPOS EDITABLES (Fusión de Textos a controladores) ---
                      Positioned(
                        left: 360,
                        top: 26,
                        child: _buildEditableField(nombreController),
                      ),
                      Positioned(
                        left: 301,
                        top: 102,
                        child: _buildEditableField(correoController),
                      ),
                      Positioned(
                        left: 334,
                        top: 178,
                        child: _buildEditableField(telefonoController),
                      ),
                      Positioned(
                        left: 353,
                        top: 254,
                        child: _buildEditableField(rifController),
                      ),
                      Positioned(
                        left: 282,
                        top: 330,
                        child: _buildEditableField(direccionController),
                      ),
                      Positioned(
                        left: 298,
                        top: 406,
                        child: _buildEditableField(paypalController),
                      ),

                      // Líneas divisorias de tu diseño
                      _buildDivider(78),
                      _buildDivider(154),
                      _buildDivider(230),
                      _buildDivider(306),
                      _buildDivider(382),
                      _buildDivider(458),

                      // Botón Guardar Cambios
                      Positioned(
                        left: 8,
                        top: 486,
                        child: GestureDetector(
                          onTap: () {
                            // Aquí se conecta con la función del otro archivo para salvar datos
                            print(
                              "Guardando datos de ${nombreController.text}",
                            );
                          },
                          child: Container(
                            width: 191,
                            height: 46,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF216A44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Center(
                              child: Text(
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
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 309,
                top: 682,
                child: GestureDetector(
                  onTap: () {
                    // Acción Cerrar Sesión
                  },
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
              Positioned(
                left: 1093,
                top: 137,
                child: Container(
                  width: 170,
                  height: 87,
                  child: Stack(
                    children: [
                      const Positioned(
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
                              fontWeight: FontWeight.w800,
                              height: 1.40,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12.31,
                        top: 31,
                        child: Container(
                          width: 21.54,
                          height: 26,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF216A44),
                          ), // Agregado ícono en el contenedor vacío
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper para mantener los textos limpios y editables con estilo Figma
  Widget _buildEditableField(TextEditingController controller) {
    return SizedBox(
      width: 350,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // Helper para las líneas divisorias repetitivas
  Positioned _buildDivider(double topPosition) {
    return Positioned(
      left: 0,
      top: topPosition,
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
    );
  }
}
