import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/reserva_viaj_main.dart';
import 'package:ecostay/pantallas/viaj_mis_reservas.dart';
import 'package:ecostay/models/buscador_exploracion.dart'; 
import 'package:flutter/material.dart';
import 'viaj_perfil.dart';

class HomeViajero extends StatefulWidget {
  final Viajero viajero; 

  const HomeViajero({super.key, required this.viajero});

  @override
  State<HomeViajero> createState() => _HomeViajeroState();
}

class _HomeViajeroState extends State<HomeViajero> {
  final BuscadorExploracion _buscador = BuscadorExploracion();
  
  final TextEditingController _searchController = TextEditingController();
  // Controlador para la barra de presupuesto superior
  final TextEditingController _presupuestoController = TextEditingController();

  String? _ubicacionSeleccionada;
  double? _calificacionMin;
  double? _precioMin;
  double? _precioMax;

  late Future<List<Publicacion>> _publicacionesFuture;

  List<String> _ubicacionesDisponibles = [];
  double _precioMaxSugerido = 1000.0;
  double _precioMinSugerido = 0.0;

  @override
  void initState() {
    super.initState();
    _ejecutarBusqueda();
    _cargarDatosDeFiltrosDinamicos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _presupuestoController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosDeFiltrosDinamicos() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('publications').get();
      
      final Set<String> ubicacionesSet = {};
      double maxPrecio = 0.0;
      double minPrecio = double.infinity;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        if (data['ubicacion'] != null && data['ubicacion'].toString().isNotEmpty) {
          String ubicacionTexto = data['ubicacion'].toString().trim();
          if (ubicacionTexto.toLowerCase() != "prueba de ubicación.") {
            ubicacionesSet.add(ubicacionTexto);
          }
        }

        if (data['precio'] != null) {
          double precio = (data['precio'] as num).toDouble();
          if (precio > maxPrecio) maxPrecio = precio;
          if (precio < minPrecio) minPrecio = precio;
        }
      }

      setState(() {
        _ubicacionesDisponibles = ubicacionesSet.toList()..sort();
        _precioMaxSugerido = maxPrecio == 0.0 ? 1000.0 : maxPrecio;
        _precioMinSugerido = minPrecio == double.infinity ? 0.0 : minPrecio;
      });
    } catch (e) {
      print("Error cargando filtros dinámicos: $e");
    }
  }

  void _ejecutarBusqueda() {
    setState(() {
      _publicacionesFuture = _buscador.buscarPublicaciones(
        titulo: _searchController.text.isEmpty ? null : _searchController.text,
        ubicacion: _ubicacionSeleccionada,
        calificacionMin: _calificacionMin,
        precioMin: _precioMin,
        precioMax: _precioMax,
      );
    });
  }

  void _mostrarPopUpFiltros(BuildContext context) {
    final TextEditingController pMinController = TextEditingController(
      text: _precioMin?.toString() ?? '',
    );
    final TextEditingController pMaxController = TextEditingController(
      text: _precioMax?.toString() ?? '',
    );
    String? tempUbicacion = _ubicacionSeleccionada;
    double tempCalificacion = _calificacionMin ?? 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool tieneUbicaciones = _ubicacionesDisponibles != null && _ubicacionesDisponibles.isNotEmpty;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.tune, color: Color(0xFF216A44)),
                  SizedBox(width: 10),
                  Text('Filtros Inteligentes', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ubicación disponible:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      
                      if (!tieneUbicaciones)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text('Cargando ubicaciones de la base de datos...', style: TextStyle(color: Colors.grey)),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _ubicacionesDisponibles.contains(tempUbicacion) ? tempUbicacion : null,
                          hint: const Text('Todas las regiones disponibles'),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: _ubicacionesDisponibles.map((String ubicacion) {
                            return DropdownMenuItem<String>(
                              value: ubicacion,
                              child: Text(ubicacion),
                            );
                          }).toList(),
                          onChanged: (value) => setDialogState(() => tempUbicacion = value),
                        ),
                      const SizedBox(height: 20),

                      const Text('Rango de Precio (\$):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Sugerido por el sistema: \$${_precioMinSugerido.toStringAsFixed(0)} a \$${_precioMaxSugerido.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: pMinController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Min: \$${_precioMinSugerido.toStringAsFixed(0)}',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextField(
                              controller: pMaxController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Max: \$${_precioMaxSugerido.toStringAsFixed(0)}',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Calificación Mínima: ${tempCalificacion == 0.0 ? "Cualquiera" : "${tempCalificacion.toStringAsFixed(1)} ★"}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Slider(
                        value: tempCalificacion,
                        min: 0.0,
                        max: 5.0,
                        divisions: 5,
                        activeColor: const Color(0xFF216A44),
                        inactiveColor: Colors.grey.shade300,
                        onChanged: (value) => setDialogState(() => tempCalificacion = value),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _ubicacionSeleccionada = null;
                      _precioMin = null;
                      _precioMax = null;
                      _calificacionMin = null;
                      _presupuestoController.clear(); // Limpia la barra superior también
                    });
                    _ejecutarBusqueda();
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar Filtros', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF216A44)),
                  onPressed: () {
                    setState(() {
                      _ubicacionSeleccionada = tempUbicacion;
                      _calificacionMin = tempCalificacion == 0.0 ? null : tempCalificacion;
                      _precioMin = double.tryParse(pMinController.text);
                      _precioMax = double.tryParse(pMaxController.text);
                      
                      // Refleja el precio máximo del pop-up en la barra superior
                      if (_precioMax != null) {
                        _presupuestoController.text = _precioMax!.toStringAsFixed(0);
                      } else {
                        _presupuestoController.clear();
                      }
                    });
                    _ejecutarBusqueda(); 
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
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
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, 
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain,),
        ),
        title: SearchBar(
          controller: _searchController,
          hintText: 'Buscar por título...', 
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
          onChanged: (value) => _ejecutarBusqueda(), 
        ),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: Text(widget.viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
            style: const TextStyle(fontSize: 20)),
          ),
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF216A44),
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                TextButton.icon(onPressed: null, 
                  icon: const Icon(Icons.search, color: Color(0xFF216A44), size: 28),
                  label: const Text('Explorar', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                  fontWeight: FontWeight.w900)),
                ),
                TextButton.icon(onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: widget.viajero),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Reservas', style: TextStyle(color: Color(0xFF216A44), fontSize: 25, )),
                ),
                TextButton.icon(onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PerfilViajero(viajero: widget.viajero),
                      ),
                    );
                  }, 
                  icon: const Icon(Icons.person_outline, color: Color(0xFF216A44), size: 28),
                  label: const Text('Perfil', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(padding: const EdgeInsets.only(top: 30, bottom: 40),
                  child: SizedBox(width: 992,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 4,
                                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) => _ejecutarBusqueda(),
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.search, color: Color(0xFF526F75)),
                                      hintText: '¿A dónde vas? (Escribe un título...)',
                                      hintStyle: TextStyle(color: Color(0xFF526F75)),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // CAJA DE PRESUPUESTO ACTIVA: Transformada a TextField editable
                              Expanded(flex: 2,
                                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(color: const Color(0xFFF5F7F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _presupuestoController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Color(0xFF526F75)),
                                    onChanged: (value) {
                                      setState(() {
                                        _precioMax = double.tryParse(value);
                                      });
                                      _ejecutarBusqueda(); // Filtra instantáneamente al escribir
                                    },
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.attach_money, color: Color(0xFF526F75), size: 20),
                                      hintText: 'Presupuesto Máx',
                                      hintStyle: TextStyle(color: Color(0xFF526F75)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              OutlinedButton(
                                onPressed: () => _mostrarPopUpFiltros(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black, width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                ),
                                child: Text(
                                  _ubicacionSeleccionada != null || _calificacionMin != null || _precioMin != null || _precioMax != null
                                      ? 'Filtros (*)' 
                                      : 'Filtros', 
                                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => _ejecutarBusqueda(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF216A44),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                ),
                                child: const Text('Buscar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 35),

                        FutureBuilder<List<Publicacion>>(
                          future: _publicacionesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(color: Color(0xFF216A44)),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error al procesar búsqueda: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Padding(padding: EdgeInsets.all(20.0),
                                  child: Text('No se encontraron hospedajes con los criterios seleccionados.', 
                                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                                ),
                              );
                            }

                            final listado = snapshot.data!;

                            return Wrap(spacing: 16, runSpacing: 16,
                              children: listado.map((publicacion) {
                                return SizedBox(
                                  width: (992 - 32) / 3, 
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => PantallaReserva(
                                          publicacion: publicacion, viajero: widget.viajero,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildDestinationCard(
                                      publicacion.titulo, 
                                      publicacion.ubicacion, 
                                      '\$${publicacion.precio}', 
                                      publicacion.imagenUrl ?? 'assets/images/los_roques.jpg',
                                      publicacion.calificacionPromedio.toStringAsFixed(1),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]
      )
    );
  }

  Widget _buildDestinationCard(String title, String location, String price, String imagePath, String rating) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath, height: 200, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 200, color: Colors.grey[300], child: const Icon(Icons.image, size: 50)),
                      )
                    : Image.asset(
                        imagePath, height: 200, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 200, color: Colors.grey[300], child: const Icon(Icons.image, size: 50)),
                      ),
              ),
              Positioned(top: 12, right: 12,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFC2DC77), borderRadius: BorderRadius.circular(12)),
                  child: Text(rating, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(location, style: const TextStyle(color: Color(0xFF6E867A), fontSize: 14)),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
                Align(alignment: Alignment.bottomRight,
                  child: Text(price, style: const TextStyle(color: Color(0xFF216A44), fontSize: 24, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}