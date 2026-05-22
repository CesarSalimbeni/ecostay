abstract class Usuario {
  String id;
  String nombre;
  String email;
  String password;
  DateTime fechaRegistro; // Equivalente a Date

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.fechaRegistro,
  });

  void iniciarSesion() {
    print('Usuario $nombre ha iniciado sesión.');
  }

  void cerrarSesion() {
    print('Usuario $nombre ha cerrado sesión.');
  }

  void editarPerfil() {
    print('Perfil de $nombre editado.');
  }
}