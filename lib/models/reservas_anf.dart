import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ecostay/estilo.dart';

enum FiltroReserva { todas, pendientes, confirmadas }

class ReservaData {
  final String viajero;
  final String destino;
  final String fecha;
  final int personas;
  final String total;
  final String estado;

  ReservaData({
    required this.viajero,
    required this.destino,
    required this.fecha,
    required this.personas,
    required this.total,
    required this.estado,
  });
}

class PantallaReservasAnf extends StatefulWidget {
  const PantallaReservasAnf({super.key});

  @override
  State<PantallaReservasAnf> createState() => _PantallaReservasAnfState();
}

class _PantallaReservasAnfState extends State<PantallaReservasAnf> {
  Set<FiltroReserva> _selectedFiltro = {FiltroReserva.todas};

  // 2. Datos de prueba simulando tu imagen
  final List<ReservaData> _reservas = [
    ReservaData(viajero: 'María Gónzales', destino: 'Posada Los Frailes', fecha: '15-May 2026', personas: 2, total: '84\$', estado: 'Solicitado'),
    ReservaData(viajero: 'Eduar Gónzales', destino: 'Cabaña Frente Al Mar', fecha: '17-Jun 2026', personas: 3, total: '90\$', estado: 'Pagado'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(
      backgroundColor: ColorPalette.bg, 
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg',fit: BoxFit.contain,),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28), 
              label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25))),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.upload, color: Color(0xFF216A44), size: 28), 
              label: const Text('Publicaciones', style: TextStyle(color: Color(0xFF216A44), fontSize: 25))),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), 
              size: 28), label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), 
              fontSize: 25, fontWeight: FontWeight.w900))),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), 
              size: 28), label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25))),
            ],),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(top: 40, bottom: 10),
                  child: Text('Reservas Recibidas', style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat', fontWeight: FontWeight.w800, fontSize: 30)),
                ),
                _buildSegmentedButton<FiltroReserva>(
                  context: context, 
                  selected: _selectedFiltro,
                  segments: const [
                    ButtonSegment(value: FiltroReserva.todas, label: Text('Todas', style: TextStyle(fontSize: 15))),
                    ButtonSegment(value: FiltroReserva.pendientes, label: Text('Pendientes', style: TextStyle(fontSize: 15))),
                    ButtonSegment(value: FiltroReserva.confirmadas, label: Text('Confirmadas', style: TextStyle(fontSize: 15))),
                  ], 
                  onSelectionChanged: (selection) {setState(() => _selectedFiltro = selection);},
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20), child: Center(
                    child: Container(width: 1230, height: 440, decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: Colors.grey.shade300, width: 1),),
                      child: ClipRRect(borderRadius: BorderRadius.circular(34), child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF6F7F6)),
                          dataRowMinHeight: 65, dataRowMaxHeight: 65,
                          headingTextStyle: const TextStyle(color: Color(0xFF758D93), 
                          fontWeight: FontWeight.bold, fontSize: 16),
                          columns: const [
                            DataColumn(label: Expanded(child: Center(child: Text('Viajero')))),
                            DataColumn(label: Expanded(child: Center(child: Text('Destino')))),
                            DataColumn(label: Expanded(child: Center(child: Text('Fecha')))),
                            DataColumn(label: Expanded(child: Center(child: Text('Personas')))),
                            DataColumn(label: Expanded(child: Center(child: Text('Total')))),
                            DataColumn(label: Expanded(child: Center(child: Text('Estado')))),
                            DataColumn(label: Expanded(child: Center(child: Text('Acciones')))),
                          ],
                          rows: _reservas.map((reserva) => DataRow(
                              cells: [
                                DataCell(Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 180),
                                  child: Text(reserva.viajero, style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis, maxLines: 1,),),
                                  )
                                ),
                                DataCell(Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 200),
                                  child: Text(reserva.destino, overflow: TextOverflow.ellipsis, maxLines: 1,),),
                                  )
                                ),
                                DataCell(Center(child: Text(reserva.fecha))),
                                DataCell(Center(child: Text(reserva.personas.toString()))),
                                DataCell(Center(child: Text(reserva.total, style: const TextStyle(fontWeight: FontWeight.bold)))),
                                DataCell(Center(child: _construirPildoraEstado(reserva.estado))),
                                DataCell(Center(child: _construirAcciones(reserva.estado))), 
                              ]
                            )).toList(),
                        ),),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ])
      )
    );
  }

  // --- MÉTODOS DE APOYO PARA LA TABLA ---

  // Método para diseñar la etiqueta ("píldora") del estado
  Widget _construirPildoraEstado(String estado) {
    Color bgColor;
    Color textColor;

    if (estado == 'Solicitado') {
      bgColor = const Color(0xFFE0E0E0);
      textColor = Colors.black87;
    } else if (estado == 'Pagado') {
      bgColor = const Color(0xFF216A44);
      textColor = Colors.white;
    } else {
      bgColor = Colors.grey;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Método que aplica la LÓGICA de mostrar/ocultar botones
  Widget _construirAcciones(String estado) {
    return SizedBox(width: 160, child: Row(mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (estado == 'Solicitado') ...[
          IconButton(icon: const Icon(Icons.check_circle, color: Color(0xFF3B7A57)), iconSize: 28,
            onPressed: () {
            // Lógica para aceptar reserva
            },
          ),
          IconButton(icon: const Icon(Icons.cancel, color: Color(0xFF903030)), iconSize: 28,
            onPressed: () {
            // Lógica para rechazar reserva
            },
          ),
          ],
          IconButton(icon: const Icon(Icons.visibility, color: Colors.black87), iconSize: 28,
            onPressed: () {
              // Lógica para ver detalles
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedButton<T>({
    required BuildContext context,
    required Set<T> selected,
    required List<ButtonSegment<T>> segments,
    required ValueChanged<Set<T>> onSelectionChanged,
  }) {
    return SegmentedButton<T>(
      segments: segments, 
      selected: selected, 
      onSelectionChanged: onSelectionChanged,
      showSelectedIcon: false, 
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black;
          }
          return const Color(0xFF526F75);
        }),
        side: WidgetStateProperty.all<BorderSide>(
          const BorderSide(color: Colors.transparent, width: 0),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFEFEFEF);
          }
          return const Color(0xFFFFFFFF);
        }),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(vertical: 18, horizontal: 5),
        ),
      ),
    );
  }
}