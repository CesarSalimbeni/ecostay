///Nota: Cambiar los prints por otras formas de mostrar mensajes al usuario.
///Nota 2: Mejorar la seguridad de Firestore.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarUsuario {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _registrarUsuarioInicial(String email, String password, String nombre, String rol) async {
    try {
      // Crear el usuario con Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtener el ID del usuario recién creado
      String uid = userCredential.user!.uid;

      // Crear un nuevo documento en Firestore para almacenar información adicional del usuario
      await _firestore.collection('users').doc(uid).set({
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'fechaRegistro': DateTime.now(),
      });

      print('Usuario registrado exitosamente');
    } catch (e) {
      print('Error al registrar usuario: $e');
    }
  }

  Future<void> _registrarUsuarioCompleto(String email, String password, String nombre, String rol, String rif, String telefono, String direccion, String cuentaPayPal, String cedula, String ciudad, int nivel) async {
    try {
      // Crear el usuario con Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtener el ID del usuario recién creado
      String uid = userCredential.user!.uid;

      // Crear un nuevo documento en Firestore para almacenar información adicional del usuario
      await _firestore.collection('users').doc(uid).set({
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'fechaRegistro': DateTime.now(),
        'rif': rif,
        'telefono': telefono,
        'direccion': direccion,
        'cuentaPayPal': cuentaPayPal,
        'cedula': cedula,
        'ciudad': ciudad,
        'nivel de acceso': nivel, ///Solo para administradores.
      });

      print('Usuario registrado exitosamente');
    } catch (e) {
      print('Error al registrar usuario: $e');
    }
  }

  ///Funciones específicas para registrar Prestadores y Clientes, utilizando la función general registrarUsuarioCompleto.
  ///Los campos específicos para cada tipo de usuario se rellenan con valores predeterminados o vacíos según corresponda.
  ///Los administradores se pondrá directamente desde Firestore, ya que no se registran a través de la app. Por si se preguntan.

  Future<void> registrarPrestador(String email, String password, String nombre, String rif, String telefono, String direccion, String cuentaPayPal) async {
    await _registrarUsuarioCompleto(email, password, nombre, 'host', rif, telefono, direccion, cuentaPayPal, 'cedula', 'ciudad', 0);
  }

  Future<void> registrarCliente(String email, String password, String nombre, String rif, String telefono, String cedula, String ciudad) async {
    await _registrarUsuarioCompleto(email, password, nombre, 'cliente', 'rif', telefono, 'direccion', 'cuentaPayPal', cedula, ciudad, 0);
  }
}

class IniciarSesion {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> iniciarSesion(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Usuario inició sesión exitosamente');
    } catch (e) {
      print('Error al iniciar sesión: $e');
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
      print('Usuario cerró sesión exitosamente');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }
}

class ObtenerInformacionUsuario {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> obtenerInformacion(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print('No se encontró el usuario');
        return null;
      }
    } catch (e) {
      print('Error al obtener información del usuario: $e');
      return null;
    }
  }
}