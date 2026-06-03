import 'package:flutter/material.dart';

class PantallaIniSesion extends StatelessWidget {
  const PantallaIniSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 20,),
                      CircleAvatar(backgroundImage: AssetImage('assets/images/logo.jpg'), radius: 40,),
                      SizedBox(width: 10,),
                      Text('Ecostay', style: TextStyle(fontFamily: 'Idiqlat', color: Color(0xFF216A44), 
                      fontSize: 30),)
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 60.0, right: 40.0),
                      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20,),
                          Text("Bienvenido de Vuelta", style: TextStyle(color: Colors.black, fontSize: 20),),
                          Text("Inicia sesión para continuar tu gran viaje."),
                          SizedBox(height: 40,),
                          Text("Correo electrónico"),
                          TextField(decoration: InputDecoration(labelText: "tu@correo.com", border: OutlineInputBorder()),),
                          SizedBox(height: 30,),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("Contraseña"),
                            TextButton(onPressed: () {}, child: Text("¿Olvidaste tu contraseña?", 
                            style: TextStyle(color: Color(0xFF216A44), fontFamily: 'Idiqlat'),),)
                          ],),
                          TextField(decoration: InputDecoration(labelText: "contraseña", border: OutlineInputBorder()),),
                          SizedBox(height: 50,),
                          FilledButton(onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF216A44),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),),
                              minimumSize: const Size(double.infinity, 50),),
                            child: const Text("Iniciar Sesión",
                              style: TextStyle(fontSize: 16, fontFamily: 'Idiqlat'),),),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text("¿No tienes cuenta?", style: TextStyle(fontFamily: 'Idiqlat'),),
                            TextButton(onPressed: () {}, child: Text("Registrate aquí", 
                            style: TextStyle(color: Color(0xFF216A44), fontFamily: 'Idiqlat'),))
                          ],)
                        ],
                      )
                  )
                ],
              ),
            )),
          
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
              image: DecorationImage(
              image: AssetImage('assets/images/fondo.jpg'),
              fit: BoxFit.cover,
          ),))
          )
        ],
      ),
    );
  }
}