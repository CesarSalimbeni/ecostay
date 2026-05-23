import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // IMPORTANTE
import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORTANTE
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro Firebase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Corregido
        useMaterial3: true,
      ),
      home: const RegistroPage(), // Cambiado a nuestra nueva página de registro
    );
  }
}

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  // Controladores para capturar el texto de los inputs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  
  // Rol por defecto asignado (Filtro único en String)
  String _rolSeleccionado = 'cliente'; 

  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // FUNCIÓN PRINCIPAL DE REGISTRO UNIFICADO
  Future<void> _registrarUsuario() async {
    try {
      // 1. Crear usuario en Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Guardar datos adicionales en la única colección 'usuarios' usando el UID
        await _firestore.collection('usuarios').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'nombres': _nombresController.text.trim(),
          'apellidos': _apellidosController.text.trim(),
          'rol': _rolSeleccionado, // "admin" o "cliente"
          'fechaRegistro': DateTime.now().toIso8601String(),
        });

        // Alerta de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Usuario registrado con éxito en Auth y Firestore!')),
          );
        }
      }
    } catch (e) {
      // Alerta de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Registro Único - Firebase'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Corregido
          children: [
            TextField(
              controller: _nombresController,
              decoration: const InputDecoration(labelText: 'Nombres'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _apellidosController,
              decoration: const InputDecoration(labelText: 'Apellidos'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            
            // Selector de Rol simple
            Row(
              children: [
                const Text("Rol asignado: "),
                DropdownButton<String>(
                  value: _rolSeleccionado,
                  items: <String>['cliente', 'admin'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (nuevoRol) {
                    setState(() {
                      _rolSeleccionado = nuevoRol!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _registrarUsuario,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    super.dispose();
  }
}
