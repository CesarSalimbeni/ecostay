import 'package:flutter/material.dart';

class PaypalService {
  String clientId;
  String secretKey;

  bool sandboxMode = true;
  bool pagoExitoso = false;
  int intentosDePago = 0;

  PaypalService({required this.clientId, required this.secretKey});

  bool validarMonto(double monto) {
    if (monto <= 0) {
      print("Error: el monto no puede ser cero o negativo");
      return false;
    }
    return true;
  }

  String armarTextoFactura(String idReserva, double monto) {
    String montoTexto = monto.toStringAsFixed(2);
    return "Factura: $idReserva\nTotal: \$$montoTexto";
  }

  // FUNCIÓN PRINCIPAL SIMULADA CON LOGIN
  void iniciarFlujoPaypal({
    required BuildContext context,
    required double monto,
    required String idReserva,
    required String tituloPublicacion,
    required Function(bool) onResultado,
  }) {
    if (!validarMonto(monto)) {
      pagoExitoso = false;
      onResultado(false);
      return;
    }

    intentosDePago++;
    print("Abriendo pasarela simulada para la reserva: $idReserva");

    // Mostramos una mini pantalla desde abajo (ModalBottomSheet) que simula PayPal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que suba cuando se abre el teclado
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _PaypalMockLoginSheet(
          monto: monto,
          tituloPublicacion: tituloPublicacion,
          onLoginSuccess: () {
            // Si el login fue "exitoso", marcamos como aprobado y devolvemos true
            pagoExitoso = true;
            onResultado(true);
          },
          onCancel: () {
            pagoExitoso = false;
            onResultado(false);
          },
        );
      },
    );
  }

  void mostrarResumen() {
    print("---- Resumen del pago SIMULADO ----");
    print("Intentos realizados: $intentosDePago");
    print("Resultado: ${pagoExitoso ? "el pago fue exitoso" : "el pago no se completó"}");
    print("-----------------------------------");
  }
}

// COMPONENTE VISUAL INTERNO DEL LOGIN SIMULADO
class _PaypalMockLoginSheet extends StatefulWidget {
  final double monto;
  final String tituloPublicacion;
  final VoidCallback onLoginSuccess;
  final VoidCallback onCancel;

  const _PaypalMockLoginSheet({
    required this.monto,
    required this.tituloPublicacion,
    required this.onLoginSuccess,
    required this.onCancel,
  });

  @override
  State<_PaypalMockLoginSheet> createState() => _PaypalMockLoginSheetState();
}

class _PaypalMockLoginSheetState extends State<_PaypalMockLoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;

  void _procesarLoginFalso() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _cargando = true;
      });

      // Simulamos la verificación de credenciales y el cobro (2 segundos)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context); // Cierra el BottomSheet
          widget.onLoginSuccess(); // Dispara el éxito
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ajuste para que el teclado no tape el diseño
    final paddingBottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, paddingBottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado simulado de PayPal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "PayPal",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF003087), // Azul corporativo PayPal
                  ),
                ),
                Text(
                  "\$${widget.monto.toStringAsFixed(2)} USD",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            const Divider(height: 30),
            
            if (_cargando) ...[
              // Estado de carga si ya presionó pagar
              const SizedBox(height: 40),
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003087)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Procesando pago de forma segura...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
            ] else ...[
              // Formulario de inicio de sesión
              Text(
                "Pagar con: ${widget.tituloPublicacion}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico Sandbox",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, ingresa un correo de prueba";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, ingresa una contraseña cualquiera";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Botón de Iniciar Sesión / Pagar
              ElevatedButton(
                onPressed: _procesarLoginFalso,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC439), // Amarillo PayPal
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Iniciar sesión y Pagar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),
              
              // Botón Cancelar
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onCancel();
                },
                child: const Text("Cancelar y volver a la app", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}