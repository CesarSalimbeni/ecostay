import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ecostay/pantallas/estilo.dart';

// Importaciones del nuevo servicio y modelos de datos
import 'package:ecostay/models/gestion_reservacion.dart'; // Asegúrate de colocar la ruta correcta de tu archivo
import 'package:ecostay/models/reserva.dart';
import 'package:ecostay/models/estadoreserva.dart';

enum FiltroReserva { todas, pendientes, confirmadas }

class ReservaData {
  final String id; 
  final String viajero;
  final String destino;
  final String fecha;
  final int personas;
  final String total;
  final String estado;
  final EstadoReserva estadoReal;

  ReservaData({
    required this.id,
    required this.viajero,
    required this.destino,
    required this.fecha,
    required this.personas,
    required this.total,
    required this.estado,
    required this.estadoReal,
  });
}

class PantallaReservasAnf extends StatefulWidget {
  const PantallaReservasAnf({super.key});

  @override
  State<PantallaReservasAnf> createState() => _PantallaReservasAnfState();
}

class _PantallaReservasAnfState extends State<PantallaReservasAnf> {
  Set<FiltroReserva> _selectedFiltro = {FiltroReserva.todas};
  
  final GestionReservacion _gestionReservacion = GestionReservacion();


  List<ReservaData> _transformarDatos(List<dynamic> reservasDeFirestore) {
    return reservasDeFirestore.map((item) {
      return ReservaData(
        id: 'id_documento_aqui', 
        viajero: 'Viajero ID: ${item.viajeroId}',
        destino: 'Alojamiento ID: ${item.publicacionId}',
        fecha: '${item.reserva.fechaInicio.day}/${item.reserva.fechaInicio.month}',
        personas: 2,
        total: '${item.reserva.total}\$',
        estado: item.reserva.estado == EstadoReserva.CONFIRMADA ? 'Pagado' : 'Solicitado',
        estadoReal: item.reserva.estado,
      );
    }).toList();
  }

  // Lógica de filtrado en memoria basada en el SegmentedButton
  List<ReservaData> _filtrarReservas(List<ReservaData> listaCompleta) {
    if (_selectedFiltro.contains(FiltroReserva.todas)) {
      return listaCompleta;
    } else if (_selectedFiltro.contains(FiltroReserva.pendientes)) {
      // Suponiendo que PENDIENTE o un equivalente mapea a tus solicitudes
      return listaCompleta.where((r) => r.estadoReal != EstadoReserva.CONFIRMADA && r.estadoReal != EstadoReserva.CANCELADA).toList();
    } else if (_selectedFiltro.contains(FiltroReserva.confirmadas)) {
      return listaCompleta.where((r) => r.estadoReal == EstadoReserva.CONFIRMADA).toList();
    }
    return listaCompleta;
  }

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
                        
                        // INTEGRACIÓN CON FIRESTORE:
                        // Usamos un StreamBuilder conectado a la colección de Firestore para actualizaciones en tiempo real.
                        // (Si no tienes un stream implementado, puedes cambiarlo por FutureBuilder)
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('reservations').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(child: Text('Error al cargar las reservas.')),
                              );
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(child: CircularProgressIndicator(color: Color(0xFF216A44))),
                              );
                            }

                            // 1. Extraemos los documentos crudos de Firestore
                            final docs = snapshot.data?.docs ?? [];
                            
                            // 2. Mapeamos dinámicamente cada documento a nuestro modelo de interfaz 'ReservaData'
                            List<ReservaData> reservasCargadas = docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              
                              // Evaluamos de forma segura el string guardado para transformarlo al enum local
                              String estadoDb = data['estado'] ?? '';
                              EstadoReserva estadoReal = EstadoReserva.values.firstWhere(
                                (e) => e.toString() == estadoDb, 
                                overflow: () => EstadoReserva.PENDIENTE // Valor por defecto si no coincide
                              );

                              // Traducimos el estado real a la etiqueta visual que ya tenías
                              String estadoVisual = 'Solicitado';
                              if (estadoReal == EstadoReserva.CONFIRMADA) estadoVisual = 'Pagado';
                              if (estadoReal == EstadoReserva.CANCELADA) estadoVisual = 'Cancelado';

                              return ReservaData(
                                id: doc.id, // Aquí recuperamos el ID del documento real
                                viajero: data['viajeroId'] ?? 'Desconocido', // Reemplazar más adelante con el nombre real
                                destino: data['publicacionId'] ?? 'Alojamiento', // Reemplazar más adelante con el nombre real
                                fecha: 'Ver detalles', // Puedes parsear tus timestamps de Firebase aquí
                                personas: 2, 
                                total: '${data['total'] ?? 0}\$',
                                estado: estadoVisual,
                                estadoReal: estadoReal,
                              );
                            }).toList();

                            // 3. Aplicamos el filtro seleccionado por el usuario en la interfaz
                            List<ReservaData> reservasFiltradas = _filtrarReservas(reservasCargadas);

                            if (reservasFiltradas.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(child: Text('No hay reservas para mostrar con este filtro.')),
                              );
                            }

                            return DataTable(
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
                              rows: reservasFiltradas.map((reserva) => DataRow(
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
                                    DataCell(Center(child: _construirAcciones(reserva))), // Pasamos el objeto completo para usar su ID
                                  ]
                                )).toList(),
                            );
                          }
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

  // --- MÉTODOS DE APOYO ADAPTADOS ---

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
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
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

  // Ahora recibe toda la información de la fila seleccionada para ejecutar acciones específicas en Firestore
  Widget _construirAcciones(ReservaData reserva) {
    return SizedBox(width: 160, child: Row(mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (reserva.estadoReal != EstadoReserva.CONFIRMADA && reserva.estadoReal != EstadoReserva.CANCELADA) ...[
          IconButton(
            icon: const Icon(Icons.check_circle, color: Color(0xFF3B7A57)), 
            iconSize: 28,
            onPressed: () async {
              // Llamada a la función de Firebase usando el ID de este documento específico
              await _gestionReservacion.confirmarReserva(reserva.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reserva confirmada exitosamente.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Color(0xFF903030)), 
            iconSize: 28,
            onPressed: () async {
              // Llamada a la cancelación en Firebase
              await _gestionReservacion.cancelarReserva(reserva.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reserva rechazada.')),
              );
            },
          ),
        ],
        IconButton(
          icon: const Icon(Icons.visibility, color: Colors.black87), 
          iconSize: 28,
          onPressed: () {
            // Lógica para ver detalles (puedes usar _gestionReservacion.obtenerInformacion(reserva.id))
          },
        ),
      ],
    ),);
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
          if (states.contains(WidgetState.selected)) return Colors.black;
          return const Color(0xFF526F75);
        }),
        side: WidgetStateProperty.all<BorderSide>(const BorderSide(color: Colors.transparent, width: 0)),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFFEFEFEF);
          return const Color(0xFFFFFFFF);
        }),
        padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 18, horizontal: 5)),
      ),
    );
  }
}

// Extensión pequeña y utilitaria para evitar caídas en el firstWhere de enums si no coinciden los strings exactos
extension FirstWhereOrNull<T> on Iterable<T> {
  T firstWhere(bool Function(T element) test, {required T Function() overflow}) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return overflow();
  }
}