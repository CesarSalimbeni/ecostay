import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../models/usuario.dart';
import '../models/reserva.dart';
import '../models/publicacion.dart';
import '../paypal_service.dart';
class ResumenReservaScreen extends StatelessWidget {
  final Usuario usuarioActual;
  final Reserva reservaNueva;
  final Publicacion publicacionActual;

  const ResumenReservaScreen({
    Key? key,
    required this.usuarioActual,
    required this.reservaNueva,
    required this.publicacionActual,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final noches = reservaNueva.fechaFin.difference(reservaNueva.fechaInicio).inDays;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Resumen de la reserva', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // SECCIÓN DEL ALOJAMIENTO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: publicacionActual.imagenUrl != null && publicacionActual.imagenUrl!.startsWith('http')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(publicacionActual.imagenUrl!, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.holiday_village, color: Colors.grey, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(publicacionActual.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Anfitrión: ${publicacionActual.nombreAnfitrion}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Estilo: ${publicacionActual.estilo}', style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1),

            // INFORMACIÓN DEL VIAJE
            const Text('Información del viaje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Check-in', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(dateFormat.format(reservaNueva.fechaInicio), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Check-out', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(dateFormat.format(reservaNueva.fechaFin), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1),

            // DETALLES DEL HUÉSPED
            const Text('Detalles del huésped', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Nombre: ${usuarioActual.nombre}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('Correo electrónico: ${usuarioActual.email}', style: const TextStyle(fontSize: 14)),
            const Divider(height: 32, thickness: 1),

            // DESGLOSE DE PRECIOS
            const Text('Desglose de precio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${publicacionActual.precio.toStringAsFixed(2)} x $noches noches'),
                Text('\$${reservaNueva.total.toStringAsFixed(2)} USD'),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total (USD)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '\$${reservaNueva.total.toStringAsFixed(2)}', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003087))
                ),
              ],
            ),
            const SizedBox(height: 40),

            // BOTÓN DE PAYPAL
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC43D), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final paypalService = PaypalService(
                    clientId: "AehQDsnvUAHaygQV-OHVn5aOu7M7sIn80iNTo5s-p1Y0sH0esqZeP2YtikiTABxqRu-WQeivgmSN9JTp",
                    secretKey: "EJmB8_DGFsbQyv1sE8VWNapibiw4ZLnHBA8iArGjHvSE7eqHfFGXLWsovbZP18XhXKSnHw9JXkWxRzqv");
                  paypalService.iniciarFlujoPaypal(
                    context: context,
                    monto: reservaNueva.total,
                    idReserva: reservaNueva.id,
                    tituloPublicacion: publicacionActual.titulo,
                    onResultado: (bool pagoExitoso) {
                      if (pagoExitoso) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("¡Reserva confirmada con éxito!"), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF1E1E24), 
                            behavior: SnackBarBehavior.floating,
                            content: const Text("Pago cancelado o fallido. Reserva no registrada."),
                          ),
                        );
                      }
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.security, color: Colors.black87, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Pagar con PayPal',
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}