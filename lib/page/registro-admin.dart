import 'package:buenos_habitos/page/confirmacion-registroadmin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'confirmacion-admin.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  _AdminRegisterScreenState createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> convertToAdmin() async {
    try {
      final email = _emailController.text.trim();

      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor ingresa un correo electrónico')),
        );
        return;
      }

      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se encontró un usuario con ese correo')),
        );
        return;
      }

      final userDoc = userQuery.docs.first;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDoc.id)
          .update({'role': 'admin'});

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ConfirmationRegistroAdminScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<bool> checkStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final androidVersion = androidInfo.version.sdkInt;

        if (androidVersion >= 30) {
          // Android 11 o superior (API level 30+)
          if (await Permission.manageExternalStorage.request().isGranted) {
            return true; // Permiso concedido
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se necesitan permisos para exportar datos.'),
              ),
            );
            return false;
          }
        } else if (androidVersion >= 23) {
          // Android 6.0 (API level 23) a Android 10 (API level 29)
          if (await Permission.storage.request().isGranted) {
            return true; // Permiso concedido
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se necesitan permisos para exportar datos.'),
              ),
            );
            return false;
          }
        } else {
          // Android 5.1 o inferior
          return true; // Asumimos que los permisos no son necesarios en versiones muy antiguas
        }
      }
      // En otras plataformas, asumimos que los permisos no son necesarios
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar permisos: $e')),
      );
      return false;
    }
  }

  Future<void> exportDataToExcel() async {
    try {
      // Verificar permisos
      if (await checkStoragePermission()) {
        // Crear el archivo Excel
        final excel = Excel.createExcel();
        final sheet = excel['Usuarios'];

        // Encabezados
        sheet.appendRow([
          'ID',
          'Nombre',
          'Correo',
          'Edad',
          'Glucosa',
          'Peso',
          'Peso Inicial',
          'Peso Perdido',
          'Días Conectados',
          'Comidas Balanceadas',
        ]);

        // Obtener datos de Firestore
        final usersSnapshot =
            await FirebaseFirestore.instance.collection('users').get();

        for (var user in usersSnapshot.docs) {
          final data = user.data();

          // Asegurar valores válidos o predeterminados
          final id = user.id;
          final name = data['name'] ?? 'Desconocido';
          final email = data['email'] ?? 'No especificado';
          final age = data['age'] ?? 'N/A';
          final glucose = data['glucose'] ??
              0; // Valor predeterminado 0 si no está disponible
          final weight = data['weight'] ??
              0; // Valor predeterminado 0 si no está disponible
          final weightInitial = data['weightInitial'] ??
              0; // Valor predeterminado 0 si no está disponible
          final weightLost = data['weightLost'] ??
              0; // Valor predeterminado 0 si no está disponible
          final daysConnected = data['daysConnected'] ??
              0; // Valor predeterminado 0 si no está disponible
          final balancedMeals = data['balancedMeals'] ??
              0; // Valor predeterminado 0 si no está disponible

          // Agregar fila con los datos del usuario
          sheet.appendRow([
            id,
            name,
            email,
            age,
            glucose,
            weight,
            weightInitial,
            weightLost,
            daysConnected,
            balancedMeals,
          ]);
        }

        // Guardar el archivo Excel
        final directory = await getExternalStorageDirectory();
        final path = '${directory!.path}/usuarios.xlsx';
        final fileBytes = excel.save();
        final file = File(path);
        await file.writeAsBytes(fileBytes!);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo guardado en: $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'No se otorgaron permisos de almacenamiento. Intenta nuevamente.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
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
              ElevatedButton(
                onPressed: convertToAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: SizedBox(
                  width: screenWidth * 0.9,
                  child: const Center(
                    child: Text('CONVERTIR A ADMIN'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: exportDataToExcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: SizedBox(
                  width: screenWidth * 0.9,
                  child: const Center(
                    child: Text('EXPORTAR A EXCEL'),
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
