import 'package:ecostay/pantallas/iniciar_sesion.dart';
import 'package:ecostay/pantallas/registro.dart';
import 'package:flutter/material.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;
    final isWide = screenWidth >= 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 24 : 60,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isCompact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: const AssetImage('assets/images/logo.jpg'),
                                    radius: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  const Flexible(
                                    child: Text(
                                      'Ecostay',
                                      style: TextStyle(
                                        fontFamily: 'Idiqlat',
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 24,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PantallaIniSesion(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontFamily: 'Idiqlat',
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PantallaRegistro(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC1DB70),
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      child: const Text(
                                        'Registrarse',
                                        style: TextStyle(
                                          fontFamily: 'Idiqlat',
                                          color: Color(0xFF19573A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: const AssetImage('assets/images/logo.jpg'),
                                      radius: 40,
                                    ),
                                    const SizedBox(width: 10),
                                    const Flexible(
                                      child: Text(
                                        'Ecostay',
                                        style: TextStyle(
                                          fontFamily: 'Idiqlat',
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 30,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PantallaIniSesion(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontFamily: 'Idiqlat',
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PantallaRegistro(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC1DB70),
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      child: const Text(
                                        'Registrarse',
                                        style: TextStyle(
                                          fontFamily: 'Idiqlat',
                                          color: Color(0xFF19573A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    SizedBox(height: isCompact ? 24 : 40),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC1DB70),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: const Text(
                        'Turismo Sostenible',
                        style: TextStyle(
                          fontFamily: 'Idiqlat',
                          color: Color(0xFF19573A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isWide ? 700 : 500),
                      child: Text(
                        'Descubre Venezuela \nlow cost, \nsin intermediarios.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Idiqlat',
                          color: const Color(0xFFFFFFFF),
                          fontSize: isCompact ? 34 : isWide ? 56 : 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: const Text(
                        'Posadas, campings y rutas auténticas a precios reales. Reserva directo con prestadores locales y viaja con tranquilidad.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}