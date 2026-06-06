import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'usuario.dart';

class Administrador extends Usuario {
  int nivelAcceso;

  Administrador({
    required super.id,
    required super.nombre,
    required super.email,
    required super.password,
    required super.fechaRegistro,
    required this.nivelAcceso,
  }) : super(rol: 'administrador');

  //Inhabilita a un usuario para que no pueda acceder a su cuenta a traves de Firebase Auth.
  void suspenderUsuario(Usuario user) {

  }

  //Elimina un usuario de la base de datos y de Firebase Auth.
  void eliminarUsuario(Usuario user) {
 
  }

  //Elimina una calificacion realizada por un usuario a una publicacion.
  void eliminarComentario(String publicacionId, String comentarioId) {
    FirebaseFirestore.instance.collection('publicaciones').doc(publicacionId).collection('comentarios').doc(comentarioId).delete();
  }

  void verEstadisticasGlobales() {
    
  }
}