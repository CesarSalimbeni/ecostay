import 'package:ecostay/models/gestion_usuario.dart';

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
    GestionUsuario gestion = GestionUsuario();
    gestion.iniciarSesion(email, password);
  }

  void cerrarSesion() {
    GestionUsuario gestion = GestionUsuario();
    gestion.cerrarSesion();
  }

  void editarPerfil(String nombre, String email, String password) {
    GestionUsuario gestion = GestionUsuario();
    gestion.editarInformacion(id, {
      'nombre': nombre,
      'email': email,
      'password': password,
    });
  }
}