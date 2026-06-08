import 'ipago_provider.dart';

// Clase que implementa la interfaz IPagoProvider
class PaypalService implements IPagoProvider {
  late String _apiKey;

  // Constructor para inicializar la clave API
  PaypalService({required String apiKey}){
    _apiKey = apiKey;
  }
   
  // Método para validar las credenciales
  void validarCredenciales() {
    print("Revisando conexión con PayPal...");

    if (_apiKey != "") {
      print("Clave API válida: $_apiKey");
    } else {
      print("ERROR: No se ha proporcionado una clave API.");
    }
  }

  @override
  bool procesarPago(double monto) {
    // Validar credenciales antes de procesar el pago
    validarCredenciales();

    print("Procesando el pago...");
    print("Monto total del paquete: \$${monto}");

    // Simulación de un pago 
    bool pagoExitoso = true;
      print("Pago realizado con éxito.");

    return pagoExitoso;
  }

  @override
  bool procesarReembolso(String idTransaccion) {
    print("Procesando reembolso para la transacción: $idTransaccion");

    // Simulación de un reembolso 
    bool reembolsoExitoso = true;
      print("Reembolso completado con éxito.");
  
    return reembolsoExitoso;
  }
}
