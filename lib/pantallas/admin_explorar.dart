import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/publicacion.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_perfil.dart';
import 'package:ecostay/pantallas/admin_pub.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:ecostay/models/buscador_exploracion.dart'; 
import 'package:flutter/material.dart';

class AdminExplorar extends StatefulWidget {
  final Administrador administrador; 

  const AdminExplorar({super.key, required this.administrador});

  @override
  State<AdminExplorar> createState() => _AdminExplorarState();
}

class _AdminExplorarState extends State<AdminExplorar> {
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
            final bool tieneUbicaciones = _ubicacionesDisponibles != null && _ubicacionesDisponibles.isNotEmpty;
            double anchoPantalla = MediaQuery.of(context).size.width;

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
                width: anchoPantalla > 500 ? 400 : anchoPantalla * 0.85, // Responsivo para el diálogo
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

  // Helper para cerrar sesión
  Future<void> _logout(BuildContext context) async {
    try {
      await _gestionUsuario.cerrarSesion();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada con éxito')),
        );
        Navigator.pushAndRemoveUntil(
          context,
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
  }

  // Construye la lista de navegación para reutilizar en Drawer u Horizontal Row
  List<Widget> _buildNavItems(BuildContext context, {bool isVertical = false}) {
    final double fontSize = isVertical ? 18 : 22;
    return [
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeAdmin(administrador: widget.administrador)));
        },
        icon: Icon(Icons.dns, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Dashboard', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: null,
        icon: Icon(Icons.search, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Explorar', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize, fontWeight: FontWeight.w900)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: widget.administrador)));
        },
        icon: Icon(Icons.person_add_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Usuarios', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminModeracion(administrador: widget.administrador)));
        },
        icon: Icon(Icons.shield_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Moderación', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilAdministrador(administrador: widget.administrador)));
        },
        icon: Icon(Icons.person_outline, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Perfil', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize, fontWeight: FontWeight.w900)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double anchoPantalla = MediaQuery.of(context).size.width;
    bool esDesktop = anchoPantalla > 900;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), 
        toolbarHeight: esDesktop ? 90 : 70, 
        centerTitle: esDesktop ? true : false,
        leading: esDesktop 
          ? Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
            )
          : null, // Muestra el botón de menú (hamburguesa) automáticamente si hay un Drawer en móviles
        title: esDesktop 
          ? SizedBox(
              width: 400,
              child: SearchBar(
                controller: _searchController,
                hintText: 'Buscar por título...', 
                hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
                leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
                backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (value) => _ejecutarBusqueda(), 
              ),
            )
          : const Text('EcoStay Admin', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: esDesktop ? 20.0 : 10.0),
            child: InkWell(
              onTap: () => _logout(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (esDesktop) ...[
                      Text(
                        widget.administrador.nombre, 
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 1, 
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                    ],
                    CircleAvatar(
                      backgroundColor: const Color(0xFF216A44),
                      backgroundImage: widget.administrador.imagenUrl != null && widget.administrador.imagenUrl!.isNotEmpty
                          ? NetworkImage(widget.administrador.imagenUrl!)
                          : null,
                      child: widget.administrador.imagenUrl == null || widget.administrador.imagenUrl!.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Drawer responsivo para vistas móviles/tablets
      drawer: !esDesktop 
        ? Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF216A44)),
                  accountName: Text(widget.administrador.nombre),
                  accountEmail: const Text("Administrador"),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: widget.administrador.imagenUrl != null && widget.administrador.imagenUrl!.isNotEmpty
                        ? NetworkImage(widget.administrador.imagenUrl!)
                        : null,
                    child: widget.administrador.imagenUrl == null || widget.administrador.imagenUrl!.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                ..._buildNavItems(context, isVertical: true),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  onTap: () => _logout(context),
                )
              ],
            ),
          )
        : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // Fila de botones de menú superior (solo se muestra en Escritorio)
          if (esDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: _buildNavItems(context),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Center(
                  // En lugar de un ancho fijo de 992, limitamos el ancho máximo conservando la estética centralizada en PC
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // BARRA DE FILTROS RESPONSIVA
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Input Buscar
                              SizedBox(
                                width: esDesktop ? 350 : double.infinity,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(color: const Color(0xFFF5F7F2), borderRadius: BorderRadius.circular(12)),
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
                              
                              // Input Presupuesto
                              SizedBox(
                                width: esDesktop ? 200 : double.infinity,
                                child: Container(
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
                                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Botón de más filtros
                              SizedBox(
                                width: esDesktop ? null : double.infinity,
                                child: OutlinedButton(
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
                              ),
                              
                              // Botón buscar definitivo
                              SizedBox(
                                width: esDesktop ? null : double.infinity,
                                child: ElevatedButton(
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
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 35),

                        // FUTURES Y CARDS ADAPTATIVAS (Uso de LayoutBuilder)
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
                                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                                ),
                              );
                            }

                            final listado = snapshot.data!;

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                // Determinamos cuántas columnas usar según el ancho disponible en el contenedor
                                int columnas = 1;
                                if (constraints.maxWidth > 900) {
                                  columnas = 3;
                                } else if (constraints.maxWidth > 600) {
                                  columnas = 2;
                                }

                                // Calculamos el ancho de cada tarjeta restando los espacios (spacing = 16)
                                double anchoTarjeta = (constraints.maxWidth - (16 * (columnas - 1))) / columnas;

                                return Wrap(
                                  spacing: 16, 
                                  runSpacing: 16,
                                  children: listado.map((publicacion) {
                                    return SizedBox(
                                      width: anchoTarjeta, 
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                            MaterialPageRoute(
                                              builder: (context) => PantallaPubAdmin(
                                                publicacion: publicacion,
                                                administrador: widget.administrador,
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
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFC2DC77), borderRadius: BorderRadius.circular(12)),
                  child: Text(rating, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(location, style: const TextStyle(color: Color(0xFF6E867A), fontSize: 14)),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
                Align(
                  alignment: Alignment.bottomRight,
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