import 'package:flutter/material.dart'; 
import 'package:inventario/services/database_services.dart'; 
import 'package:inventario/pages/Administrador/views/clientes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarCliente extends StatefulWidget {
  final Function(Widget) onNavigate;

  const AgregarCliente({super.key, required this.onNavigate});

  @override
  State<AgregarCliente> createState() => _AgregarClienteState();
}

class _AgregarClienteState extends State<AgregarCliente> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  
  // Instancia de DatabaseServices
  final DatabaseServices _databaseServices = DatabaseServices();

  Future<bool> _emailExiste(String email) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('clientes') // Se cambia la colección a "clientes"
      .where('email', isEqualTo: email)
      .limit(1) // Limitar a 1 documento
      .get();

  return querySnapshot.docs.isNotEmpty;
}

void _guardarCliente() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;

  final String nombre = _nombreController.text.trim();
  final String email = _emailController.text.trim();
  final String telefono = _telefonoController.text.trim();

  // Verificar si el email ya está registrado
  bool existe = await _emailExiste(email);
  if (existe) {
    _mostrarAlertaCorreoExistente();
    return;
  }

  final clienteData = {
    'nombre': nombre,
    'email': email,
    'telefono': telefono,
    'timestamp': FieldValue.serverTimestamp(),
  };

  try {
    await _databaseServices.addCliente(clienteData);
    widget.onNavigate(Clientes(onNavigate: widget.onNavigate));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar el Cliente: $e')),
    );
  }
}

void _mostrarAlertaCorreoExistente() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Correo ya registrado'),
        content: const Text('El correo ingresado ya está en uso. Intente con otro.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1A578A))),
          ),
        ],
      );
    },
  );
}

  // Función para construir los campos de texto
Widget _buildTextField(String label, TextEditingController controller,
    {String? Function(String?)? validator, TextInputType? keyboardType}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType, // Se agrega esta línea para definir el teclado
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD4AF37)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
      validator: validator,
    ),
  );
}

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 🔹 Evita el overflow cuando aparece el teclado
      appBar: AppBar(
        title: const Text('Agregar cliente', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 🔹 Cierra el teclado al tocar fuera
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9, // 🔹 Controla la altura máxima
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 🔹 Evita que la columna se expanda demasiado
                  children: [
                    SizedBox(
                      width: 350,
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField('Nombre', _nombreController),
                                const SizedBox(height: 10),
                                _buildTextField('Email', _emailController),
                                const SizedBox(height: 10),
                                _buildTextField('Teléfono', _telefonoController, keyboardType: TextInputType.phone),
                                const SizedBox(height: 40),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD4AF37),
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _guardarCliente,
                                    child: const Text(
                                      'Guardar',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          FocusScope.of(context).unfocus(); // 🔹 Cierra el teclado antes de navegar
          Future.delayed(const Duration(milliseconds: 200), () { 
            widget.onNavigate(Clientes(onNavigate: widget.onNavigate));
          });
        },
        backgroundColor: Colors.transparent,
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
      ),
    );
  }
}