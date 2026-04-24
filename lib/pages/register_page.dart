import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user!.updateDisplayName(_nameController.text.trim());

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = "El correo ya está registrado";
      } else {
        errorMessage = "Error al registrar: ${e.message}";
      }
      _showErrorDialog(context, errorMessage);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error "),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Aceptar",style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🔹 Fondo blanco
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(0.0),
            child: Card(
              color: Colors.white, // 🔹 Tarjeta blanca
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 400,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      const Text(
                        "Registrarse",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField("Nombre", _nameController, icon: Icons.person, validator: _validateName),
                      _buildTextField("Correo electrónico", _emailController, icon: Icons.email, validator: _validateEmail),
                      _buildTextField("Teléfono", _phoneController, icon: Icons.phone, validator: _validatePhone, keyboardType: TextInputType.phone),
                      _buildTextField("Edad", _ageController, icon: Icons.cake, validator: _validateAge, keyboardType: TextInputType.number),
                      _buildTextField("Contraseña", _passwordController, icon: Icons.lock, isPassword: true, validator: _validatePassword),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD4AF37), // 🔹 Botón amarillo
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                        child: const Text(
                          "Registrarse",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Botón para ir a Login
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text(
                          "¿Ya tienes cuenta? Inicia sesión",
                          style: TextStyle(color: Colors.black),
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

  // Función reutilizable para los campos de entrada
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        keyboardType: keyboardType ?? TextInputType.text,
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

  // Validaciones
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'El nombre no puede estar vacío';
    if (value.length < 3 || value.length > 25) return 'Debe tener entre 3 y 25 caracteres';
    if (RegExp(r'[0-9]').hasMatch(value)) return 'No puede contener números';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo no puede estar vacío';
    if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+').hasMatch(value)) return 'Ingrese un correo válido';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'El teléfono no puede estar vacío';
    if (value.length != 10) return 'Debe tener 10 dígitos';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Solo puede contener números';
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return 'La edad no puede estar vacía';
    int? age = int.tryParse(value);
    if (age == null) return 'Ingrese una edad válida';
    if (age < 1 || age > 80) return 'Debe estar entre 1 y 80 años';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña no puede estar vacía';
    if (value.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Debe contener al menos una mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Debe contener al menos una minúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Debe contener al menos un número';
    return null;
  }
}
