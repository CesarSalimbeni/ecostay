import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

class PaypalService {
  String clientId;
  String secretKey;

  // Esto lo dejo en true mientras estoy probando (modo sandbox = modo de pruebas)
  bool sandboxMode = true;

  // Aqui guardo si el pago salio bien o mal, para poder revisarlo despues
  bool pagoExitoso = false;

  // Contador para saber cuantas veces se intento procesar un pago
  int intentosDePago = 0;

  // Constructor, le pido clientId y secretKey
  PaypalService({required this.clientId, required this.secretKey});

  // Revisa si el monto es valido antes de cobrar
  bool validarMonto(double monto) {
    if (monto <= 0) {
      print("Error: el monto no puede ser cero o negativo");
      return false;
    } else {
      print("El monto es valido: \$${monto}");
      return true;
    }
  }

  // Arma el texto que se muestra en pantalla con la factura
  String armarTextoFactura(String idReserva, double monto) {
    String montoTexto = monto.toStringAsFixed(2);
    String texto = "Factura: " + idReserva + "\nTotal: \$" + montoTexto;
    return texto;
  }

  // Arma la lista de "transactions" en formato Map, como lo pide
  // este paquete
  List<Map<String, dynamic>> armarTransaccion(
    double monto,
    String tituloPublicacion,
  ) {
    String montoTexto = monto.toStringAsFixed(2);

    List<Map<String, dynamic>> transaccion = [
      {
        "amount": {
          "total": montoTexto,
          "currency": "USD",
          "details": {
            "subtotal": montoTexto,
            "shipping": '0',
            "shipping_discount": 0,
          }
        },
        "description": tituloPublicacion,
      }
    ];

    return transaccion;
  }

  // Funcion principal: abre la pantalla real de pago del paquete
  void iniciarFlujoPaypal({
    required BuildContext context,
    required double monto,
    required String idReserva,
    required String tituloPublicacion,
    required Function(bool) onResultado,
  }) {
    bool esValido = validarMonto(monto);

    if (esValido == false) {
      onResultado(false);
      return;
    }

    intentosDePago = intentosDePago + 1;
    print("Intento numero $intentosDePago de procesar pago");

    List<Map<String, dynamic>> miTransaccion =
        armarTransaccion(monto, tituloPublicacion);

    // OJO: este paquete NO tiene returnURL ni cancelURL.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: sandboxMode,
          clientId: clientId,
          secretKey: secretKey,
          transactions: miTransaccion,
          note: "Gracias por tu compra, factura: $idReserva",

          // Esto se llama cuando el pago SI funciono
          onSuccess: (Map params) async {
            print("El pago se realizo con exito: $params");
            pagoExitoso = true;
            Navigator.pop(context);
            onResultado(true);
          },

          // Esto se llama cuando hubo un ERROR en el pago
          onError: (error) {
            print("El pago fallo: $error");
            pagoExitoso = false;
            Navigator.pop(context);
            onResultado(false);
          },

          // Esto se llama si el usuario CANCELA el pago el mismo
          onCancel: () {
            print("El usuario cancelo el pago");
            pagoExitoso = false;
            Navigator.pop(context);
            onResultado(false);
          },
        ),
      ),
    );
  }

  // Imprime en consola un resumen del ultimo pago
  void mostrarResumen() {
    print("---- Resumen del pago ----");
    print("Intentos realizados: $intentosDePago");
    if (pagoExitoso == true) {
      print("Resultado: el pago fue exitoso");
    } else {
      print("Resultado: el pago no se completo");
    }
    print("---------------------------");
  }
}
