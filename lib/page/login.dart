import 'package:buenos_habitos/page/confirmacion-admin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'confirmacion-login.dart';
import 'recuperarContrasena.dart';
import 'registrar.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'principal.dart';
import 'principal-admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Incrementar el campo 'daysConnected' solo una vez por día
  Future<void> _incrementDaysConnected(User user) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final userDoc = await userRef.get();

  // Obtener la fecha actual en formato "yyyy-MM-dd"
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  if (userDoc.exists) {
    // Verificar la última fecha de inicio de sesión
    final lastLoginDate = userDoc.data()?['lastLoginDate'];
    final daysConnected = userDoc.data()?['daysConnected'] ?? 0;

    if (lastLoginDate != today) {
      // Si la fecha de inicio de sesión es diferente a hoy
      await userRef.update({
        'daysConnected': (daysConnected > 0) ? daysConnected + 1 : 1, // Si 'daysConnected' es 0, se incrementa a 1
        'lastLoginDate': today, // Actualizar la última fecha de inicio de sesión
      });
    }
  } else {
    // Si el usuario no existe en Firestore, crearlo con 'daysConnected' igual a 0 y la fecha actual
    await userRef.set({
      'daysConnected': 0, // Empezar con 0 en el primer inicio de sesión
      'lastLoginDate': today,
      'email': user.email,
    });
  }
}


  Future<void> _checkUserRole(User user) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final userDoc = await userRef.get();

  if (!mounted) return; // Asegúrate de que el widget esté montado

  if (userDoc.exists) {
    String role = userDoc.data()?['role'] ?? 'usuario'; // Por defecto 'usuario' si no está definido.

    // Dependiendo del rol, redirige a la interfaz correspondiente
    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmationAdminScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
      );
    }
  } else {
    // Si no existe el documento, redirige a la pantalla de confirmación
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
    );
  }
}

Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Referencia al documento del usuario en Firestore
    final userRef = FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid);
    final userDoc = await userRef.get();

    // Si el usuario no existe, creamos los datos por defecto
    if (!userDoc.exists) {
      await userRef.set({
        'name': userCredential.user?.displayName ?? 'Usuario Sin Nombre',
        'email': userCredential.user?.email ?? '',
        'age': 0, // Edad por defecto
        'gender': 'Otros', // Género por defecto
        'daysConnected': 0, // Establecemos daysConnected en 0 por defecto
        'hasSeenIntro': false, // El usuario aún no ha visto la pantalla de introducción
        'balancedMeals': 0,
        'glucose': 0,
        'weight': 0,
        'weightLost': 0,
        'weightInitial': 0,
        'role': 'usuario',  // Asignación de rol por defecto
      });
    }

    // Esperamos que los datos de Firestore se actualicen antes de continuar
    await _incrementDaysConnected(userCredential.user!);

    if (!mounted) return; // Asegúrate de que el widget esté montado
    await _checkUserRole(userCredential.user!);

  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.message}')),
    );
  }
}




Future<void> signInWithEmailAndPassword() async {
  if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario/contraseña inválidos')),
    );
    return;
  }

  final email = _emailController.text.trim();
  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formato de correo incorrecto')),
    );
    return;
  }

  try {
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: _passwordController.text.trim(),
    );

    // Incrementar 'daysConnected' después del inicio de sesión exitoso
    await _incrementDaysConnected(userCredential.user!);

    // Verificar el rol del usuario y redirigir a la interfaz correspondiente
    if (!mounted) return; // Asegúrate de que el widget esté montado
    await _checkUserRole(userCredential.user!);

  } on FirebaseAuthException catch (e) {
    _emailController.clear();
    _passwordController.clear();

    if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario/Contraseña incorrecto')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }
}



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                  'NOMBRE',
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 4.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 4.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 4.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 4.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: signInWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    child: const Center(
                      child: Text('INGRESAR'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PasswordResetScreen()),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "or",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 171, 67, 58),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/imagenes/google.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text('INICIAR SESIÓN CON GMAIL'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    child: const Center(
                      child: Text('REGISTRAR'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
