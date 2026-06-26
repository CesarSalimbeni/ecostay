import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/reserva.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/estadoreserva.dart';
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:ecostay/paypal_service.dart';

class DialogoPagoReserva extends StatelessWidget {
  final Reserva reservaActual;
  final Publicacion publicacion;
  final Viajero viajero;
  final VoidCallback onPagoCompletado;

  const DialogoPagoReserva({
    super.key, 
    required this.reservaActual, 
    required this.publicacion, 
    required this.viajero,
    required this.onPagoCompletado
  });

  @override
  Widget build(BuildContext context) {
    final paypalService = PaypalService(clientId: "TU_CLIENT_ID_PAYPAL", secretKey: "TU_SECRET_KEY_PAYPAL");
    final GestionReservacion gestionReservacion = GestionReservacion();
    
    bool esPendiente = reservaActual.estado == EstadoReserva.PENDIENTE;
    int noches = reservaActual.fechaFin.difference(reservaActual.fechaInicio).inDays;
    if (noches == 0) noches = 1;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), backgroundColor: ColorPalette.bg,
      title: const Text('Finalizar Pago con PayPal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,
      fontFamily: 'Idiqlat')),
      content: SizedBox(
        width: 450,
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: esPendiente ? Colors.orange.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15), 
            border: Border.all(color: esPendiente ? Colors.orange.shade300 : Colors.blue.shade300, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.paypal, color: Color(0xFF003087), size: 35),
                  SizedBox(width: 8),
                  Text('PayPal', style: TextStyle(color: Color(0xFF003087), fontWeight: FontWeight.bold, fontSize: 22, fontStyle: FontStyle.italic)),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Total a transferir: \$${reservaActual.total.toStringAsFixed(2)} ($noches ${noches == 1 ? 'noche' : 'noches'})',
                textAlign: TextAlign.center,
                style: TextStyle(color: esPendiente ? Colors.orange.shade900 : Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 15),
              if (esPendiente) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(child: Text('Espera a que su reserva sea confirmada para realizar el pago', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC439), foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    paypalService.iniciarFlujoPaypal(
                      context: context,
                      monto: reservaActual.total,
                      idReserva: reservaActual.id,
                      tituloPublicacion: publicacion.titulo,
                      onResultado: (exito) async {
                        if (exito) {
                          await gestionReservacion.completarReserva(reservaActual.id);
                          onPagoCompletado();
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                    );
                  },
                  child: const Text('Pagar Ahora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
      ],
    );
  }
}