import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostay/models/usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/models/prestador_servicio.dart';
import 'package:ecostay/models/administrador.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
          fechaRegistro: fecha, telefono: data['telefono'] ?? '',
          cedula: data['cedula'] ?? '', ciudad: data['ciudad'] ?? '', historialReservas: [],
          suspendido: data['suspendido']
        );
      case 'host':
        return PrestadorServicio(
          id: uid, nombre: data['nombre'], email: data['email'],
           fechaRegistro: fecha, rif: data['rif'] ?? '',
          telefono: data['telefono'] ?? '', direccion: data['direccion'] ?? '',
          cuentaPayPal: data['cuentaPayPal'] ?? '', estadisticas: [],
          suspendido: data['suspendido']
        );
      case 'admin':
        return Administrador(
          id: uid, nombre: data['nombre'], email: data['email'],
           fechaRegistro: fecha, nivelAcceso: data['nivelAcceso'] ?? 0,
           suspendido: data['suspendido']
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

  /// Envía un correo electrónico para restablecer la contraseña del usuario.
  /// 
  /// Recibe el [email] al que se enviará el enlace.
  /// Devuelve `true` si el correo se envió con éxito, o un [String] con el mensaje de error si falla.
  Future<dynamic> recuperarContrasena(String email) async {
    try {
      // Este metodo de auth envia un email al correo para reestablecer la contraseña.
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true; 
    } on FirebaseAuthException catch (e) {
      // Manejo de errores específicos de Firebase Auth
      switch (e.code) {
        case 'invalid-email':
          return 'El formato del correo electrónico no es válido.';
        case 'user-not-found':
          return 'No existe ningún usuario registrado con este correo.';
        default:
          return 'Ocurrió un error inesperado: ${e.message}';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }

  //Este metodo modifica el bool de suspendido de un usuario en Firebase.
  //
  Future<dynamic> cambiarEstadoSuspension(String uidUsuarioAfectado, bool suspender) async {
    try {
      
      await _firestore.collection('users').doc(uidUsuarioAfectado).update({
        'suspendido': suspender,
        'fecha_modificacion': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      return 'Error al cambiar el estado del usuario: $e';
    }
  }
}

//Por cuestiones de modulacion, se hará esta clase por separado.
class GestionImagenPerfil { 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //Esta función sirve para subir una imagen a Firebase Storage y asociarla a una publicación 
  //específica en Firestore, utilizando el ID de la publicación y el archivo de la imagen.
  Future<String?> subirImagen(String usuarioId, XFile imagen) async { // <-- Cambiado a XFile
    try {
      String filePath = 'usuarios/$usuarioId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await imagen.readAsBytes(); 
      
      UploadTask uploadTask = _storage.ref().child(filePath).putData(bytes); 
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore.collection('users').doc(usuarioId).update({'imagenUrl': downloadUrl});
      print('Imagen subida exitosamente');
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  //Esta función sirve para eliminar la imagen asociada a una publicación específica en Firestore, 
  //utilizando el ID de la publicación.
  Future<void> eliminarImagen(String usuarioId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(usuarioId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['imagenUrl'] != null) {
          String imageUrl = data['imagenUrl'];
          await _storage.refFromURL(imageUrl).delete();
          await _firestore.collection('users').doc(usuarioId).update({'imagenUrl': FieldValue.delete()});
          print('Imagen eliminada exitosamente');
        }
      } else {
        print('No se encontró imagen para eliminar');
      }
    } catch (e) {
      print('Error al eliminar imagen: $e');
    }
  }

  //Esta función sirve para obtener el URL de la imagen asociada a una publicación específica en Firestore, 
  //utilizando el ID de la publicación.
  Future<String?> obtenerImagenUrl(String usuarioId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(usuarioId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['imagenUrl'] != null) {
          return data['imagenUrl'];
        }
      }
      print('No se encontró imagen para esta publicación');
      return null;
    } catch (e) {
      print('Error al obtener URL de imagen: $e');
      return null;
    }
  }
}