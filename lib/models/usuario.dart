import 'gestion_Usuario.dart';

abstract class Usuario {
  String rol; // "cliente", "host", "admin"
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
    required this.password,
    required this.fechaRegistro,
  });

  void iniciarSesion() {
    IniciarSesion iniciarSesion = IniciarSesion();
    iniciarSesion.iniciarSesion(email, password);
  }

  void cerrarSesion() {
    IniciarSesion iniciarSesion = IniciarSesion();
    iniciarSesion.cerrarSesion();
  }

  void editarPerfil() {
    print('Perfil de $nombre editado.');
  }
}