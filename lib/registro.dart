import 'package:flutter/material.dart';
import 'dart:math';

class PantallaRegistro extends StatelessWidget {
  const PantallaRegistro({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleFontSize = min(size.width * 0.12, size.height * 0.14).clamp(32.0, 128.0) as double;
    final buttonFontSize = min(size.width * 0.07, size.height * 0.08).clamp(18.0, 48.0) as double;
    final imageWidth = min(size.width * 0.5, 300.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo.jpg'),
            fit: BoxFit.cover,
          ),),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 5),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundImage: AssetImage('assets/images/logo.jpg'), radius: 40,),
                      SizedBox(width: 10,),
                      Text('Ecostay', style: TextStyle(fontFamily: 'Idiqlat', color: Color(0xFFFFFFFF), 
                      fontSize: 30),)
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(onPressed: () {}, child: Text('Iniciar Sesión', 
                        style: TextStyle(fontFamily: 'Idiqlat', color: Color(0xFFFFFFFF)),)),
                      TextButton(onPressed: () {},
                       child: Container(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                        decoration: BoxDecoration(
                        color: const Color(0xFFC1DB70),
                        borderRadius: BorderRadius.circular(30.0),),
                        child: Text('Registrarse', style: TextStyle(fontFamily: 'Idiqlat',
                        color: Color(0xFF19573A)),),
                    ))
                    ],
                  )
                ],
              ),
              SizedBox(height: 40,),
              Container(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                decoration: BoxDecoration(
                color: const Color(0xFFC1DB70),
                borderRadius: BorderRadius.circular(30.0),),
                child: Text('Turismo Sostenible', style: TextStyle(fontFamily: 'Idiqlat',
                color: Color(0xFF19573A)),),
              ),
              Text('Descubre Venezuela \nlow cost, \nsin intermediarios.', textAlign: TextAlign.left,
              style: TextStyle(fontFamily: 'Idiqlat', color: Color(0xFFFFFFFF), fontSize: 50),),
              Text('Posadas, campings y rutas auténticas a precios reales. Reserva directo \ncon prestadores locales y viaja con tranquilidad.', 
              textAlign: TextAlign.left, style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 15),)
            ],
          ),
        ),
      ),
    );
  }
}