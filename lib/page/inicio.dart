import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'platoBuenComer.dart';
import 'introduccion-biencomer.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String _userName = '';
  int _daysConnected = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
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
    } catch (e) {
      print('Error al cargar los datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Bienvenido\n',
                      style: TextStyle(fontSize: 20),
                    ),
                    TextSpan(
                      text: _userName,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              for (var i = 0; i < 5; i++) ...[
                _buildPlatoDelBuenComer(context),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildPlatoDelBuenComer(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      final docSnapshot = await userDoc.get();

      final hasSeenIntro = docSnapshot.exists && docSnapshot.data()?['hasSeenIntro'] == true;

      if (hasSeenIntro) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlatoDelBuenComerApp(),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IntroductionScreen(uid: uid),
          ),
        );
      }
    },
    child: Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/imagenes/plato_buen_comer.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 8),
          const Text(
            'Plato del bien comer',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
