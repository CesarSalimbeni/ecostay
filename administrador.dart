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
  });

  void suspenderUsuario(Usuario user) {
    print('Admin $nombre suspendió al usuario: ${user.nombre}');
  }

  void eliminarUsuario(Usuario user) {
    print('Admin $nombre eliminó al usuario: ${user.nombre}');
  }

  void eliminarComentario(dynamic comentario) {
    print('Admin $nombre eliminó un comentario.');
  }

  void verEstadisticasGlobales() {
    print('Admin $nombre viendo métricas globales del sistema.');
  }
}