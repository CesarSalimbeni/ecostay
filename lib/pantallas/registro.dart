import 'package:ecostay/pantallas/anf_home.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/viaj_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/usuario.dart';
import 'package:ecostay/models/prestador_servicio.dart';

enum UserRole { viajero, anfitrion }

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}
class _PantallaRegistroState extends State<PantallaRegistro> {
  UserRole _selectedRole = UserRole.viajero;
  final GestionUsuario _gestionUsuario = GestionUsuario();
  bool _isLoading = false; 

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _cedulaCtrl = TextEditingController();
  final TextEditingController _rifCtrl = TextEditingController();
  final TextEditingController _paypalCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    _passCtrl.dispose();
    _cedulaCtrl.dispose();
    _rifCtrl.dispose();
    _paypalCtrl.dispose();
    super.dispose();
  }
  
  Future<void> _crearCuenta() async {
    final isViajero = _selectedRole == UserRole.viajero;
    final emailText = _correoCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Validación estricta del dominio @correo.unimet.edu.ve solo para viajeros
    if (isViajero) {
      final unimetRegex = RegExp(r'^[\w-\.]+@correo\.unimet\.edu\.ve$');
      if (!unimetRegex.hasMatch(emailText.toLowerCase())) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Acceso denegado: Los viajeros deben usar un correo institucional @correo.unimet.edu.ve'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final String rolBackend = isViajero ? 'cliente' : 'host';

      Map<String, dynamic> extras = isViajero
          ? {
              'telefono': _telefonoCtrl.text.trim(),
              'cedula': _cedulaCtrl.text.trim(),
              'direccion': _direccionCtrl.text.trim(), // Se usa para Ciudad
              'suspendido': false,
            }
          : {
              'telefono': _telefonoCtrl.text.trim(),
              'direccion': _direccionCtrl.text.trim(),
              'rif': _rifCtrl.text.trim(),
              'cuentaPayPal': _paypalCtrl.text.trim(),
              'suspendido': false,
            };

      await _gestionUsuario.registrarUsuario(
        email: emailText,
        password: _passCtrl.text.trim(),
        nombre: _nombreCtrl.text.trim(),
        rol: rolBackend,
        datosAdicionales: extras,
      );

      if (!mounted) return;

      String uid = FirebaseAuth.instance.currentUser!.uid;
      Usuario usuarioCreado;

      if (isViajero) {
        usuarioCreado = Viajero(
          id: uid,
          nombre: _nombreCtrl.text.trim(),
          email: emailText,
          fechaRegistro: DateTime.now(),
          telefono: _telefonoCtrl.text.trim(),
          cedula: _cedulaCtrl.text.trim(),
          ciudad: _direccionCtrl.text.trim(),
          suspendido: false,
          historialReservas: [],
        );
      } else {
        usuarioCreado = PrestadorServicio(
          id: uid,
          nombre: _nombreCtrl.text.trim(),
          email: emailText,
          fechaRegistro: DateTime.now(),
          rif: _rifCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
          cuentaPayPal: _paypalCtrl.text.trim(),
          suspendido: false,
          estadisticas: [],
        );
      }

      if (usuarioCreado is Viajero) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeViajero(viajero: usuarioCreado as Viajero),
          ),
        );
      } else if (usuarioCreado is PrestadorServicio) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                HomeAnfitrion(prestador: usuarioCreado as PrestadorServicio),
          ),
        );
      }

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('¡Cuenta creada con éxito!')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isViajero = _selectedRole == UserRole.viajero;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;

    Widget buildRoleButton({
      required bool selected,
      required VoidCallback onPressed,
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(20.0),
            backgroundColor: selected
                ? const Color(0xFF216A44).withValues(alpha: 0.1)
                : Colors.transparent,
            side: BorderSide(
              color: selected ? const Color(0xFF216A44) : Colors.grey.shade400,
              width: selected ? 2.0 : 1.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            alignment: AlignmentDirectional.centerStart,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF216A44), size: 40),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Idiqlat',
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF8E8E93)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 32, vertical: 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 24 : 45, vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Flexible(
                          child: Text(
                            'Crea tu cuenta de Ecostay',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Idiqlat',
                              color: Colors.black,
                              fontSize: isCompact ? 24 : 30,
                            ),
                          ),
                        ),
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/logo.jpg'),
                          radius: 34,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  isCompact
                      ? Column(
                          children: [
                            buildRoleButton(
                              selected: isViajero,
                              onPressed: () => setState(() => _selectedRole = UserRole.viajero),
                              icon: Icons.air,
                              title: 'Soy Viajero',
                              subtitle: 'Quiero descubrir destinos.',
                            ),
                            const SizedBox(height: 12),
                            buildRoleButton(
                              selected: !isViajero,
                              onPressed: () => setState(() => _selectedRole = UserRole.anfitrion),
                              icon: Icons.home_outlined,
                              title: 'Soy Anfitrión',
                              subtitle: 'Ofrezco servicios turísticos',
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: buildRoleButton(
                                selected: isViajero,
                                onPressed: () => setState(() => _selectedRole = UserRole.viajero),
                                icon: Icons.air,
                                title: 'Soy Viajero',
                                subtitle: 'Quiero descubrir destinos.',
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: buildRoleButton(
                                selected: !isViajero,
                                onPressed: () => setState(() => _selectedRole = UserRole.anfitrion),
                                icon: Icons.home_outlined,
                                title: 'Soy Anfitrión',
                                subtitle: 'Ofrezco servicios turísticos',
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),
                  isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldColumn(
                              label: 'Nombre',
                              child: TextField(
                                controller: _nombreCtrl,
                                keyboardType: TextInputType.name,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]')),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: ColorPalette.bg,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFieldColumn(
                              label: 'Teléfono',
                              child: TextField(
                                controller: _telefonoCtrl,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'Teléfono',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: ColorPalette.bg,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildFieldColumn(
                                label: 'Nombre',
                                child: TextField(
                                  controller: _nombreCtrl,
                                  keyboardType: TextInputType.name,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]')),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Nombre',
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: ColorPalette.bg,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildFieldColumn(
                                label: 'Teléfono',
                                child: TextField(
                                  controller: _telefonoCtrl,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    labelText: 'Teléfono',
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: ColorPalette.bg,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 20),
                  _buildFieldColumn(
                    label: 'Correo electrónico',
                    child: TextField(
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'tu@correo.com',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: ColorPalette.bg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldColumn(
                              label: isViajero ? 'Ciudad' : 'Dirección Fiscal',
                              child: TextField(
                                controller: _direccionCtrl,
                                decoration: InputDecoration(
                                  labelText: isViajero ? 'Ciudad Real, País' : 'Calle Real, Estado, País',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: ColorPalette.bg,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFieldColumn(
                              label: 'Contraseña',
                              child: TextField(
                                controller: _passCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: ColorPalette.bg,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildFieldColumn(
                                label: isViajero ? 'Ciudad' : 'Dirección Fiscal',
                                child: TextField(
                                  controller: _direccionCtrl,
                                  decoration: InputDecoration(
                                    labelText: isViajero ? 'Ciudad Real, País' : 'Calle Real, Estado, País',
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: ColorPalette.bg,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildFieldColumn(
                                label: 'Contraseña',
                                child: TextField(
                                  controller: _passCtrl,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: ColorPalette.bg,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 20),
                  if (isViajero)
                    _buildFieldColumn(
                      label: 'Cédula',
                      child: TextField(
                        controller: _cedulaCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: '55555555',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: ColorPalette.bg,
                        ),
                      ),
                    )
                  else
                    isCompact
                        ? Column(
                            children: [
                              _buildFieldColumn(
                                label: 'Rif',
                                child: TextField(
                                  controller: _rifCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'J-555555-5',
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: ColorPalette.bg,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFieldColumn(
                                label: 'Cuenta PayPal',
                                child: TextField(
                                  controller: _paypalCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'tu.cuenta@paypal.com',
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: ColorPalette.bg,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildFieldColumn(
                                  label: 'Rif',
                                  child: TextField(
                                    controller: _rifCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'J-555555-5',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: ColorPalette.bg,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildFieldColumn(
                                  label: 'Cuenta PayPal',
                                  child: TextField(
                                    controller: _paypalCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'tu.cuenta@paypal.com',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: ColorPalette.bg,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _crearCuenta,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF216A44),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Crea tu cuenta de Ecostay',
                            style: TextStyle(fontSize: 16, fontFamily: 'Idiqlat'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldColumn({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}