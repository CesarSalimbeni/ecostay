import 'package:ecostay/models/administrador.dart';
import 'package:ecostay/pantallas/admin_home.dart';
import 'package:ecostay/pantallas/admin_moderacion.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AdminUsuarios extends StatelessWidget {
  final Administrador administrador;

  const AdminUsuarios({super.key, required this.administrador});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> usuariosMock = [
      {'id': 'U-001', 'nombre': 'María Gónzales', 'email': 'maria@correo.com', 'rol': 'Viajero', 'estado': 'Activo'},
      {'id': 'U-002', 'nombre': 'Carlos Méndez', 'email': 'carlos@correo.com', 'rol': 'Anfitrión', 'estado': 'Activo'},
      {'id': 'U-003', 'nombre': 'Miguel Angle', 'email': 'miguelangle@correo.com', 'rol': 'Anfitrión', 'estado': 'Activo'},
      {'id': 'U-004', 'nombre': 'Pedro Ruiz', 'email': 'pedro@correo.com', 'rol': 'Viajero', 'estado': 'Suspendido'},
      {'id': 'U-005', 'nombre': 'Luis Pérez', 'email': 'luis@correo.com', 'rol': 'Anfitrión', 'estado': 'Activo'},
    ];

    final size = MediaQuery.of(context).size;
    final fontSize = min(size.width * 0.11, size.height * 0.11).clamp(28.0, 96.0) as double;

    return Scaffold(backgroundColor: ColorPalette.bg,
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
        ),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 10.0),
            child: Text(administrador.nombre, overflow: TextOverflow.ellipsis, maxLines: 1, 
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(padding: const EdgeInsets.only(top: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeAdmin(administrador: administrador)),
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
                        MaterialPageRoute(builder: (context) => AdminModeracion(administrador: administrador),
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
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
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
                                child: ListView.separated(
                                  itemCount: usuariosMock.length,
                                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                                  itemBuilder: (context, index) {
                                    final user = usuariosMock[index];
                                    return _buildUsuarioRowItem(
                                      id: user['id'],
                                      nombre: user['nombre'],
                                      email: user['email'],
                                      rol: user['rol'],
                                      estado: user['estado'],
                                      brandGreen: const Color(0xFF216A44),
                                      darkRed: const Color(0xFF7A1C1C),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 15), // Spacing base baseline
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

  // --- NEW: Added missing table header widget method ---
  Widget _buildTableHeader(Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('ID', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18))),
          Expanded(flex: 2, child: Text('Nombre', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18))),
          Expanded(flex: 3, child: Text('Email', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18))),
          Expanded(flex: 2, child: Text('Rol', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18))),
          Expanded(flex: 2, child: Center(child: Text('Estado', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)))),
          Expanded(flex: 2, child: Center(child: Text('Acciones', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)))),
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
  }) {
    bool isSuspended = estado == 'Suspendido';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(id, style: const TextStyle(fontSize: 16, color: Colors.black87))),
          Expanded(flex: 2, child: Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, 
          color: Colors.black))),
          Expanded(flex: 3, child: Text(email, style: const TextStyle(fontSize: 16, color: Colors.black54))),
          Expanded(flex: 2, child: Text(rol, style: const TextStyle(fontSize: 16, color: Colors.black87))),
          
          Expanded(flex: 2,
            child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(color: isSuspended ? darkRed : const Color(0xFFE2E6E2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(estado,style: TextStyle(
                    color: isSuspended ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500, fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          
          // Acciones Icons (Toggle Block Status & View Profile Details)
          Expanded(flex: 2,
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    isSuspended ? Icons.check_circle : Icons.cancel,
                    color: isSuspended ? brandGreen : darkRed, size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
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