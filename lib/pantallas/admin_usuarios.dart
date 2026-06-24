import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_perfil_usuario.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AdminUsuarios extends StatefulWidget {
  final Administrador administrador;

  const AdminUsuarios({super.key, required this.administrador});

  @override
  State<AdminUsuarios> createState() => _AdminUsuariosState();
}

class _AdminUsuariosState extends State<AdminUsuarios> {
  final GestionUsuario _gestionUsuario = GestionUsuario();
  List<Usuario> _usuariosReales = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios({String? nombre}) async {
    setState(() => _cargando = true);
    try {
      List<Usuario> todos = await _gestionUsuario.buscarUsuariosPorNombre(nombre);
      
      setState(() {
        _usuariosReales = todos.where((u) => u.id != widget.administrador.id).toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar usuarios: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
        ),
        title: SearchBar(
          hintText: 'Buscar...', 
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
          onChanged: (value) {
            _cargarUsuarios(nombre: value.isEmpty ? null : value);
          },
        ),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: Text(widget.administrador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
            style: const TextStyle(fontSize: 20),
            ),
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
        children: [Padding(padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeAdmin(administrador: widget.administrador)),
                    );
                  }, 
                  icon: const Icon(Icons.dns, color: Color(0xFF216A44), size: 28),
                  label: const Text('Dashboard', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,)),
                ),
                TextButton.icon(
                  onPressed: null, 
                  icon: const Icon(Icons.person_add_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Usuarios', style: TextStyle(color: Color(0xFF216A44), fontSize: 25,
                  fontWeight: FontWeight.w900)),
                ),
                TextButton.icon(
                  onPressed:() {
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => AdminModeracion(administrador: widget.administrador),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Moderación', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
                ),
              ],
            ),
          ),
          Center(
              child: Padding(padding: const EdgeInsets.only(top: 50),
                child: SizedBox(width: 1240, height: 520, 
                  child: Padding(padding: const EdgeInsets.all(30.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Usuarios', style: TextStyle(fontSize: 32, 
                          fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 20),
                        
                        Expanded(
                          child: Container(width: double.infinity, decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.shade300, width: 1),),
                            child: Column(
                            children: [_buildTableHeader(const Color(0xFFF4F6F4), const Color(0xFF526F75)),
                              Expanded(
                                child: _cargando 
                                ? const Center(child: CircularProgressIndicator(color: Color(0xFF216A44)))
                                : _usuariosReales.isEmpty 
                                  ? const Center(child: Text('No se encontraron usuarios.', style: TextStyle(fontSize: 18, color: Colors.grey)))
                                  : ListView.separated(
                                    itemCount: _usuariosReales.length,
                                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                                    itemBuilder: (context, index) {
                                      final user = _usuariosReales[index];
                                      
                                      String rolFormateado = user is Administrador ? 'Admin' : (user is Viajero ? 'Viajero' : 'Anfitrión');
                                      String estadoFormateado = user.suspendido ? 'Suspendido' : 'Activo';

                                      return _buildUsuarioRowItem(
                                        id: user.id.substring(0, min(5, user.id.length)),
                                        nombre: user.nombre,
                                        email: user.email,
                                        rol: rolFormateado,
                                        estado: estadoFormateado,
                                        brandGreen: const Color(0xFF216A44),
                                        darkRed: const Color(0xFF7A1C1C),
                                        onVerPerfil: () {
                                          if (user is Viajero || user is PrestadorServicio) {
                                            Navigator.pushReplacement(
                                              context, MaterialPageRoute(
                                                builder: (context) => PerfilUsuario(
                                                  usuarioSeleccionado: user, administrador: widget.administrador,
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('No es posible visualizar este perfil.')),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                              ),
                              const SizedBox(height: 15), 
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTableHeader(Color bgColor, Color textColor) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      decoration: BoxDecoration(color: bgColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('ID', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18))),
          Expanded(flex: 2, child: Text('Nombre', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, 
            fontSize: 18))),
          Expanded(flex: 3, child: Text('Email', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, 
            fontSize: 18))),
          Expanded(flex: 2, child: Text('Rol', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, 
            fontSize: 18))),
          Expanded(flex: 2, child: Center(child: Text('Estado', style: TextStyle(color: textColor, 
            fontWeight: FontWeight.bold, fontSize: 18)))),
          Expanded(flex: 2, child: Center(child: Text('Acciones', style: TextStyle(color: textColor, 
            fontWeight: FontWeight.bold, fontSize: 18)))),
        ],
      ),
    );
  }

  Widget _buildUsuarioRowItem({
    required String id,
    required String nombre,
    required String email,
    required String rol,
    required String estado,
    required Color brandGreen,
    required Color darkRed,
    required VoidCallback onVerPerfil,
  }) {
    bool isSuspended = estado == 'Suspendido';

    return Padding(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(id, style: const TextStyle(fontSize: 16, color: Colors.black87))),
          Expanded(flex: 2, child: Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, 
          color: Colors.black))),
          Expanded(flex: 3, child: Text(email, style: const TextStyle(fontSize: 16, color: Colors.black54))),
          Expanded(flex: 2, child: Text(rol, style: const TextStyle(fontSize: 16, color: Colors.black87))),
          
          Expanded(flex: 2,
            child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(color: isSuspended ? darkRed : const Color(0xFFE2E6E2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(estado,style: TextStyle(color: isSuspended ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500, fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(flex: 2,
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(isSuspended ? Icons.check_circle : Icons.cancel,
                    color: isSuspended ? brandGreen : darkRed, size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onVerPerfil,
                  icon: const Icon(Icons.visibility_outlined, color: Colors.black87, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}