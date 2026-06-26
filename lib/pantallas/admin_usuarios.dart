import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/admin_explorar.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_perfil.dart';
import 'package:ecostay/pantallas/admin_perfil_usuario.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/pantallas/estilo.dart';

class AdminUsuarios extends StatefulWidget {
  final Administrador administrador;

  const AdminUsuarios({super.key, required this.administrador});

  @override
  State<AdminUsuarios> createState() => _AdminUsuariosState();
}

class _AdminUsuariosState extends State<AdminUsuarios> {
  final GestionUsuario _gestionUsuario = GestionUsuario();
  List<Usuario> _usuarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    try {
      List<Usuario> lista = await _gestionUsuario.buscarUsuariosPorNombre(null);
      if (mounted) {
        setState(() {
          _usuarios = lista;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuarios: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminExplorar(administrador: widget.administrador)));
        },
        icon: Icon(Icons.search, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Explorar', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
      TextButton.icon(
        onPressed: null, // Pantalla actual
        icon: Icon(Icons.person_add_outlined, color: const Color(0xFF216A44), size: isVertical ? 24 : 28),
        label: Text('Usuarios', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize, fontWeight: FontWeight.w900)),
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
        label: Text('Perfil', style: TextStyle(color: const Color(0xFF216A44), fontSize: fontSize)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double anchoPantalla = MediaQuery.of(context).size.width;
    bool esDesktop = anchoPantalla > 950;

    List<Viajero> viajeros = _usuarios.whereType<Viajero>().toList();
    List<PrestadorServicio> prestadores = _usuarios.whereType<PrestadorServicio>().toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ColorPalette.bg,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          toolbarHeight: esDesktop ? 90 : 70,
          centerTitle: esDesktop ? true : false,
          leading: esDesktop 
            ? Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
              )
            : null,
          title: esDesktop
            ? SizedBox(
                width: 400,
                child: SearchBar(
                  hintText: 'Buscar...',
                  hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
                  leading: const Icon(Icons.search, color: Color(0xFF526F75)),
                  backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
                  elevation: const WidgetStatePropertyAll(0),
                ),
              )
            : const Text('Gestión de Usuarios', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            if (esDesktop)
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildNavItems(context),
                ),
              ),
            
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF216A44)))
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: esDesktop ? 40.0 : 16.0, 
                        vertical: 10.0
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TÍTULO DE LA SECCIÓN
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  'Usuarios Registrados',
                                  style: TextStyle(
                                    fontSize: esDesktop ? 35 : 26,
                                    fontFamily: 'Idiqlat',
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // CONTROL DE PESTAÑAS RESPONSIVO
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const TabBar(
                                  labelColor: Color(0xFF216A44),
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: Color(0xFF216A44),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  tabs: [
                                    Tab(child: Text('Viajeros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                    Tab(child: Text('Prestadores de Servicio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // LISTADO DINÁMICO CONTENIDO DE TABS
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildListaUsuarios(viajeros, anchoPantalla),
                                    _buildListaUsuarios(prestadores, anchoPantalla),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaUsuarios(List<Usuario> lista, double anchoPantalla) {
    if (lista.isEmpty) {
      return const Center(
        child: Text(
          'No hay usuarios registrados en esta categoría.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final usuario = lista[index];
        bool esViajero = usuario is Viajero;
        bool estaSuspendido = usuario.suspendido;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: EdgeInsets.all(anchoPantalla > 600 ? 20.0 : 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Flex(
            direction: anchoPantalla > 650 ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: anchoPantalla > 650 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              // AVATAR DEL USUARIO
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF38664D),
                child: Text(
                  usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: anchoPantalla > 650 ? 20 : 0, height: anchoPantalla > 650 ? 0 : 15),
              
              // INFORMACIÓN DEL USUARIO
              Expanded(
                flex: anchoPantalla > 650 ? 1 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            usuario.nombre,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (estaSuspendido) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB72E2E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Suspendido',
                              style: TextStyle(color: Color(0xFFB72E2E), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      esViajero ? usuario.email : 'RIF: ${(usuario as PrestadorServicio).rif}',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF6E867A)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: anchoPantalla > 650 ? 20 : 0, height: anchoPantalla > 650 ? 0 : 20),

              // ACCIONES (BOTÓN VER PERFIL)
              SizedBox(
                width: anchoPantalla > 650 ? null : double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF216A44),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PerfilUsuario(
                          usuarioSeleccionado: usuario,
                          administrador: widget.administrador,
                        ),
                      ),
                    ).then((_) => _cargarUsuarios()); // Recarga la lista al volver atrás por si cambió el estado de suspensión
                  },
                  icon: const Icon(Icons.visibility_outlined, color: Colors.white, size: 20),
                  label: const Text(
                    'Ver Perfil',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}