import 'package:flutter/material.dart';

class ModeracionController {
  // --- FUNCIONES DEL MENÚ SUPERIOR ---
  void irADashboard(BuildContext context) {
    print("Navegando a la pantalla de Dashboard...");
    // TODO: Agregar Navigator.push hacia DashboardScreen
  }

  void irAUsuarios(BuildContext context) {
    print("Navegando a la pantalla de Usuarios...");
    // TODO: Agregar Navigator.push hacia UsuariosScreen
  }

  void irALocaciones(BuildContext context) {
    print("Navegando a la pantalla de Locaciones...");
    // TODO: Agregar Navigator.push hacia LocacionesScreen
  }

  // --- FUNCIONES DE LOS BOTONES DEL REPORTE ---
  void ignorarReporte() {
    print("Acción: Reporte Ignorado con éxito.");
    // TODO: Conectar con Firebase para cambiar estado del reporte a "ignorado"
  }

  void eliminarReporte() {
    print("Acción: Reporte Eliminado de la base de datos.");
    // TODO: Conectar con Firebase para borrar el reporte
  }

  void verPerfil(BuildContext context) {
    print("Navegando al Perfil del usuario (Pedro R.)...");
    // TODO: Agregar Navigator.push hacia PerfilScreen pasando el ID del usuario
  }
}
