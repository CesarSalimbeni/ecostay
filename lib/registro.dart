import 'package:ecostay/estilo.dart';
import 'package:flutter/material.dart';

class PantallaRegistro extends StatelessWidget {
  const PantallaRegistro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      body: Center(
        child: Container( width: 775, height: 775,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(30)),
          child: Column(
            children: [ 
              SizedBox(height: 15,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Crea tu cuenta de Ecostay', style: TextStyle(fontFamily: 'Idiqlat', color: Colors.black, 
                  fontSize: 30),),
                SizedBox(width: 10,),
                CircleAvatar(backgroundImage: AssetImage('assets/images/logo.jpg'), radius: 40,)
              ],),
              SizedBox(height: 20,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0),), 
                      alignment: AlignmentDirectional.centerStart
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.air, color: Color(0xFF216A44), size: 40),
                        Text('Soy Viajero', style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat'),),
                        Text('Quiero descubrir destinos.', style: TextStyle(color: Color(0xFF8E8E93)),)
                      ],
                    ))),
                    SizedBox(width: 30,),
                    Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0),), 
                      alignment: AlignmentDirectional.centerStart
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.home_outlined, color: Color(0xFF216A44), size: 40),
                        Text('Soy Anfitrión', style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat'),),
                        Text('Ofrezco servicios turísticos', style: TextStyle(color: Color(0xFF8E8E93)),)
                      ],
                    ))),
                  ],
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Nombre"),
                      TextField(decoration: InputDecoration(labelText: "Nombre", border: OutlineInputBorder()),)
                    ],),
                  ),
                  SizedBox(width: 30,),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Teléfono"),
                      TextField(decoration: InputDecoration(labelText: "Teléfono", border: OutlineInputBorder()),)
                    ],),
                  )
                ],),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Correo electrónico"),
                  TextField(decoration: InputDecoration(labelText: "tu@correo.com", border: OutlineInputBorder()),)
                  ],)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Dirección Fiscal"),
                      TextField(decoration: InputDecoration(labelText: "Calle Real, Estado, País", border: OutlineInputBorder()),)
                    ],),
                  ),
                  SizedBox(width: 30,),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Contraseña"),
                      TextField(decoration: InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),)
                    ],),
                  )
                ],),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Rif"),
                      TextField(decoration: InputDecoration(labelText: "J-555555-5", border: OutlineInputBorder()),)
                    ],),
                  ),
                  SizedBox(width: 30,),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Cuenta PayPal"),
                      TextField(decoration: InputDecoration(labelText: "tu.cuenta@@paypal.com", border: OutlineInputBorder()),)
                    ],),
                  )
                ],),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: FilledButton(onPressed: () {},
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF216A44),
                  foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                  minimumSize: const Size(double.infinity, 50),),child: const Text("Crear Cuenta",
                    style: TextStyle(fontSize: 16, fontFamily: 'Idiqlat'),),),
              )
            ],
          ),
        ),
      ),
    );
  }
}