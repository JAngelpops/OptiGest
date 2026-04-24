//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter/services.dart'; 
import 'package:inventario/pages/Administrador/admin_inicio.dart';
import 'package:inventario/pages/Vendedor/vendedor_inicio.dart';
import 'package:inventario/pages/Vendedor/views/finanzas.dart';
import 'package:inventario/pages/Vendedor/views/grafica_venta.dart';
import 'package:inventario/pages/Vendedor/views/nueva_venta.dart';
import 'package:inventario/pages/Vendedor/views/ventas.dart';
import 'package:inventario/pages/login_page.dart';
import 'package:inventario/pages/register_page.dart';
import 'package:inventario/pages/home_page.dart';
import 'package:inventario/splash_screen.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login y Registro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, // Cambia el fondo de toda la app
          appBarTheme: AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white, // Fondo blanco para todos los AppBar
          elevation: 0, // Eliminar sombra del AppBar (opcional)
          iconTheme: IconThemeData(color: Colors.black), // Iconos en negro
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20), // Títulos en negro
        ),
        dialogTheme: const DialogTheme(
    backgroundColor: Colors.white, // 🔹 Fondo blanco para todos los AlertDialog
    shape: RoundedRectangleBorder( // 🔹 Bordes redondeados para un mejor diseño
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Color(0xFFD4AF37), // 🔹 Color dorado para todos los indicadores de carga
  ),
      ),
      
      // Configuración de rutas
      //initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      initialRoute:'/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/admin': (context) => AdminInicio(),
        '/vendedor': (context) => VendedorInicio(),
        '/ventas': (context) => Ventas(),
        '/nuevaVenta': (context) => NuevaVenta(),
        '/graficaVenta': (context) => GraficaVenta(),
        '/finanzas': (context) => Finanzas(),
        

      },
    );
  }
}