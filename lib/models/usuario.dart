import 'package:firebase_auth/firebase_auth.dart';

abstract class Usuario {
  String id;
  String rol;
  String nombre;
  String email;
  String password;
  DateTime fechaRegistro;

  Usuario({
    required this.id,
    required this.rol,
    required this.nombre,
    required this.email,
    required this.password,
    required this.fechaRegistro,
  });

  /// Inicia sesión usando Firebase Auth con email y password.
  /// Devuelve el usuario autenticado o lanza una excepción si falla.
  Future<UserCredential?> iniciarSesion(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Usuario $email ha iniciado sesión.');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Error al iniciar sesión: \\${e.message}');
      return null;
    }
  }

  /// Registra un nuevo usuario. Esta funcion será común para todos los roles.
  /// Esta función va a requerir nombre, role, telefono, cedula, ciudad, RIF, direccion, cuentaPayPal, nivelAcceso, email.
  /// Pero dependiendo del rol, se pueden omitir algunos campos. Por ejemplo, un cliente no necesita RIF ni cuenta PayPal.
  Future<UserCredential?> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String rol,
    String? telefono,
    String? cedula,
    String? ciudad,
    String? rif,
    String? direccion,
    String? cuentaPayPal,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Usuario $email ha sido registrado con rol $rol.');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Error al registrar usuario: \\${e.message}');
      return null;
    }
  } 

  ///Función para registrar los datos adicionales del usuario en ecostaybd después de la autenticación.
  ///Esta función se llamará después de que el usuario haya sido autenticado con Firebase Auth, para guardar su información adicional en la base de datos.
  Future<void> registrarDatosAdicionales(String uid) async {
    // Aquí se implementaría la lógica para guardar los datos adicionales del usuario en ecostaybd usando el UID proporcionado.
    print('Datos adicionales para $nombre registrados en la base de datos con UID: $uid');
  }

  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    print('Usuario $nombre ha cerrado sesión.');
  }

  void editarPerfil() {
    print('Perfil de $nombre editado.');
  }
}