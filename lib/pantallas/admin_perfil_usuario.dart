import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/admin_explorar.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_explorar.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_perfil.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart';
import 'package:ecostay/pantallas/admin_perfil.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:flutter/material.dart';

class PerfilUsuario extends StatefulWidget {
  final Usuario usuarioSeleccionado;
  final Administrador administrador;

  const PerfilUsuario({
    super.key, 
    required this.usuarioSeleccionado, 
    required this.administrador,
  });

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  late String _rolFormateado;
  final GestionUsuario _gestionUsuario = GestionUsuario();
  late bool _estaSuspendido;

  @override
  void initState() {
    super.initState();
    _estaSuspendido = widget.usuarioSeleccionado.suspendido;
    if (widget.usuarioSeleccionado is Viajero) {
      _rolFormateado = 'Viajero';
    } else if (widget.usuarioSeleccionado is PrestadorServicio) {
      _rolFormateado = 'Prestador de Servicio';
    } else {
      _rolFormateado = 'Usuario';
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

  void _cambiarEstadoSuspension() async {
    final nuevoEstado = !_estaSuspendido;
    final accion = nuevoEstado ? 'suspender' : 'activar';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Confirmar acción?'),
        content: Text('¿Está seguro de que desea $accion a este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: nuevoEstado ? const Color(0xFFB72E2E) : const Color(0xFF216A44),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _gestionUsuario.cambiarEstadoSuspension(
                  widget.usuarioSeleccionado.id,
                  nuevoEstado,
                );
                setState(() {
                  _estaSuspendido = nuevoEstado;
                  widget.usuarioSeleccionado.suspendido = nuevoEstado;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Usuario ${nuevoEstado ? "suspendido" : "activado"} con éxito.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cambiar estado: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: widget.administrador)));
        },
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

    return Scaffold(
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
          : const Text('Detalle de Usuario', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
              padding: const EdgeInsets.only(top: 15, bottom: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildNavItems(context),
              ),
            ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: esDesktop ? 40.0 : 16.0, 
                vertical: 20.0
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Container(
                    padding: EdgeInsets.all(anchoPantalla > 600 ? 40.0 : 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BOTÓN VOLVER ATRÁS
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF38664D)),
                          label: const Text('Volver a usuarios', style: TextStyle(color: Color(0xFF38664D), fontSize: 16)),
                        ),
                        const SizedBox(height: 20),

                        // CABECERA DEL PERFIL (FLEX ADAPTATIVO)
                        Flex(
                          direction: anchoPantalla > 600 ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: anchoPantalla > 600 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFF38664D),
                              child: Text(
                                widget.usuarioSeleccionado.nombre.isNotEmpty 
                                    ? widget.usuarioSeleccionado.nombre[0].toUpperCase() 
                                    : 'U',
                                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: anchoPantalla > 600 ? 25 : 0, height: anchoPantalla > 600 ? 0 : 15),
                            Expanded(
                              flex: anchoPantalla > 600 ? 1 : 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.usuarioSeleccionado.nombre,
                                    style: TextStyle(
                                      fontSize: anchoPantalla > 600 ? 32 : 24, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.black, 
                                      fontFamily: 'Idiqlat'
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _rolFormateado,
                                    style: const TextStyle(fontSize: 18, color: Color(0xFF6E867A), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: anchoPantalla > 600 ? 15 : 0, height: anchoPantalla > 600 ? 0 : 20),
                            
                            // BOTÓN DE ACCIÓN CORPORATIVA (SUSPENDER O ACTIVAR)
                            SizedBox(
                              width: anchoPantalla > 600 ? null : double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _estaSuspendido ? const Color(0xFF216A44) : const Color(0xFFB72E2E),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 0,
                                ),
                                onPressed: _cambiarEstadoSuspension,
                                icon: Icon(_estaSuspendido ? Icons.check_circle_outline : Icons.gavel, color: Colors.white),
                                label: Text(
                                  _estaSuspendido ? 'Activar Usuario' : 'Suspender Usuario',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        const Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
                        const SizedBox(height: 20),

                        // CAMPOS DE DATOS DINÁMICOS POR ROL
                        ..._buildCamposPorRol(widget.usuarioSeleccionado, anchoPantalla),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCamposPorRol(Usuario user, double anchoPantalla) {
    if (user is Viajero) {
      return [
        _buildProfileDisplayField('Cédula de Identidad', user.cedula, anchoPantalla),
        _buildDivider(),
        _buildProfileDisplayField('Correo Electrónico', user.email, anchoPantalla),
        _buildDivider(),
        _buildProfileDisplayField('Teléfono de Contacto', user.telefono, anchoPantalla),
        _buildDivider(),
        _buildProfileDisplayField('Ciudad de Origen', user.ciudad.isEmpty ? 'No provisto' : user.ciudad, anchoPantalla),
      ];
    } else if (user is PrestadorServicio) {
      return [
        _buildProfileDisplayField('Nombre de la Empresa / Registro', user.nombre, anchoPantalla),
        _buildDivider(),
        _buildProfileDisplayField('Correo Electrónico Corporativo', user.email, anchoPantalla),
        _buildDivider(),
        _buildProfileDisplayField('Teléfono', user.telefono, anchoPantalla),
        _buildDivider(),
        _buildProfileDisplayField('RIF / Registro Fiscal', user.rif, anchoPantalla),
        _buildDivider(),
        _buildProfileDisplayField('Dirección Fiscal', user.direccion, anchoPantalla),
        _buildDivider(),
        _buildProfileDisplayField('Cuenta de Pagos (PayPal)', user.cuentaPayPal, anchoPantalla),
      ];
    }
    
    return [_buildProfileDisplayField('Nombre Completo', user.nombre, anchoPantalla)];
  }

  Widget _buildProfileDisplayField(String label, String value, double anchoPantalla) {
    bool usarLayoutHorizontal = anchoPantalla > 550;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Flex(
        direction: usarLayoutHorizontal ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: usarLayoutHorizontal ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: usarLayoutHorizontal ? 260 : double.infinity,
            child: Text(
              label, 
              style: const TextStyle(color: Color(0xFF38664D), fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          if (!usarLayoutHorizontal) const SizedBox(height: 4),
          Expanded(
            flex: usarLayoutHorizontal ? 1 : 0,
            child: TextFormField(
              initialValue: value.isEmpty ? 'No provisto' : value, 
              readOnly: true,
              style: const TextStyle(color: Colors.black87, fontSize: 17),
              decoration: const InputDecoration(
                border: InputBorder.none, 
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFFF0F2EE), thickness: 1.0);
  }
}