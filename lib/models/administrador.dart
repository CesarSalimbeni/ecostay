import 'package:ecostay/models/gestion_publicacion.dart';

import 'usuario.dart';

class Administrador extends Usuario {
  String rol = "admin";
  int nivelAcceso;

  Administrador({
    required super.id,
    required super.nombre,
    required super.email,
    required super.password,
    required super.fechaRegistro,
    required this.nivelAcceso,
  }) : super(rol: 'administrador');

  void suspenderUsuario(Usuario user) {
    print('Admin $nombre suspendió al usuario: ${user.nombre}');
  }

  void eliminarUsuario(Usuario user) {
    print('Admin $nombre eliminó al usuario: ${user.nombre}');
  }

  void eliminarComentario(String publicacionId, String comentarioId) {
    print('Admin $nombre eliminó el comentario $comentarioId de la publicación $publicacionId.');
  }

  void verEstadisticasGlobales() {
    print('Admin $nombre viendo métricas globales del sistema.');
  }
}