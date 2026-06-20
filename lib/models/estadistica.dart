class Estadistica {
  String nombre;
  double valor;
  String descripcion;

  Estadistica({
    required this.nombre,
    required this.valor,
    this.descripcion = '',
  });

  // funcion para poder imprimir la estadistica facil de prueba
  String mostrarTexto() {
    return "$nombre: $valor";
  }
}