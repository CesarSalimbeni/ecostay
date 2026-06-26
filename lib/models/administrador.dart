import 'usuario.dart';

class Administrador extends Usuario {
  int nivelAcceso;

  Administrador({
    required super.id,
    required super.nombre,
    required super.email,
    required super.fechaRegistro,
    required super.suspendido,
    super.imagenUrl,
    required this.nivelAcceso,
  }) : super(rol: 'administrador');
}