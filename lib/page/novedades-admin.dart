import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AltaNovedadScreen extends StatefulWidget {
  @override
  _AltaNovedadScreenState createState() => _AltaNovedadScreenState();
}

class _AltaNovedadScreenState extends State<AltaNovedadScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _type = 'video'; // Video por defecto
  String? _mediaUrl;

  Future<void> saveNewsToFirestore() async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    // Validamos que la URL no esté vacía
    if (_mediaUrl == null || _mediaUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa una URL válida.')),
      );
      return;
    }

    // Guardamos la novedad en Firestore
    await _firestore.collection('novedades').add({
      'title': title,
      'description': description,
      'type': _type,
      'url': _mediaUrl ?? '', // La URL del video o PDF
    });

    // Limpiamos los campos
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _mediaUrl = null; // Limpiamos la URL
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Novedad agregada exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Agregar desplazamiento cuando se abre el teclado
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Centrar todo el contenido
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centrado horizontal
            children: [
              const SizedBox(height: 20),
              // Título de la pantalla
              const Text(
                'Alta de Novedad',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Campo de Título con estilo personalizado
              const SizedBox(height: 30),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  prefixIcon: const Icon(Icons.title),
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
              // Campo de Descripción con estilo personalizado
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: const Icon(Icons.description),
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
              // Dropdown para seleccionar el tipo de novedad
              Container(
                width: double
                    .infinity, // Permite que el Dropdown ocupe todo el ancho disponible
                child: DropdownButtonFormField<String>(
                  value: _type,
                  hint: const Text('Seleccionar tipo'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.video_label),
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
                  items: <String>['video', 'pdf']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'video' ? 'Video' : 'PDF'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _type = newValue!;
                      _mediaUrl = null; // Limpiar URL cuando se cambia el tipo
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),
              // Campo para la URL con el mismo estilo que el título y descripción
              TextField(
                controller: TextEditingController(
                    text: _mediaUrl), // No limpiar el valor
                onChanged: (value) {
                  setState(() {
                    _mediaUrl = value; // Guardamos la URL del video o PDF
                  });
                },
                decoration: InputDecoration(
                  labelText: _type == 'video'
                      ? 'URL del Video de YouTube'
                      : 'URL del Documento PDF',
                  prefixIcon: const Icon(Icons.link),
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
              const SizedBox(height: 50),
              // Botón para guardar la novedad
              ElevatedButton(
                onPressed: saveNewsToFirestore,
                child: const Text('Guardar novedad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                  minimumSize:
                      Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
