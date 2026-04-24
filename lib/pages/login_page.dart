import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventario/pages/cambiar_contrasena.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "Correo no registrado";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Contraseña incorrecta";
      } else {
        errorMessage = "Error al iniciar sesión: ${e.message}";
      }
      _showErrorDialog(context, errorMessage);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error de inicio de sesión"),
          content: Text('Usuario o contraseña incorrectos'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Aceptar", style: TextStyle(color: Color(0xFFD4AF37)),),
            ),
          ],
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo no puede estar vacío';
    } else if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+').hasMatch(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña no puede estar vacía';
    } else if (value.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe contener al menos una mayúscula';
    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe contener al menos una minúscula';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener al menos un número';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🔹 Fondo blanco
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white, // 🔹 Tarjeta blanca
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 400,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset("assets/LogoBlanco.png", height: 80),
                      const SizedBox(height: 10),
                      const Text(
                        "Iniciar Sesión",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        "Correo electrónico",
                        _emailController,
                        icon: Icons.email,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "Contraseña",
                        _passwordController,
                        icon: Icons.lock,
                        isPassword: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD4AF37), // 🔹 Botón amarillo
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                        child: const Text(
                          "Iniciar Sesión",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                        child: const Text(
                          "¿No tienes cuenta? Regístrate",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RecuperarContrasenaScreen()),
                        ),
                        child: const Text(
                          "¿Olvidaste tu contraseña?",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.transparent,
          prefixIcon: Icon(icon, color: Color(0xFFD4AF37)), // 🔹 Ícono amarillo
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFFD4AF37),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD4AF37)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
        validator: validator,
      ),
    );
  }
}