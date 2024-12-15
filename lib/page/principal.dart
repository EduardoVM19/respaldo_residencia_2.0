import 'package:buenos_habitos/page/introduccion-biencomer.dart';
import 'package:buenos_habitos/page/platoBuenComer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inicio.dart';
import 'perfil.dart';
import 'novedades.dart';
import 'novedades-admin.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String _userName = '';
  int _daysConnected = 0;
  int _selectedIndex = 0;

  // Lista de pantallas para cada sección del menú
  final List<Widget> _pages = [
    const Inicio(),    // Pantalla principal
    NovedadesScreen(),      // Pantalla de Novedades
    PerfilScreen(),       // Pantalla "Yo"
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;

    if (_user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(_user!.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        setState(() {
          final data = docSnapshot.data();
          _userName = data?['name'] ?? 'Usuario';
          _daysConnected = data?['daysConnected'] ?? 0;
        });
      }
    }
  }

  final List<Widget> _icons = [
    const Icon(Icons.home),
    const Icon(Icons.new_releases),
    const Icon(Icons.person),
  ];

  final List<String> _titles = ['Inicio', 'Novedades', 'Yo'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130.0),
        child: Container(
          margin: const EdgeInsets.only(top: 25),
          child: AppBar(
            title: Row(
              children: [
                Image.asset('assets/imagenes/icono-app.png', width: 100, height: 100),
                const Spacer(),
                Row(
                  children: [
                    Image.asset('assets/imagenes/fuego.png', width: 50, height: 50),
                    const SizedBox(width: 4),
                    Text('$_daysConnected', style: const TextStyle(color: Colors.black)),
                  ],
                ),
              ],
            ),
            centerTitle: true,
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 233, 187, 241),
          ),
        ),
      ),
      body: _pages[_selectedIndex],  // Aquí se muestra la pantalla según el índice seleccionado
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _icons[index],
                  const SizedBox(height: 4),
                  Text(
                    _titles[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      color: _selectedIndex == index ? Colors.purple : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
