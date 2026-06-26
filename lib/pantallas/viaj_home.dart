import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
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
  final GestionUsuario _gestionUsuario = GestionUsuario();
  
  final TextEditingController _searchController = TextEditingController();
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
          final bool tieneUbicaciones = _ubicacionesDisponibles.isNotEmpty;
          final bool isMobile = MediaQuery.of(context).size.width < 768;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
            backgroundColor: ColorPalette.bg,
            title: const Row(
              children: [
                Icon(Icons.tune, color: Color(0xFF216A44)),
                SizedBox(width: 10),
                Text('Filtros Inteligentes', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Idiqlat')),
              ],
            ),
            content: SizedBox(
              width: isMobile ? MediaQuery.of(context).size.width * 0.85 : 400, 
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
                    _presupuestoController.clear(); 
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
    // Detectamos si es pantalla móvil
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), 
        toolbarHeight: isMobile ? 70 : 90, 
        leadingWidth: isMobile ? 80 : 120, 
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: isMobile ? 10.0 : 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
        ),
        // Si es móvil ocultamos la barra del appBar para que no se amontone, se maneja abajo
        title: isMobile 
          ? null 
          : SearchBar(
              controller: _searchController,
              hintText: 'Buscar por título...', 
              hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
              leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
              backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (value) => _ejecutarBusqueda(), 
            ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isMobile ? 10.0 : 20.0),
            child: Tooltip(
              message: 'Cerrar sesión', 
              preferBelow: true, 
              verticalOffset: 25,
              textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: BoxDecoration(
                color: const Color(0xFF216A44).withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () async {
                  try {
                    await _gestionUsuario.cerrarSesion();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sesión cerrada con éxito')),
                      );
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) => const PantallaInicio()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar sesión: $e')),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMobile) ...[
                        Text(widget.viajero.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
                          style: const TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                      ],
                      CircleAvatar(
                        backgroundColor: const Color(0xFF216A44),
                        backgroundImage: widget.viajero.imagenUrl != null && widget.viajero.imagenUrl!.isNotEmpty
                            ? NetworkImage(widget.viajero.imagenUrl!)
                            : null,
                        child: widget.viajero.imagenUrl == null || widget.viajero.imagenUrl!.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // Menú de Navegación adaptado
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                _buildNavigationButton(
                  icon: Icons.search, label: 'Explorar', isActive: true, isMobile: isMobile, onTap: () {}
                ),
                _buildNavigationButton(
                  icon: Icons.send_outlined, label: 'Reservas', isActive: false, isMobile: isMobile,
                  onTap: () {
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PantallaMisReservas(viajero: widget.viajero)),
                    );
                  }
                ),
                _buildNavigationButton(
                  icon: Icons.person_outline, label: 'Perfil', isActive: false, isMobile: isMobile,
                  onTap: () {
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PerfilViajero(viajero: widget.viajero)),
                    );
                  }
                ),
              ],
            ),
          ),

          // Contenido Principal Fluido
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Definimos márgenes y anchos máximos en base al espacio disponible
                double paddingHorizontal = constraints.maxWidth > 1200 ? 100 : (isMobile ? 16 : 40);
                
                return SingleChildScrollView(
                  padding: EdgeInsets.only(left: paddingHorizontal, right: paddingHorizontal, top: 15, bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de filtros unificada y dinámica
                      _buildResponsiveFilterBar(isMobile),
                      
                      const SizedBox(height: 35),

                      // Listado adaptativo en Grid dinámico
                      FutureBuilder<List<Publicacion>>(
                        future: _publicacionesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(color: Color(0xFF216A44)),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error al procesar búsqueda: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text('No se encontraron hospedajes con los criterios seleccionados.', 
                                  style: TextStyle(fontSize: 16, color: Colors.grey)),
                              ),
                            );
                          }

                          final listado = snapshot.data!;

                          // Mantenemos estrictamente tu distribución de columnas original
                          int crossAxisCount = 3;
                          if (constraints.maxWidth < 600) {
                            crossAxisCount = 1; // Teléfonos
                          } else if (constraints.maxWidth < 950) {
                            crossAxisCount = 2; // Tablets
                          }

                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1050),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: listado.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 20, // Espaciado elegante original
                                  mainAxisSpacing: 20,
                                  mainAxisExtent: constraints.maxWidth < 600 ? 310 : 320,
                                ),
                                itemBuilder: (context, index) {
                                  final publicacion = listado[index];
                                  return GestureDetector(
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
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        ]
      )
    );
  }

  // Widget auxiliar para los botones superiores que reducen el tamaño de letra en móviles
  Widget _buildNavigationButton({
    required IconData icon, required String label, required bool isActive, required bool isMobile, required VoidCallback onTap
  }) {
    return TextButton.icon(
      onPressed: onTap, 
      icon: Icon(icon, color: const Color(0xFF216A44), size: isMobile ? 22 : 28),
      label: Text(label, style: TextStyle(
        color: const Color(0xFF216A44), 
        fontSize: isMobile ? 16 : 22,
        fontWeight: isActive ? FontWeight.w900 : FontWeight.normal
      )),
    );
  }

  // Barra de filtros que cambia de Row a Column si es móvil
  Widget _buildResponsiveFilterBar(bool isMobile) {
    final searchInput = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5F7F2), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _ejecutarBusqueda(),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFF526F75)),
          hintText: '¿A dónde vas?',
          hintStyle: TextStyle(color: Color(0xFF526F75)),
          border: InputBorder.none,
        ),
      ),
    );

    final budgetInput = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5F7F2), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _presupuestoController,
        keyboardType: TextInputType.number, 
        style: const TextStyle(color: Color(0xFF526F75)),
        onChanged: (value) {
          setState(() {
            _precioMax = double.tryParse(value);
          });
          _ejecutarBusqueda(); 
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.attach_money, color: Color(0xFF526F75), size: 20),
          hintText: 'Presupuesto Máx',
          hintStyle: TextStyle(color: Color(0xFF526F75)),
          border: InputBorder.none,
        ),
      ),
    );

    final filterButton = OutlinedButton(
      onPressed: () => _mostrarPopUpFiltros(context),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Center(
        child: Text(
          _ubicacionSeleccionada != null || _calificacionMin != null || _precioMin != null || _precioMax != null
              ? 'Filtros (*)' 
              : 'Filtros', 
          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );

    final searchButton = ElevatedButton(
      onPressed: () => _ejecutarBusqueda(),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF216A44), 
        foregroundColor: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Center(child: Text('Buscar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: isMobile 
        ? Column(
            children: [
              searchInput,
              const SizedBox(height: 10),
              budgetInput,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: filterButton),
                  const SizedBox(width: 10),
                  Expanded(child: searchButton),
                ],
              )
            ],
          )
        : Row(
            children: [
              Expanded(flex: 4, child: searchInput),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: budgetInput),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: filterButton),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: searchButton),
            ],
          ),
    );
  }

  Widget _buildDestinationCard(String title, String location, String price, String imagePath, String rating) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath, height: 185, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 185, color: Colors.grey[300], 
                        child: const Icon(Icons.image, size: 40)),
                      )
                    : Image.asset(
                        imagePath, height: 185, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 185, color: Colors.grey[300], 
                        child: const Icon(Icons.image, size: 40)),
                      ),
              ),
              Positioned(top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFC2DC77), borderRadius: BorderRadius.circular(12)),
                  child: Text(rating, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, 
                        style: const TextStyle(fontSize: 18, fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, 
                        style: const TextStyle(color: Color(0xFF6E867A), fontSize: 13)),
                    ],
                  ),
                  Column(
                    children: [
                      const Divider(color: Color(0xFFEBEBEB), thickness: 1.5, height: 8),
                      Align(alignment: Alignment.bottomRight,
                        child: Text(price, style: const TextStyle(color: Color(0xFF216A44), fontSize: 20, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}