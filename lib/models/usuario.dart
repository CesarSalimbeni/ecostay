abstract class Usuario {
  String rol; // "cliente", "prestador", "admin"
  String id;
  String nombre;
  String email;
  DateTime fechaRegistro; // Equivalente a Date
  bool suspendido;

  Usuario({
    required this.rol,
    required this.id,
    required this.nombre,
    required this.email,
    required this.fechaRegistro,
    required this.suspendido //Poner false para cuando se registre.
  });
}