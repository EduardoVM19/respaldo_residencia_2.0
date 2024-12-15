import 'package:buenos_habitos/page/principal-admin.dart';
import 'package:flutter/material.dart';
import 'login.dart';// Importa la pantalla a la que deseas redirigir

class ConfirmationRegistroAdminScreen extends StatelessWidget {
  const ConfirmationRegistroAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicia el temporizador para redirigir después de unos segundos
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomePage()), // Cambia por la página de destino
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Registro exitoso!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
