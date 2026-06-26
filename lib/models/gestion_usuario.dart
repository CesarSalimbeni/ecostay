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
    
    return _mapearDocumentoAUsuario(doc);
  }

  Future<void> editarInformacion(String uid, Map<String, dynamic> nuevaInformacion) async {
    // Evitamos explícitamente que intenten guardar contraseñas en Firestore
    nuevaInformacion.remove('password'); 
    await _firestore.collection('users').doc(uid).update(nuevaInformacion);
  }

  /// Elimina por completo la cuenta del usuario de Firebase Auth, Firestore y Storage.
  /// Requiere la [contrasenaActual] por seguridad para reautenticar al usuario.
  Future<void> eliminarCuentaCompleta({
    required String contrasenaActual,
  }) async {
    try {
      User? usuarioActual = _auth.currentUser;
      if (usuarioActual == null) throw Exception('No hay ningún usuario con sesión activa.');

      String uid = usuarioActual.uid;
      String? email = usuarioActual.email;

      if (email == null) throw Exception('No se pudo verificar el correo electrónico.');

      // 1. REAUTENTICACIÓN (Obligatoria en Firebase antes de acciones sensibles)
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: contrasenaActual,
      );
      await usuarioActual.reauthenticateWithCredential(credential);

      // 2. ELIMINAR IMAGEN DE PERFIL
      // Instanciamos la clase auxiliar de imágenes y borramos el archivo si existe
      final gestionImagen = GestionImagenPerfil();
      await gestionImagen.eliminarImagen(uid);

      // 3. ELIMINAR DOCUMENTO DE FIRESTORE
      await _firestore.collection('users').doc(uid).delete();

      // 4. ELIMINAR USUARIO DE FIREBASE AUTH
      await usuarioActual.delete();
      
    } on FirebaseAuthException catch (e) {
      // Manejo de errores específicos de Firebase Auth
      switch (e.code) {
        case 'wrong-password':
          throw Exception('La contraseña ingresada es incorrecta.');
        case 'user-mismatch':
          throw Exception('Las credenciales no coinciden con el usuario actual.');
        case 'requires-recent-login':
          throw Exception('Por seguridad, por favor cierra sesión e ingresa nuevamente antes de eliminar tu cuenta.');
        default:
          throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al eliminar la cuenta de manera integral: $e');
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

  /// Busca usuarios por nombre.
  /// Si [nombreBusqueda] está vacío o es nulo, actúa como un explorador y devuelve todos los usuarios.
  /// Retorna una lista de instancias de la clase base [Usuario].
  Future<List<Usuario>> buscarUsuariosPorNombre(String? nombreBusqueda) async {
    try {
      Query query = _firestore.collection('users');

      if (nombreBusqueda != null && nombreBusqueda.trim().isNotEmpty) {
        String busqueda = nombreBusqueda.trim();
        
        // Simulación de "Comienza con" para Firestore
        query = query
            .where('nombre', isGreaterThanOrEqualTo: busqueda)
            .where('nombre', isLessThanOrEqualTo: '$busqueda\uf8ff');
      }

      QuerySnapshot querySnapshot = await query.get();

      // Mapeamos cada documento transformándolo en su clase correspondiente de tipo Usuario
      List<Usuario> usuarios = querySnapshot.docs.map((doc) {
        return _mapearDocumentoAUsuario(doc);
      }).toList();

      return usuarios;
    } catch (e) {
      throw Exception('Error al buscar usuarios: $e');
    }
  }

  /// Método auxiliar privado para centralizar la conversión de Firestore a objetos de tipo Usuario.
  Usuario _mapearDocumentoAUsuario(DocumentSnapshot doc) {
    if (!doc.exists) throw Exception('Usuario no encontrado');
    
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String uid = doc.id;
    String rol = data['rol'] ?? 'cliente';
    String? imagenUrl = data['imagenUrl'];
    
    DateTime fecha = data['fechaRegistro'] != null 
        ? (data['fechaRegistro'] as Timestamp).toDate() 
        : DateTime.now();

    switch (rol) {
      case 'cliente':
        return Viajero(
          id: uid, nombre: data['nombre'] ?? 'Sin nombre', email: data['email'] ?? '', 
          fechaRegistro: fecha, telefono: data['telefono'] ?? '',
          cedula: data['cedula'] ?? '', ciudad: data['ciudad'] ?? '', historialReservas: [],
          suspendido: data['suspendido'] ?? false,
          imagenUrl: imagenUrl,
        );
      case 'host':
        return PrestadorServicio(
          id: uid, nombre: data['nombre'] ?? 'Sin nombre', email: data['email'] ?? '',
          fechaRegistro: fecha, rif: data['rif'] ?? '',
          telefono: data['telefono'] ?? '', direccion: data['direccion'] ?? '',
          cuentaPayPal: data['cuentaPayPal'] ?? '', estadisticas: [],
          suspendido: data['suspendido'] ?? false,
          imagenUrl: imagenUrl,
        );
      case 'admin':
        return Administrador(
          id: uid, nombre: data['nombre'] ?? 'Sin nombre', email: data['email'] ?? '',
          fechaRegistro: fecha, nivelAcceso: data['nivelAcceso'] ?? 0,
          suspendido: data['suspendido'] ?? false,
          imagenUrl: imagenUrl,
        );
      default:
        throw Exception('Rol desconocido: $rol');
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
    return downloadUrl;
  } catch (e) {
    print('Error crítico al subir imagen: $e');
    throw Exception('Error al subir la imagen en Storage: $e');
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