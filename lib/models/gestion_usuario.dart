import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/Prestador_Servicio.dart';
import 'package:ecostay/models/administrador.dart';

class GestionUsuario {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Este método necesita un mapa de datos adicionales para poder registrar tanto clientes como hosts sin necesidad de crear métodos separados.
  //Se debe usar el metodo toMap() de cada clase para generar el mapa de datos adicionales.
  Future<void> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String rol,
    Map<String, dynamic>? datosAdicionales,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Base del documento
      Map<String, dynamic> perfilUsuario = {
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'fechaRegistro': FieldValue.serverTimestamp(), // Usa el tiempo del servidor, es más seguro
      };

      // Si hay datos específicos (rif, paypal, etc.), los agregamos dinámicamente
      if (datosAdicionales != null) {
        perfilUsuario.addAll(datosAdicionales);
      }

      await _firestore.collection('users').doc(uid).set(perfilUsuario);
    } catch (e) {
      // Nota 1: Aquí deberías lanzar una excepción personalizada para que la UI la maneje
      throw Exception('Error al registrar: $e');
    }
  }

  // Ejemplo de cómo llamar al registro desde la UI:
  // _gestion.registrarUsuario(email: ..., password: ..., nombre: ..., rol: 'host', datosAdicionales: {'rif': rif, 'cuentaPayPal': paypal});

  Future<Usuario> iniciarSesion(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Retornamos directamente el usuario completo cargado de Firestore
      return await obtenerInformacion(userCredential.user!.uid);
    } catch (e) {
      throw Exception('Error de autenticación: $e');
    }
  }

  Future<void> cerrarSesion() async => await _auth.signOut();

  Future<Usuario> obtenerInformacion(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    
    if (!doc.exists) throw Exception('Usuario no encontrado');
    
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String rol = data['rol'];
    DateTime fecha = (data['fechaRegistro'] as Timestamp).toDate();

    switch (rol) {
      case 'cliente':
        return Viajero(
          id: uid, nombre: data['nombre'], email: data['email'],
          password: '', fechaRegistro: fecha, telefono: data['telefono'] ?? '',
          cedula: data['cedula'] ?? '', ciudad: data['ciudad'] ?? '', historialReservas: [],
        );
      case 'host':
        return PrestadorServicio(
          id: uid, nombre: data['nombre'], email: data['email'],
          password: '', fechaRegistro: fecha, rif: data['rif'] ?? '',
          telefono: data['telefono'] ?? '', direccion: data['direccion'] ?? '',
          cuentaPayPal: data['cuentaPayPal'] ?? '', estadisticas: [],
        );
      case 'admin':
        return Administrador(
          id: uid, nombre: data['nombre'], email: data['email'],
          password: '', fechaRegistro: fecha, nivelAcceso: data['nivelAcceso'] ?? 0,
        );
      default:
        throw Exception('Rol desconocido');
    }
  }

  Future<void> editarInformacion(String uid, Map<String, dynamic> nuevaInformacion) async {
    // Evitamos explícitamente que intenten guardar contraseñas en Firestore
    nuevaInformacion.remove('password'); 
    await _firestore.collection('users').doc(uid).update(nuevaInformacion);
  }

  Future<void> eliminarCuenta(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      await _auth.currentUser!.delete();
    } catch (e) {
      throw Exception('Error al eliminar cuenta: $e');
    }
  }
}