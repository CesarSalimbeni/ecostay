import 'package:ecostay/pantallas/estilo.dart';
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
  final TextEditingController _cuposController = TextEditingController(text: '1');
  int _cuposSeleccionados = 1;

  @override
  void initState() {
    super.initState();
    _cuposController.addListener(() {
      final int? valor = int.tryParse(_cuposController.text);
      if (valor != null && valor > 0) {
        setState(() {
          _cuposSeleccionados = valor;
        });
      } else {
        setState(() {
          _cuposSeleccionados = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _cuposController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int noches = _fechasSeleccionadas != null ? _fechasSeleccionadas!.duration.inDays : 0;
    if (noches == 0 && _fechasSeleccionadas != null) noches = 1;
    
    double montoTotal = noches * widget.publicacion.precio * _cuposSeleccionados;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), backgroundColor: ColorPalette.bg,
      title: const Text('Seleccionar Fechas de Reserva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,
      fontFamily: 'Idiqlat')),
      content: SizedBox(width: 450,
        child: Column(mainAxisSize: MainAxisSize.min,
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
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        scaffoldBackgroundColor: ColorPalette.bg,
                        dialogBackgroundColor: ColorPalette.bg,
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          surface: ColorPalette.bg,
                          primary: const Color(0xFF216A44),
                          primaryContainer: const Color(0xFFE2ECE7),
                          onPrimaryContainer: const Color(0xFF216A44),
                          secondaryContainer: const Color(0xFFE0F2E9),
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520,),
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10,
                                )
                              ]
                            ),
                            child: ClipRRect(borderRadius: BorderRadius.circular(20), child: child!,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
            const SizedBox(height: 20),
            
            // CAMPO NUMÉRICO PARA LOS CUPOS
            TextField(
              controller: _cuposController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad de Cupos / Personas',
                hintText: 'Ej. 2',
                prefixIcon: const Icon(Icons.groups, color: Color(0xFF216A44)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF216A44), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // VISTA PREVIA DEL PRECIO TOTAL DINÁMICO
            if (_fechasSeleccionadas != null) ...[
              Text(
                'Monto Total: \$${montoTotal.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF216A44)),
              ),
              const SizedBox(height: 15),
            ],

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF216A44), foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300, minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _fechasSeleccionadas == null ? null : () async {
                final int maxCupos = widget.publicacion.cuposMax ?? 99;
                if (_cuposSeleccionados > maxCupos) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Esta publicación solo permite un máximo de $maxCupos cupos.')),
                  );
                  return;
                }

                await _gestionReservacion.crearReservaSegura(
                  viajeroId: widget.viajero.id, 
                  publicacionId: widget.publicacion.id, 
                  data: {
                    'fechaInicio': _fechasSeleccionadas!.start.toIso8601String(),
                    'fechaFin': _fechasSeleccionadas!.end.toIso8601String(),
                    'estado': EstadoReserva.PENDIENTE.name,
                    'total': montoTotal,
                    'cupos': _cuposSeleccionados,
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