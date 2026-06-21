import 'package:flutter/material.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/estadoreserva.dart';
import 'package:ecostay/models/gestion_reservacion.dart';

class DialogoSolicitarReserva extends StatefulWidget {
  final Publicacion publicacion;
  final Viajero viajero;
  final VoidCallback onReservaCreada;

  const DialogoSolicitarReserva({
    super.key, 
    required this.publicacion, 
    required this.viajero, 
    required this.onReservaCreada
  });

  @override
  State<DialogoSolicitarReserva> createState() => _DialogoSolicitarReservaState();
}

class _DialogoSolicitarReservaState extends State<DialogoSolicitarReserva> {
  DateTimeRange? _fechasSeleccionadas;
  final GestionReservacion _gestionReservacion = GestionReservacion();

  @override
  Widget build(BuildContext context) {
    int noches = _fechasSeleccionadas != null ? _fechasSeleccionadas!.duration.inDays : 0;
    if (noches == 0 && _fechasSeleccionadas != null) noches = 1;
    double montoTotal = noches * widget.publicacion.precio;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Seleccionar Fechas de Reserva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: const BorderSide(color: Color(0xFF216A44), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: _fechasSeleccionadas,
                );
                if (picked != null) {
                  setState(() => _fechasSeleccionadas = picked);
                }
              },
              icon: const Icon(Icons.date_range, color: Color(0xFF216A44)),
              label: Text(
                _fechasSeleccionadas == null
                    ? 'Elegir Fechas'
                    : '${_fechasSeleccionadas!.start.day}/${_fechasSeleccionadas!.start.month} - ${_fechasSeleccionadas!.end.day}/${_fechasSeleccionadas!.end.month}',
                style: const TextStyle(color: Color(0xFF216A44), fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF216A44), foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300, minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _fechasSeleccionadas == null ? null : () async {
                await _gestionReservacion.crearReservaSegura(
                  viajeroId: widget.viajero.id, 
                  publicacionId: widget.publicacion.id, 
                  data: {
                    'fechaInicio': _fechasSeleccionadas!.start.toIso8601String(),
                    'fechaFin': _fechasSeleccionadas!.end.toIso8601String(),
                    'estado': EstadoReserva.PENDIENTE.name,
                    'total': montoTotal,
                    'cupos': 1,
                  }
                );

                widget.onReservaCreada();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Solicitar Reserva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
          ],
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