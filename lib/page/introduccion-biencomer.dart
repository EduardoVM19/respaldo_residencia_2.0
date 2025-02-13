import 'package:buenos_habitos/page/platoBuenComer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IntroductionScreen extends StatelessWidget {
  final String uid; // El UID del usuario se pasa correctamente como parámetro

  // Constructor donde recibes el UID
  const IntroductionScreen({Key? key, required this.uid}) : super(key: key);

  // Método para marcar la intro como vista en la base de datos
  Future<void> _markIntroSeen() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'hasSeenIntro': true,
    });
  }

  // Método para navegar a la pantalla de minijuego
  void _goToMinigame(BuildContext context) async {
    await _markIntroSeen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PlatoDelBuenComerApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150.0),
        child: Container(
          margin: const EdgeInsets.only(top: 50),
          child: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/imagenes/icono-app.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(width: 16),
                const Text(
                  'Introducción',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            toolbarHeight: 100,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Instrucciones:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "- Selecciona una categoría de alimentos.\n"
              "- Arrastra los ingredientes desde la categoría hasta el plato.\n"
              "- Los ingredientes deben ser colocados dentro del plato para ser válidos.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              "Condiciones para ganar:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "El plato debe incluir al menos un ingrediente de cada categoría:\n"
              "  - Verduras\n"
              "  - Frutas\n"
              "  - Cereales\n"
              "  - Proteínas",
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _goToMinigame(context),
                child: const Text(
                  "Continuar",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
