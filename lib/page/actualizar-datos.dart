import 'package:buenos_habitos/page/principal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditPerfilScreen extends StatefulWidget {
  const EditPerfilScreen({super.key});

  @override
  _EditPerfilScreenState createState() => _EditPerfilScreenState();
}

class _EditPerfilScreenState extends State<EditPerfilScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightInitialController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();

  String? _selectedGender;  // Variable para almacenar el género seleccionado

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

  // Método para actualizar los datos del usuario
  Future<void> updateUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final name = _nameController.text;
      final age = int.tryParse(_ageController.text) ?? 0;
      final gender = _selectedGender ?? 'Otros';  // Si no se selecciona nada, por defecto será 'Otros'
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final glucose = double.tryParse(_glucoseController.text) ?? 0.0;
      final weightInitial = double.tryParse(_weightInitialController.text) ?? 0.0;

      // Validación de nombre: solo letras y espacios, longitud máxima de 25
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name) || name.length > 25) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre debe ser solo letras y no superar los 25 caracteres')),
        );
        return;
      }

      // Validación de edad: debe ser mayor a 15 y menor a 100
      if (age <= 14 || age >= 101) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La edad debe ser mayor a 15 y menor a 100')),
        );
        return;
      }

      // Validación de peso inicial y peso actual mayor a 1
      if (weightInitial <= 0 || weight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El peso debe ser mayor a 1')),
        );
        return;
      }

      // Validación de que el peso actual no sea mayor que el peso inicial
      if (weight > weightInitial) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El peso actual no puede ser mayor al peso inicial')),
        );
        return;
      }

      // Validación del nivel de glucosa mayor a 1
      if (glucose <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nivel de glucosa debe ser mayor a 1')),
        );
        return;
      }

      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Verificar si es la primera vez que se establece el weightInitial
      final userData = await userDoc.get();
      final existingData = userData.data();
      final currentWeightInitial = existingData != null && existingData.containsKey('weightInitial') ? existingData['weightInitial'] : 0.0;

      if (currentWeightInitial == 0) {
        // Guardar weightInitial, weight y weightLost solo si weightInitial era cero
        await userDoc.update({
          'name': name,
          'age': age,
          'gender': gender,
          'weightInitial': weightInitial,
          'weight': weight,
          'weightLost': weightInitial - weight,
          'glucose': glucose,
        });
      } else {
        // Solo actualiza el peso y la glucosa si weightInitial ya fue establecido
        await userDoc.update({
          'name': name,
          'age': age,
          'gender': gender,
          'weight': weight,
          'glucose': glucose,
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar los datos: $e')),
      );
    }
  }
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
          final edad = userData['age']?.toString() ?? 'No disponible';
          final sexo = userData['gender'] ?? 'Otros';
          final weightInitial = userData['weightInitial'] ?? 0.0;
          final weight = userData['weight'] ?? 0.0;
          final glucose = userData['glucose'] ?? 0.0;

          // Inicializa los controladores con los datos del usuario
          _nameController.text = nombre;
          _ageController.text = edad;
          _weightController.text = weight.toString();
          _glucoseController.text = glucose.toString();
          _weightInitialController.text = weightInitial.toString();

          // Establece el valor del género
          _selectedGender = sexo;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Nombre
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

                  const SizedBox(height: 30),

                  // Edad
                  TextField(
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

                  const SizedBox(height: 30),

                  // Sexo (Dropdown)
                  Center( // Centrar el Dropdown
                    child: Container(
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
                            _selectedGender = newValue;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Peso inicial
                  TextField(
                    controller: _weightInitialController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Peso Inicial',
                      prefixIcon: const Icon(Icons.fitness_center),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabled: weightInitial == 0, // No editable si ya tiene valor
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

                  const SizedBox(height: 30),

                  // Peso actual
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Peso Actual',
                      prefixIcon: const Icon(Icons.fitness_center),
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

                  const SizedBox(height: 30),

                  // Glucosa
                  TextField(
                    controller: _glucoseController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nivel de Glucosa',
                      prefixIcon: const Icon(Icons.local_hospital),
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

                  const SizedBox(height: 30),

                  // Botón para actualizar los datos
                  ElevatedButton(
                    onPressed: updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Guardar cambios'),
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
