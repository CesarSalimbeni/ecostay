abstract class Usuario {
  String rol; // "cliente", "prestador", "admin"
  String id;
  String nombre;
  String email;
  String password;
  DateTime fechaRegistro; // Equivalente a Date

  Usuario({
    required this.rol,
    required this.id,
    required this.nombre,
    required this.email,
    required this.password, //El password se maneja solo para autenticación, no se guarda en Firestore
    required this.fechaRegistro,
  });
}