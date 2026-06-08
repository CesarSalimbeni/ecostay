import 'package:ecostay/models/Publicacion.dart'; // Ajusta la ruta exacta de tu modelo Publicacion
import 'package:ecostay/models/Calificacion.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaReserva extends StatelessWidget {
  final Publicacion publicacion; // <-- Recibe el objeto tipo Publicacion

  const PantallaReserva({super.key, required this.publicacion});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        toolbarHeight: 90, 
        leadingWidth: 120, 
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain,),
        ),
        title: SearchBar(
          hintText: 'Buscar...', 
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Text('Usuario', overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 20)),
          ),
          CircleAvatar()
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // MENÚ SUPERIOR
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  TextButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                    label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                    label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                    label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                ],
              ),
            ),

            // TARJETA DE DETALLE PRINCIPAL
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  width: 1240, 
                  height: 500, 
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(25),
                  ), 
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start, 
                            children: [
                              // IMAGEN DE LA POSADA
                              Padding(
                                padding: const EdgeInsets.only(left: 20), 
                                child: Container(
                                  width: 300, 
                                  height: 250, 
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20), 
                                    image: const DecorationImage(
                                      image: AssetImage('assets/images/fondo.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // INFORMACIÓN DE LA PUBLICACIÓN
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text(
                                        publicacion.titulo,
                                        style: const TextStyle(fontFamily: 'Idiqlat', fontSize: 40, 
                                        fontWeight: FontWeight.w800),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start, 
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Text('Lugar: ${publicacion.ubicacion}', style: const TextStyle(
                                                  fontSize: 30), overflow: TextOverflow.ellipsis, maxLines: 1),
                                              ),
                                              Padding(padding: const EdgeInsets.only(top: 10),
                                                child: Row(mainAxisSize: MainAxisSize.min,
                                                children: [
                                                const Text('Rating: ', style: TextStyle(fontSize: 30)),
                                                const Icon(Icons.star, color: Colors.amber, size: 32),
                                                Text(' ${publicacion.calificacionPromedio.toStringAsFixed(1)}', 
                                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                                                ],),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start, 
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(top: 10),
                                                  child: Text('Anfitrión: ${publicacion.nombreAnfitrion}', style: TextStyle(fontSize: 30), 
                                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Text('Precio: \$${publicacion.precio.toStringAsFixed(0)}', 
                                                  style: const TextStyle(fontSize: 30), overflow: TextOverflow.ellipsis, 
                                                  maxLines: 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // BOTÓN PAGAR (Deshabilitado si disponibilidad es false)
                                          FilledButton(
                                            onPressed: publicacion.disponibilidad ? () {} : null, 
                                            style: FilledButton.styleFrom(
                                              backgroundColor: const Color(0xFF216A44), 
                                              foregroundColor: const Color(0xFFFFFFFF),
                                              disabledBackgroundColor: Colors.grey,
                                            ),
                                            child: const Text('Pagar', style: TextStyle(fontSize: 30)),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        
                        // SECCIÓN DE RESEÑAS CON EL CÍRCULO VERDE DEL DISEÑO
                        const Padding(
                          padding: EdgeInsets.only(left: 60),
                          child: Text('Reseñas', style: TextStyle(fontSize: 30, fontFamily: 'Idiqlat', 
                          color: Colors.black, fontWeight: FontWeight.w800)),
                        ),
                        
                        // LISTVIEW DINÁMICO DE RESEÑAS
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 60, top: 10, bottom: 10),
                            child: publicacion.calificaciones.isEmpty
                                ? const Text('No hay reseñas disponibles para esta posada todavía.', 
                                  style: TextStyle(fontSize: 20, color: Colors.grey))
                                : ListView.builder(
                                    itemCount: publicacion.calificaciones.length,
                                    itemBuilder: (context, index) {
                                      final calificacion = publicacion.calificaciones[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.circle, color: Color(0xFF216A44), size: 24),
                                            const SizedBox(width: 15),
                                            
                                            // Nombre del autor de la reseña
                                            Text(calificacion.nombreUsuario, style: const TextStyle(
                                              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                                            ),
                                            
                                            // Comentario de la reseña
                                            Expanded(
                                              child: Text(calificacion.comentario, style: const TextStyle(
                                                fontSize: 25, color: Colors.black), overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}