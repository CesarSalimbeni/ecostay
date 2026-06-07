import 'package:ecostay/estilo.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaReserva extends StatelessWidget {
  const PantallaReserva({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg',fit: BoxFit.contain,),
        ),
        title: SearchBar(
          hintText: 'Buscar...', hintStyle: WidgetStateProperty.all(
          const TextStyle(color: Color(0xFF526F75)),),
          leading: const Icon(Icons.search, color: Color(0xFF526F75),), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: WidgetStatePropertyAll(0),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text('Usuario', overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 20),),
          ),
          const CircleAvatar()
        ],
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton.icon(onPressed: () {}, 
                icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25),),),
              TextButton.icon(onPressed: () {}, 
                icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25),),),
              TextButton.icon(onPressed: () {}, 
                icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25),),),
            ],),
          ),


          Center(child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Container(width: 1240, height: 500, decoration: BoxDecoration(color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(25)), child: 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Padding(padding: const EdgeInsets.only(left: 20), child: Container(width: 300, height: 250, 
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), 
                        image: DecorationImage(image: AssetImage('assets/images/fondo.jpg'),fit: BoxFit.cover,),),),),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Nombre de Posada', style: TextStyle(fontFamily: 'Idiqlat', 
                              fontSize: 40, fontWeight: FontWeight.w800),),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Padding(padding: const EdgeInsets.only(top: 10),
                                    child: Text('Lugar: ', style: TextStyle(fontSize: 30), 
                                    overflow: TextOverflow.ellipsis, maxLines: 1,),
                                  ),
                                  Padding(padding: const EdgeInsets.only(top: 10),
                                    child: Text('Fecha: ', style: TextStyle(fontSize: 30), 
                                    overflow: TextOverflow.ellipsis, maxLines: 1,),
                                  ),
                                ],),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Padding(padding: const EdgeInsets.only(top: 10),
                                      child: Text('Anfitrión: ', style: TextStyle(fontSize: 30), 
                                      overflow: TextOverflow.ellipsis, maxLines: 1,),
                                    ),
                                    Padding(padding: const EdgeInsets.only(top: 10),
                                      child: Text('Precio: ', style: TextStyle(fontSize: 30), 
                                      overflow: TextOverflow.ellipsis, maxLines: 1,),
                                    ),
                                  ],),
                                ),
                                FilledButton(onPressed: () {}, style: FilledButton.styleFrom(
                                backgroundColor: Color(0xFF216A44), foregroundColor: Color(0xFFFFFFFF)),
                                child: Text('Pagar', style: TextStyle(fontSize: 30),)),
                              ],)
                            ],),
                          ),
                        )
                    ],),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 60),
                    child: Text('Reseñas', style: TextStyle(fontSize: 30, fontFamily: 'Idiqlat', 
                    color: Colors.black, fontWeight: FontWeight.w800),),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 60),
                    child: Text(''),
                  )
                ],),
            ),),
          ),
          )
          ])
      )
    );
  }
}