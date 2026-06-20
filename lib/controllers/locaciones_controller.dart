import 'package:flutter/material.dart';

class LocacionesController {
  // ==========================================
  // NAVEGACIÓN DEL MENÚ
  // ==========================================
  void irADashboard(BuildContext context) {
    // Navigator.pushNamed(context, '/dashboard');
    print('Navegando a Dashboard');
  }

  void irAUsuarios(BuildContext context) {
    // Navigator.pushNamed(context, '/usuarios');
    print('Navegando a Usuarios');
  }

  void irAModeracion(BuildContext context) {
    // Navigator.pushNamed(context, '/moderacion');
    print('Navegando a Moderación');
  }

  // ==========================================
  // ACCIONES DE LA TABLA LOCACIONES
  // ==========================================

  void editarLocacion(String lugar) {
    // Aquí tus compañeros pondrán la lógica para abrir el modal/pantalla de edición
    print('Botón presionado: Editar locación -> $lugar');
  }

  void eliminarLocacion(String lugar) {
    // Aquí tus compañeros pondrán la lógica para borrar de la base de datos
    print('Botón presionado: Eliminar locación -> $lugar');
  }

  void agregarLocacion() {
    // Aquí tus compañeros pondrán la lógica para crear una nueva locación
    print('Botón presionado: Agregar nueva locación');
  }
}
