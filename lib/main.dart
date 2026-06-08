import 'package:ecostay/pantallas/mis_reservas_viaj.dart';
import 'package:ecostay/pantallas/publicaciones_anf.dart';
import 'package:ecostay/pantallas/reservas_anf.dart';
import 'package:ecostay/pantallas/reservas_viaj.dart';
import 'package:ecostay/pantallas/pag_inicio.dart';
import 'package:ecostay/models/gestion_usuario.dart';
import 'package:ecostay/models/viajero.dart';
import 'package:ecostay/pantallas/registro.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String? error;
  const MyApp({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoStay',
      theme: ThemeData(primarySwatch: Colors.green),
      
      // CAMBIAMOS ESTA LÍNEA: 
      // En vez de PantallaInicio(), cargamos PantallaRegistro()
      home: PantallaInicio(), 
    );
  }
}

// Esta es una prueba hecha con IA para verificar y mostrar en pantalla el funcionamiento de los métodos de autenticación y gestión de usuarios con Firebase.
class TestUserManagementScreen extends StatefulWidget {
  const TestUserManagementScreen({super.key});

  @override
  State<TestUserManagementScreen> createState() => _TestUserManagementScreenState();
}

class _TestUserManagementScreenState extends State<TestUserManagementScreen> {
  final GestionUsuario _gestionUsuario = GestionUsuario();
  String _statusMessage = "Presiona el botón para iniciar la prueba.";
  bool _isLoading = false;

  // Método secuencial para probar los flujos de tu backend simulado/Firebase
  Future<void> _ejecutarPruebaCompleta() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Iniciando pruebas...";
    });

    const String emailTest = "viajero_test@ecostay.com";
    const String passwordTest = "password123";
    const String nombreTest = "Carlos Viajero";

    try {
      Viajero nuevoViajero = Viajero(
        id: '', 
        nombre: nombreTest,
        email: emailTest,
        password: passwordTest,
        fechaRegistro: DateTime.now(),
        telefono: "+584121234567",
        cedula: "V-12345678",
        ciudad: "Caracas",
        historialReservas: [],
      );

      setState(() => _statusMessage = "1. Registrando usuario en Firebase...");
      await _gestionUsuario.registrarUsuario(
        email: nuevoViajero.email,
        password: passwordTest,
        nombre: nuevoViajero.nombre,
        rol: nuevoViajero.rol,
        datosAdicionales: nuevoViajero.toMap(),
      );

      setState(() => _statusMessage = "2. Usuario registrado. Iniciando sesión...");
      var usuarioLogueado = await _gestionUsuario.iniciarSesion(emailTest, passwordTest);

      setState(() {
        _statusMessage = "3. ¡Sesión Iniciada!\n\n"
            "Detalles recuperados de Firestore:\n"
            "ID: ${usuarioLogueado.id}\n"
            "Nombre: ${usuarioLogueado.nombre}\n"
            "Rol: ${usuarioLogueado.rol}\n\n"
            "Cerrando sesión en 3 segundos...";
      });

      await Future.delayed(const Duration(seconds: 3));

      await _gestionUsuario.cerrarSesion();
      setState(() {
        _statusMessage = "4. Prueba completada con éxito. Sesión cerrada.";
      });

    } catch (e) {
      setState(() {
        _statusMessage = "❌ Error durante la prueba:\n$e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoStay - Test de Autenticación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _ejecutarPruebaCompleta,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Correr Flujo de Prueba'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}