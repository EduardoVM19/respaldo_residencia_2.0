import 'package:buenos_habitos/page/principal.dart'; // Asegúrate de que la ruta sea correcta
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Ganar extends StatelessWidget {
  const Ganar({super.key});

  // Método para obtener el valor de balancedMeals en tiempo real
  Stream<int> getBalancedMealsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      return userDoc.snapshots().map((snapshot) {
        if (snapshot.exists) {
          return snapshot['balancedMeals'] ??
              0; // Devuelve el valor de balancedMeals o 0 si no existe
        }
        return 0;
      });
    }
    return Stream.value(0); // Si no hay usuario, devuelve 0
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: StreamBuilder<int>(
              stream:
                  getBalancedMealsStream(), // Llama al método para escuchar cambios en balancedMeals
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Muestra un indicador mientras se carga
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final balancedMeals =
                    snapshot.data ?? 0; // Obtiene el valor de balancedMeals

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¡Felicidades!",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Has completado un plato balanceado.",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/imagenes/ganar.png',
                      width: 200,
                      height: 200,
                    ),

                    // Mostrar "Comidas saludables logradas:" seguido del valor de balancedMeals
                    Text(
                      "Comidas saludables logradas: $balancedMeals",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        // Redirigir a la página HomePage al presionar el botón
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: const Text('CONTINUAR'),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }
}
