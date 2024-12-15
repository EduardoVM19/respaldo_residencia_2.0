import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'confirmacion-registro.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedGender; // Variable para almacenar el género seleccionado

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> registerWithEmailAndPassword() async {
  // Validación de campos obligatorios
  if (_emailController.text.trim().isEmpty ||
      _passwordController.text.trim().isEmpty ||
      _confirmPasswordController.text.trim().isEmpty ||
      _nameController.text.trim().isEmpty ||
      _ageController.text.trim().isEmpty ||
      _selectedGender == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todos los campos son obligatorios')),
    );
    return; // Salir si algún campo está vacío
  }

  // Validación de contraseñas
  if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Las contraseñas no coinciden')),
    );
    return; // Salir si las contraseñas no coinciden
  }

  // Validación de la edad
  int? age = int.tryParse(_ageController.text.trim());
  if (age == null || age <= 14 || age > 101) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La edad debe ser mayor a 15 y menor de 100 años')),
    );
    return; // Salir si la edad no es válida
  }

  // Validación del nombre (solo letras y espacios, longitud máxima de 25 caracteres)
  String name = _nameController.text.trim();
  if (name.length > 25 || !RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El nombre no debe contener números ni caracteres especiales y debe tener una longitud máxima de 25 caracteres')),
    );
    return; // Salir si el nombre no es válido
  }

  try {
    // Registrar al usuario en Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Obtener la referencia a Firestore
    final userRef = FirebaseFirestore.instance.collection('users');

    // Guardar los datos del usuario en Firestore
    await userRef.doc(userCredential.user?.uid).set({
      'name': name,
      'email': _emailController.text.trim(),
      'age': age, // Usa la edad válida
      'gender': _selectedGender, // Cambia a _selectedGender
      'daysConnected': 0, // Establecemos daysConnected en 0 por defecto
      'hasSeenIntro': false, // El usuario aún no ha visto la pantalla de introducción
      'balancedMeals': 0,
      'glucose': 0,
      'weight': 0,
      'weightLost': 0,
      'weightInitial': 0,
      'role': 'usuario',
    });

    // Navega a la pantalla de confirmación
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfirmationRegistroScreen()),
    );
  } on FirebaseAuthException catch (e) {
    // Mostrar un SnackBar para el error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.message}')),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
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
                  'REGISTRAR',
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: const Icon(Icons.email),
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
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Edad',
                        prefixIcon: const Icon(Icons.cake),
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
                  ),
                  const SizedBox(width: 40),
                  Container(
                    width: 185,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      hint: const Text('Sexo'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
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
                      items: <String>['Masculino', 'Femenino', 'Otros']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: registerWithEmailAndPassword,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                child: SizedBox(
                    width: screenWidth * 0.9,
                    child: const Center(
                      child: Text('Registrar'),
                    ),
                  ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
