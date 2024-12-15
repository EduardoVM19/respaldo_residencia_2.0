import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart';
import 'actualizar-datos.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  // Método para obtener los datos del usuario
  Future<Map<String, dynamic>> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();
      return snapshot.data() ?? {};
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data ?? {};

          // Obtén los datos del usuario
          final nombre = userData['name'] ?? 'Usuario';
          final email = userData['email'] ?? 'No disponible';
          final balancedMeals = userData['balancedMeals'] ?? 0;
          final weightInitial = userData['weightInitial'] ?? 0.0; // Cambiar 'weightLost' a 'weightInitial' aquí
          final weight = userData['weight'] ?? 0.0; // Peso actual
          final weightLost = weightInitial > 0.0 ? weightInitial - weight : 0.0; // Si 'weightInitial' es mayor que 0, calculamos la diferencia

          final glucose = userData['glucose'] ?? 0.0;
          
          // Determina si los parámetros de salud son saludables
          bool isHealthyWeight = weight >= 18.5 && weight <= 24.9;
          bool isHealthyGlucose = glucose >= 70 && glucose <= 100;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección 1: Nombre y Correo
                  Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(nombre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      subtitle: Text(email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sección 2: Estadísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card de comidas exitosas
                      Expanded(
                        child: Container(
                          height:
                              180, // Establecer altura común para ambas tarjetas
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Centrar contenido verticalmente
                                children: [
                                  const Icon(Icons.star,
                                      size: 40, color: Colors.yellow),
                                  const SizedBox(height: 8),
                                  Text(
                                    "$balancedMeals",
                                    style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Comidas exitosas",
                                      style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Card de kilogramos perdidos
                      Expanded(
                        child: Container(
                          height:
                              180, // Establecer altura común para ambas tarjetas
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Centrar contenido verticalmente
                                children: [
                                  const Icon(Icons.balance,
                                      size: 40, color: Colors.black),
                                  const SizedBox(height: 8),
                                  Text(
                                    "$weightLost",
                                    style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Kg perdidos",
                                      style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Sección 3: Peso actual y Glucosa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Peso Inicial",
                              style: TextStyle(fontSize: 18)),
                          Text("$weightInitial kg",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Peso Actual",
                              style: TextStyle(fontSize: 18)),
                          Text("$weight kg",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                    
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Glucosa", style: TextStyle(fontSize: 18)),
                          Text("$glucose mg/dL",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () {
                      // Navegar a la pantalla de Editar Perfil
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditPerfilScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Actualizar avances'),
                  ),
                  const SizedBox(height: 30),

                  // Botón de cerrar sesión
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Cerrar sesión de Firebase
                        await FirebaseAuth.instance.signOut();

                        // Cerrar sesión de Google si se utilizó para autenticarse
                        final googleSignIn = GoogleSignIn();
                        if (await googleSignIn.isSignedIn()) {
                          await googleSignIn.signOut();
                        }

                        // Navegar a la pantalla de login
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                          (Route<dynamic> route) => false,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Cerraste sesión correctamente')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al cerrar sesión: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
