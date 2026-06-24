import 'dart:math';
import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/models/usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/admin_usuarios.dart';
import 'package:ecostay/pantallas/estilo.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.usuarioSeleccionado is Viajero) {
      _rolFormateado = 'Viajero';
    } else if (widget.usuarioSeleccionado is PrestadorServicio) {
      _rolFormateado = 'Anfitrión';
    } else {
      _rolFormateado = 'Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: AppBar(backgroundColor: const Color(0xFFFFFFFF), toolbarHeight: 90, leadingWidth: 120, centerTitle: true,
        leading: Padding(padding: const EdgeInsets.only(left: 40.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
        ),
        title: SearchBar(
          hintText: 'Buscar...', 
          hintStyle: WidgetStateProperty.all(const TextStyle(color: Color(0xFF526F75))),
          leading: const Icon(Icons.search, color: Color(0xFF526F75)), 
          backgroundColor: WidgetStateProperty.all(ColorPalette.bg),
          elevation: const WidgetStatePropertyAll(0),
        ),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: Text(widget.administrador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
              style: const TextStyle(fontSize: 20)),
          ),
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: const CircleAvatar(backgroundColor: Color(0xFF216A44),
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(padding: const EdgeInsets.only(top: 15, bottom: 15),
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
                  onPressed: () {
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => AdminUsuarios(administrador: widget.administrador)),
                    );
                  }, 
                  icon: const Icon(Icons.person_add_outlined, color: Color(0xFF216A44), size: 28),
                  label: const Text('Usuarios', style: TextStyle(color: Color(0xFF216A44), fontSize: 25)),
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
          
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(padding: const EdgeInsets.only(bottom: 40, top: 20),
                  child: SizedBox(width: 1240, 
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Perfil de Usuario', style: TextStyle(color: Colors.black, fontFamily: 'Idiqlat', 
                          fontWeight: FontWeight.w800, fontSize: 30),
                        ),
                        const SizedBox(height: 24),
                        Row(crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 4,
                              child: Container(padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  children: [
                                    Container(width: 130, height: 130, decoration: const BoxDecoration(
                                      color: Color(0xFF38664D), shape: BoxShape.circle,),
                                      child: const Icon(Icons.person, color: Colors.white, size: 70),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      widget.usuarioSeleccionado.nombre,
                                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, 
                                      fontFamily: 'Idiqlat', color: Colors.black, fontWeight: FontWeight.w800),
                                    ),
                                    Text(_rolFormateado, style: const TextStyle(color: Color(0xFF6E867A), fontSize: 18)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(flex: 6,
                              child: Container(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildCamposSegunRol(),
                                ),
                              ),
                            ),
                          ],
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

  List<Widget> _buildCamposSegunRol() {
    final user = widget.usuarioSeleccionado;

    if (user is Viajero) {
      return [
        _buildProfileDisplayField('Nombre', user.nombre),
        _buildDivider(),
        _buildProfileDisplayField('Correo', user.email),
        _buildDivider(),
        _buildProfileDisplayField('Teléfono', user.telefono),
        _buildDivider(),
        _buildProfileDisplayField('Cédula', user.cedula),
        _buildDivider(),
        _buildProfileDisplayField('Ciudad', user.ciudad),
      ];
    } else if (user is PrestadorServicio) {
      return [
        _buildProfileDisplayField('Responsable', user.nombre),
        _buildDivider(),
        _buildProfileDisplayField('Correo', user.email),
        _buildDivider(),
        _buildProfileDisplayField('Teléfono', user.telefono),
        _buildDivider(),
        _buildProfileDisplayField('Rif', user.rif),
        _buildDivider(),
        _buildProfileDisplayField('Dirección Fiscal', user.direccion),
        _buildDivider(),
        _buildProfileDisplayField('Cuenta PayPal', user.cuentaPayPal),
      ];
    }
    
    return [_buildProfileDisplayField('Nombre', user.nombre)];
  }

  Widget _buildProfileDisplayField(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 4, 
            child: Text(label, style: const TextStyle(color: Color(0xFF38664D), fontSize: 18, 
            fontWeight: FontWeight.w500)),
          ),
          Expanded(flex: 6, 
            child: TextFormField(
              initialValue: value.isEmpty ? 'No provisto' : value, 
              readOnly: true,
              style: const TextStyle(color: Colors.black87, fontSize: 18),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: Color(0xFFEBEBEB), thickness: 1.5),
    );
  }
}