import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ganar.dart';

Future<void> updateBalancedMealsCount() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.update({
        'balancedMeals': FieldValue.increment(1),
      });
    }
  } catch (e) {
    print('Error al actualizar el contador de comidas balanceadas: $e');
  }
}

class PlatoDelBuenComerApp extends StatelessWidget {
  const PlatoDelBuenComerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plato del Bien Comer',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const PlatoScreen(),
    );
  }
}

class PlatoScreen extends StatefulWidget {
  const PlatoScreen({Key? key}) : super(key: key);

  @override
  _PlatoScreenState createState() => _PlatoScreenState();
}

class _PlatoScreenState extends State<PlatoScreen> {
  List<Ingredient> ingredients = [
    Ingredient(name: 'zanahoria', type: 'verdura', portion: '50g'),
    Ingredient(name: 'chile_morron', type: 'verdura', portion: '50g'),
    Ingredient(name: 'pepino', type: 'verdura', portion: '50g'),
    Ingredient(name: 'nopal', type: 'verdura', portion: '50g'),
    Ingredient(name: 'brocoli', type: 'verdura', portion: '50g'),
    Ingredient(name: 'aguacate', type: 'verdura', portion: '50g'),
    Ingredient(name: 'cebolla', type: 'verdura', portion: '50g'),
    Ingredient(name: 'lechuga', type: 'verdura', portion: '50g'),
    Ingredient(name: 'repollo', type: 'verdura', portion: '50g'),
    Ingredient(name: 'tomate', type: 'verdura', portion: '50g'),
    Ingredient(name: 'chile', type: 'verdura', portion: '50g'),
    Ingredient(name: 'apio', type: 'verdura', portion: '50g'),
    Ingredient(name: 'maiz', type: 'pan', portion: '50g'),
    Ingredient(name: 'pan', type: 'pan', portion: '50g'),
    Ingredient(name: 'frijol', type: 'pan', portion: '50g'),
    Ingredient(name: 'caldo', type: 'pan', portion: '50g'),
    Ingredient(name: 'cereal', type: 'pan', portion: '50g'),
    Ingredient(name: 'tortilla', type: 'pan', portion: '50g'),
    Ingredient(name: 'arroz', type: 'pan', portion: '50g'),
    Ingredient(name: 'harina', type: 'pan', portion: '50g'),
    Ingredient(name: 'pasta', type: 'pan', portion: '50g'),
    Ingredient(name: 'queso', type: 'carne', portion: '50g'),
    Ingredient(name: 'pescado', type: 'carne', portion: '50g'),
    Ingredient(name: 'pollo', type: 'carne', portion: '50g'),
    Ingredient(name: 'huevo', type: 'carne', portion: '50g'),
    Ingredient(name: 'cacahuate', type: 'carne', portion: '50g'),
    Ingredient(name: 'res', type: 'carne', portion: '50g'),
    Ingredient(name: 'uva', type: 'fruta', portion: '50g'),
    Ingredient(name: 'sandia', type: 'fruta', portion: '50g'),
    Ingredient(name: 'manzana', type: 'fruta', portion: '50g'),
    Ingredient(name: 'naranja', type: 'fruta', portion: '50g'),
    Ingredient(name: 'piña', type: 'fruta', portion: '50g'),
    Ingredient(name: 'mango', type: 'fruta', portion: '50g'),
    Ingredient(name: 'pera', type: 'fruta', portion: '50g'),
    Ingredient(name: 'platano', type: 'fruta', portion: '50g'),
  ];

  final List<Ingredient> selectedIngredients = [];

  // Función para manejar la eliminación de ingredientes
  void removeIngredientFromPlate(Ingredient ingredient) {
    setState(() {
      selectedIngredients.remove(ingredient);
      ingredients.add(ingredient);
    });
  }

  final Map<String, String> categoryMap = {
    'Verduras': 'verdura',
    'Frutas': 'fruta',
    'Carnes/Proteína': 'carne',
    'Pan/Fécula/Granos': 'pan',
  };

  final List<String> categories = [
    'Verduras',
    'Frutas',
    'Carnes/Proteína',
    'Pan/Fécula/Granos',
  ];

  String selectedCategory = 'Verduras';

  bool hasCompletedMeal() {
    final typesInPlate = selectedIngredients.map((i) => i.type).toSet();
    return typesInPlate.containsAll(['verdura', 'fruta', 'pan', 'carne']);
  }

  double calculateCompletionPercentage() {
    final requiredTypes = {'verdura', 'fruta', 'carne', 'pan'};
    final typesInPlate = selectedIngredients.map((i) => i.type).toSet();
    final matchedTypes = typesInPlate.intersection(requiredTypes).length;
    return (matchedTypes / requiredTypes.length) * 100;
  }

  Color getProgressBarColor(double percentage) {
    if (percentage < 50) {
      return Colors.red;
    } else if (percentage < 75) {
      return Colors.orange;
    } else if (percentage < 100) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  void onFinishedButtonPressed() {
    if (hasCompletedMeal()) {
      updateBalancedMealsCount(); // Actualizar en Firebase

      // Redirigir a la pantalla 'Ganar'
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Ganar()),
      );
    } else {
      final percentage = calculateCompletionPercentage();

      // Mostrar un AlertDialog centrado
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "¡Casi lo logras!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.bold, // Aquí se establece el tamaño del texto
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // Asegura que el contenido no ocupe más espacio del necesario
            children: [
              // Centrar horizontalmente el texto con TextAlign.center
              const Text(
                "Aún no es un plato equilibrado, añade más variedad de alimentos saludables.",
                textAlign: TextAlign.center, // Centrar el texto
                style: TextStyle(
                  fontSize: 20, // Aquí se establece el tamaño del texto
                ),
              ),
              const SizedBox(
                  height: 10), // Espaciado entre el texto y la imagen
              // Centrar horizontalmente la imagen
              Center(
                child: Image.asset(
                  'assets/imagenes/perder.png',
                  width: 250,
                  height: 150,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredIngredients = ingredients
        .where((ingredient) => ingredient.type == categoryMap[selectedCategory])
        .toList();

    final percentage = calculateCompletionPercentage();
    final progressBarColor = getProgressBarColor(percentage);

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: const Text(
            '¡Elige tus ingredientes!',
            style: TextStyle(
              fontSize: 30,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          child: Container(
            height: 8.0,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Mostrar las categorías con ChoiceChip
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0), // Espaciado entre los chips
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: selectedCategory == category
                              ? Colors.white
                              : Colors
                                  .black, // Cambiar color del texto según la selección
                        ),
                      ),
                      selected: selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      selectedColor:
                          Colors.green, // Color verde cuando está seleccionado
                      backgroundColor: Colors.grey[
                          300], // Color de fondo cuando no está seleccionado
                      labelStyle: TextStyle(fontSize: 16), // Tamaño de texto
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Mostrar los ingredientes filtrados según la categoría seleccionada
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: filteredIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = filteredIngredients[index];
                return Draggable<Ingredient>(
                  data: ingredient,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          'assets/imagenes/${ingredient.name.toLowerCase()}.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ingredient.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),                      
                    ],
                  ),
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: Image.asset(
                        'assets/imagenes/${ingredient.name.toLowerCase()}.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: Image.asset(
                        'assets/imagenes/${ingredient.name.toLowerCase()}.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          DragTarget<Ingredient>(
            onAccept: (ingredient) {
              if (selectedIngredients.length < 12) {
                setState(() {
                  selectedIngredients.add(ingredient);
                  ingredients.remove(ingredient);
                });
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("¡Límite alcanzado!"),
                    content: const Text(
                        "Solo puedes agregar un máximo de 12 ingredientes."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cerrar"),
                      ),
                    ],
                  ),
                );
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/imagenes/plato.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: selectedIngredients.map<Widget>((ingredient) {
                      return Draggable<Ingredient>(
                        data: ingredient,
                        onDragCompleted: () {
                          // Si se suelta fuera, se elimina del plato
                          removeIngredientFromPlate(ingredient);
                        },
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Permitir eliminar ingrediente al presionar
                                removeIngredientFromPlate(ingredient);
                              },
                              child: Image.asset(
                                'assets/imagenes/${ingredient.name.toLowerCase()}.png',
                                height: 60,
                                width: 60,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ingredient.portion, // Mostrar la porción
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: Image.asset(
                              'assets/imagenes/${ingredient.name.toLowerCase()}.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: onFinishedButtonPressed,
              child: const Text("Terminado"),
            ),
          ),
        ],
      ),
    );
  }
}

class Ingredient {
  final String name;
  final String type;
  final String portion;

  Ingredient({required this.name, required this.type, required this.portion});
}
