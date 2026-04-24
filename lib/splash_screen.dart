import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventario/pages/home_page.dart';
import 'package:inventario/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 5));
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FirebaseAuth.instance.currentUser == null
            ? const LoginPage()
            : const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo negro por si el GIF no cubre completamente
          Container(color: Colors.black),
          
          // GIF que ocupa toda la pantalla
          Positioned.fill(
            child: Image.asset(
              'assets/splashOpti.gif',
              gaplessPlayback: true,
              fit: BoxFit.cover, // Cambiado de contain a cover
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}