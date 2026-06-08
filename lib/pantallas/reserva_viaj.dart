import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/calificacion.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/mis_reservas_viaj.dart';
import 'package:ecostay/paypal_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaReserva extends StatelessWidget {
  final Publicacion publicacion;
  final Viajero viajero;

  const PantallaReserva({super.key, required this.publicacion, required this.viajero});

  void _mostrarDialogoReserva(BuildContext context) {
    final paypalService = PaypalService(apiKey: "TU_CLAVE_API_PAYPAL");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTimeRange? fechasSeleccionadas;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            int noches = fechasSeleccionadas != null ? fechasSeleccionadas!.duration.inDays : 0;
            if (noches == 0 && fechasSeleccionadas != null) noches = 1;
            double montoTotal = noches * publicacion.precio;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Finalizar Reserva',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              content: SizedBox(width: 450,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Selecciona las fechas de estadía:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: OutlinedButton.icon(style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          side: const BorderSide(color: Color(0xFF216A44), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            initialDateRange: fechasSeleccionadas,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(primary: Color(0xFF216A44),
                                    onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              fechasSeleccionadas = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.date_range, color: Color(0xFF216A44)),
                        label: Text(
                          fechasSeleccionadas == null
                              ? 'Elegir Fechas'
                              : '${fechasSeleccionadas!.start.day}/${fechasSeleccionadas!.start.month}/${fechasSeleccionadas!.start.year} - ${fechasSeleccionadas!.end.day}/${fechasSeleccionadas!.end.month}/${fechasSeleccionadas!.end.year}',
                          style: const TextStyle(color: Color(0xFF216A44), fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    const Divider(thickness: 1),
                    const SizedBox(height: 15),

                    const Text('2. Proceder con el pago:',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 12),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: fechasSeleccionadas == null ? Colors.grey.shade100 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: fechasSeleccionadas == null ? Colors.grey.shade300 : Colors.blue.shade300, 
                          width: 1.5
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.paypal, 
                              color: fechasSeleccionadas == null ? Colors.grey : const Color(0xFF003087), size: 35
                              ),
                              const SizedBox(width: 8),
                              Text('PayPal',
                                style: TextStyle(
                                  color: fechasSeleccionadas == null ? Colors.grey : const Color(0xFF003087),
                                  fontWeight: FontWeight.bold, fontSize: 22, fontStyle: FontStyle.italic
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            fechasSeleccionadas == null 
                              ? 'Por favor, selecciona las fechas primero.' 
                              : 'Total a transferir: \$${montoTotal.toStringAsFixed(2)} ($noches ${noches == 1 ? 'noche' : 'noches'})',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: fechasSeleccionadas == null ? Colors.grey : Colors.blue.shade900, 
                              fontWeight: FontWeight.bold, fontSize: 16
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          ElevatedButton(style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC439), foregroundColor: Colors.black,
                            disabledBackgroundColor: Colors.grey.shade300, minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
                            ),
                            onPressed: fechasSeleccionadas == null ? null : () {
                              bool exito = paypalService.procesarPago(montoTotal);
                              
                              if (exito) {
                                Navigator.pop(context);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('¡Reserva completada con éxito por \$${montoTotal.toStringAsFixed(2)}!'),
                                    backgroundColor: const Color(0xFF216A44),
                                  ),
                                );
                              }
                            },
                            child: const Text('Pagar Ahora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(padding: const EdgeInsets.only(left: 40.0),
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
          Padding(padding: EdgeInsets.only(right: 10.0),
            child: Text('Usuario', overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 20)),
          ),
          CircleAvatar()
        ],
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Padding(padding: const EdgeInsets.only(top: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  TextButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                    label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: viajero)),
                      );
                    }, 
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
            Center(child: Padding(padding: const EdgeInsets.only(top: 50),
                child: Container(width: 1240, height: 500, 
                  decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(25),
                  ), 
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(mainAxisAlignment: MainAxisAlignment.start, 
                            children: [
                              Padding(padding: const EdgeInsets.only(left: 20), 
                                child: Container(width: 300, height: 250, 
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), 
                                    image: const DecorationImage(image: AssetImage('assets/images/fondo.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // INFORMACIÓN DE LA PUBLICACIÓN
                              Expanded(
                                child: Padding(padding: const EdgeInsets.all(20),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text(publicacion.titulo,style: const TextStyle(fontFamily: 'Idiqlat', 
                                      fontSize: 40, fontWeight: FontWeight.w800),
                                      ),
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                        children: [
                                          Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                            children: [
                                              Padding(padding: const EdgeInsets.only(top: 10),
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
                                          Padding(padding: const EdgeInsets.only(left: 10),
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                              children: [
                                                Padding(padding: const EdgeInsets.only(top: 10),
                                                  child: Text('Anfitrión: ${publicacion.nombreAnfitrion}', 
                                                  style: const TextStyle(fontSize: 30), 
                                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                                                ),
                                                Padding(padding: const EdgeInsets.only(top: 10),
                                                  child: Text('Precio: \$${publicacion.precio.toStringAsFixed(0)}', 
                                                  style: const TextStyle(fontSize: 30), overflow: TextOverflow.ellipsis, 
                                                  maxLines: 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // BOTÓN PAGAR (Llama al diálogo de reserva con el método recuperado)
                                          FilledButton(
                                            onPressed: publicacion.disponibilidad ? () => _mostrarDialogoReserva(context) : null, 
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
                        const Padding(padding: EdgeInsets.only(left: 60),
                          child: Text('Reseñas', style: TextStyle(fontSize: 30, fontFamily: 'Idiqlat', 
                          color: Colors.black, fontWeight: FontWeight.w800)),
                        ),
                        
                        // LISTVIEW DINÁMICO DE RESEÑAS
                        Expanded(
                          child: Padding(padding: const EdgeInsets.only(left: 60, top: 10, bottom: 10),
                            child: publicacion.calificaciones.isEmpty
                                ? const Text('No hay reseñas disponibles para esta posada todavía.', 
                                  style: TextStyle(fontSize: 20, color: Colors.grey))
                                : ListView.builder(
                                    itemCount: publicacion.calificaciones.length,
                                    itemBuilder: (context, index) {
                                      final calificacion = publicacion.calificaciones[index];
                                      return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0),
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