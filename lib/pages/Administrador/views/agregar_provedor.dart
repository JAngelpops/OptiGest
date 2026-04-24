import 'package:flutter/material.dart';
import 'package:inventario/services/database_services.dart';
import 'package:inventario/pages/Administrador/views/provedores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AgregarProvedor extends StatefulWidget {
  final Function(Widget) onNavigate;

  const AgregarProvedor({super.key, required this.onNavigate});

  @override
  State<AgregarProvedor> createState() => _AgregarProvedorState();
}

class _AgregarProvedorState extends State<AgregarProvedor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final DatabaseServices _databaseServices = DatabaseServices();

  bool _isSaving = false;



  Future<bool> _emailOUsuarioExiste(String email, String userId) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('proveedores')
      .where("email", isEqualTo: email)  // 🔹 Verifica si el email ya existe
      .where("idUser", isEqualTo: userId) // 🔹 Solo si pertenece al mismo usuario
      .limit(1) 
      .get();

  return querySnapshot.docs.isNotEmpty;
}



  void _guardarProvedor() async {
  if (!(_formKey.currentState?.validate() ?? false) || _isSaving) return;

  setState(() => _isSaving = true);

  final String nombre = _nombreController.text.trim();
  final String email = _emailController.text.trim();
  final String telefono = _telefonoController.text.trim();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // 🔹 Solo marca error si el email ya existe con el mismo idUser
  bool existe = await _emailOUsuarioExiste(email, userId);
  if (existe) {
    setState(() => _isSaving = false);
    _mostrarAlertaCorreoOUsuarioExistente();
    return;
  }

  final provedorData = {
    'nombre': nombre,
    'email': email,
    'telefono': telefono, 
    'timestamp': FieldValue.serverTimestamp(),
  };

  try {
    await _databaseServices.addProveedor(provedorData);
    widget.onNavigate(Provedores(onNavigate: widget.onNavigate));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar el Proveedor: $e')),
    );
  } finally {
    setState(() => _isSaving = false);
  }
}



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
      title: const Text('Agregar proveedor',
          style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold)),
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
                              _buildTextField('Nombre', _nombreController, validator: _validateNombre),
                              const SizedBox(height: 10),
                              _buildTextField('Email', _emailController, validator: _validateEmail),
                              const SizedBox(height: 10),
                              _buildTextField('Teléfono', _telefonoController, validator: _validateTelefono, keyboardType: TextInputType.phone),
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
                                  onPressed: _isSaving ? null : _guardarProvedor,
                                  child: _isSaving
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
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
          widget.onNavigate(Provedores(onNavigate: widget.onNavigate));
        });
      },
      backgroundColor: Colors.transparent,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    ),
  );
}


  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un email';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  String? _validateNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre no puede estar vacío';
    }
    return null;
  }

  String? _validateTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono no puede estar vacío';
    } else if (value.length != 10) {
      return 'El teléfono debe tener 10 caracteres';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El teléfono solo puede contener números';
    }
    return null;
  }

  void _mostrarAlertaCorreoOUsuarioExistente() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Proveedor ya registrado'),
        content: const Text(
            'El correo ya esta registrado. Intente con otro.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37) )),
          ),
        ],
      );
    },
  );
}
}