import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:ecostay/pantallas/viaj_mis_reservas.dart';
import 'package:ecostay/pantallas/viaj_perfil.dart';
import 'package:ecostay/paypal_service.dart';
import 'package:ecostay/models/gestion_reservacion.dart'; 
import 'package:flutter/material.dart';
import 'dart:math';

class PantallaReserva extends StatefulWidget {
  final Publicacion publicacion;
  final Viajero viajero;

  const PantallaReserva({super.key, required this.publicacion, required this.viajero});

  @override
  State<PantallaReserva> createState() => _PantallaReservaState();
}

class _PantallaReservaState extends State<PantallaReserva> {
  DateTimeRange? _fechasSeleccionadas;
  bool _isPagoPendiente = false; 

  void _mostrarDialogoReserva(BuildContext pantallaContext) {
    final paypalService = PaypalService(apiKey: "TU_CLAVE_API_PAYPAL");
    final gestionReservacion = GestionReservacion();
    final messenger = ScaffoldMessenger.of(pantallaContext);

    showDialog(context: pantallaContext,
      builder: (BuildContext dialogoContext) {
        return StatefulBuilder(
          builder: (BuildContext bldContext, StateSetter setDialogState) {
            int noches = _fechasSeleccionadas != null ? _fechasSeleccionadas!.duration.inDays : 0;
            if (noches == 0 && _fechasSeleccionadas != null) noches = 1;
            double montoTotal = noches * widget.publicacion.precio;

            return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
              title: Text(
                _isPagoPendiente ? 'Finalizar Pago con PayPal' : 'Seleccionar Fechas de Reserva',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              content: SizedBox(width: 450,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    //PARTE SOLICITUD
                    if (!_isPagoPendiente) ...[
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
                            final DateTimeRange? picked = await showDialog<DateTimeRange>(
                              context: dialogoContext,
                              builder: (BuildContext context) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF216A44), onPrimary: Colors.white,
                                      surface: Color(0xFFF5F7F2), onSurface: Colors.black,
                                    ),
                                  ),
                                  child: Dialog(
                                    insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
                                      child: DateRangePickerDialog(firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                        initialDateRange: _fechasSeleccionadas,
                                        initialEntryMode: DatePickerEntryMode.calendar,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() {
                                _fechasSeleccionadas = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.date_range, color: Color(0xFF216A44)),
                          label: Text(
                            _fechasSeleccionadas == null
                                ? 'Elegir Fechas'
                                : '${_fechasSeleccionadas!.start.day}/${_fechasSeleccionadas!.start.month}/${_fechasSeleccionadas!.start.year} - ${_fechasSeleccionadas!.end.day}/${_fechasSeleccionadas!.end.month}/${_fechasSeleccionadas!.end.year}',
                            style: const TextStyle(color: Color(0xFF216A44), fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF216A44), foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300, minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
                        ),
                        onPressed: _fechasSeleccionadas == null ? null : () async {
                          await gestionReservacion.crearReservaSegura(
                            viajeroId: widget.viajero.id, 
                            publicacionId: widget.publicacion.id, 
                            data: {
                              'fechaInicio': _fechasSeleccionadas!.start.toIso8601String(),
                              'fechaFin': _fechasSeleccionadas!.end.toIso8601String(),
                              'estado': 'PENDIENTE',
                              'total': montoTotal,
                              'cupos': 1,
                            }
                          );

                          setState(() {_isPagoPendiente = true;});
                          
                          if (dialogoContext.mounted) {Navigator.pop(dialogoContext);}

                          messenger.showSnackBar(
                            const SnackBar(content: Text('¡Solicitud de reserva creada! Proceda a pagar.'),
                              backgroundColor: Color(0xFF216A44),
                            ),
                          );
                        },
                        child: const Text('Solicitar Reserva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      )
                    ]
                    
                    //PARTE PAGO
                    else ...[
                      const Text('2. Proceder con el pago:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      const SizedBox(height: 12),
                      Container(width: double.infinity, padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blue.shade300, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.paypal, color: Color(0xFF003087), size: 35),
                                const SizedBox(width: 8),
                                Text('PayPal',
                                  style: TextStyle(color: const Color(0xFF003087),
                                    fontWeight: FontWeight.bold, fontSize: 22, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Total a transferir: \$${montoTotal.toStringAsFixed(2)} ($noches ${noches == 1 ? 'noche' : 'noches'})',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 15),
                            
                            ElevatedButton(style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC439), foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.grey.shade300, minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
                              ),
                              onPressed: () {
                                bool exito = paypalService.procesarPago(montoTotal);
                                
                                if (exito) {
                                  if (dialogoContext.mounted) {Navigator.pop(dialogoContext);}
                                  
                                  setState(() {
                                    _isPagoPendiente = false;
                                    _fechasSeleccionadas = null;
                                  });

                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('¡Reserva completada con éxito por \$${montoTotal.toStringAsFixed(2)}!'),
                                      backgroundColor: const Color(0xFF216A44),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Pagar Ahora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ],

                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogoContext),
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
          Padding(padding: EdgeInsets.only(right: 10.0),
            child: CircleAvatar(),
          )
        ],
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Padding(padding: const EdgeInsets.only(top: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomeViajero(viajero: widget.viajero)),);
                    }, 
                    icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                    label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: widget.viajero)),);
                    }, 
                    icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                    label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PerfilViajero(viajero: widget.viajero)),);
                    },
                    icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                    label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                  ),
                ],
              ),
            ),

            // TARJETA DE DETALLE PRINCIPAL
            Center(child: Padding(padding: const EdgeInsets.only(top: 50),
                child: Container(width: 1240, height: 500, 
                  decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(25),), 
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(mainAxisAlignment: MainAxisAlignment.start, 
                            children: [
                              Padding(padding: const EdgeInsets.only(left: 20), 
                                child: Container(width: 300, height: 250, 
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), 
                                    image: DecorationImage(
                                      image: (widget.publicacion.imagenUrl != null && widget.publicacion.imagenUrl!.startsWith('http'))
                                          ? NetworkImage(widget.publicacion.imagenUrl!) as ImageProvider
                                          : const AssetImage('assets/images/fondo.jpg'),
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
                                      Text(widget.publicacion.titulo,style: const TextStyle(fontFamily: 'Idiqlat', 
                                      fontSize: 40, fontWeight: FontWeight.w800),
                                      ),
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                        children: [
                                          Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                            children: [
                                              Padding(padding: const EdgeInsets.only(top: 10),
                                                child: Text('Lugar: ${widget.publicacion.ubicacion}', style: const TextStyle(
                                                  fontSize: 30), overflow: TextOverflow.ellipsis, maxLines: 1),
                                              ),
                                              Padding(padding: const EdgeInsets.only(top: 10),
                                                child: Row(mainAxisSize: MainAxisSize.min,
                                                children: [
                                                const Text('Rating: ', style: TextStyle(fontSize: 30)),
                                                const Icon(Icons.star, color: Colors.amber, size: 32),
                                                Text(' ${widget.publicacion.calificacionPromedio.toStringAsFixed(1)}', 
                                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                                                ],),
                                              ),
                                            ],
                                          ),
                                          Padding(padding: const EdgeInsets.only(left: 10),
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
                                              children: [
                                                Padding(padding: const EdgeInsets.only(top: 10),
                                                  child: Text('Anfitrión: ${widget.publicacion.nombreAnfitrion}', 
                                                  style: const TextStyle(fontSize: 30), 
                                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                                                ),
                                                Padding(padding: const EdgeInsets.only(top: 10),
                                                  child: Text('Precio: \$${widget.publicacion.precio.toStringAsFixed(0)}', 
                                                  style: const TextStyle(fontSize: 30), overflow: TextOverflow.ellipsis, 
                                                  maxLines: 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          FilledButton(
                                            onPressed: () => _mostrarDialogoReserva(context), 
                                            style: FilledButton.styleFrom(
                                              backgroundColor: const Color(0xFF216A44), 
                                              foregroundColor: const Color(0xFFFFFFFF),
                                              disabledBackgroundColor: Colors.grey,
                                            ),
                                            child: Text(
                                              _isPagoPendiente ? 'Pagar' : 'Solicitar', 
                                              style: const TextStyle(fontSize: 30)
                                            ),
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
                        
                        const Padding(padding: EdgeInsets.only(left: 60),
                          child: Text('Reseñas', style: TextStyle(fontSize: 30, fontFamily: 'Idiqlat', 
                          color: Colors.black, fontWeight: FontWeight.w800)),
                        ),
                        
                        Expanded(
                          child: Padding(padding: const EdgeInsets.only(left: 60, top: 10, bottom: 10),
                            child: widget.publicacion.calificaciones.isEmpty
                                ? const Text('No hay reseñas disponibles para esta posada todavía.', 
                                  style: TextStyle(fontSize: 20, color: Colors.grey))
                                : ListView.builder(
                                    itemCount: widget.publicacion.calificaciones.length,
                                    itemBuilder: (context, index) {
                                      final calificacion = widget.publicacion.calificaciones[index];
                                      return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.circle, color: Color(0xFF216A44), size: 24),
                                            const SizedBox(width: 15),
                                            
                                            Text(calificacion.nombreUsuario, style: const TextStyle(
                                              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                                            ),
                                            
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