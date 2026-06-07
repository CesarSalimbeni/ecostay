abstract class IPagoProvider {
  bool procesarPago(double monto);

  bool procesarReembolso(String idTransaccion);
  
}