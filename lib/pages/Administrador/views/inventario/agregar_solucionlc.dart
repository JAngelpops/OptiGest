import 'package:flutter/material.dart';
import 'package:inventario/pages/Administrador/views/inventario/soluciones_lc.dart';
import 'package:inventario/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarSolucionlc extends StatefulWidget {
  final Function(Widget) onNavigate;

  const AgregarSolucionlc({super.key, required this.onNavigate});

  @override
  State<AgregarSolucionlc> createState() => _AgregarSolucionlcState();
}

class _AgregarSolucionlcState extends State<AgregarSolucionlc> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  final DatabaseServices _databaseServices = DatabaseServices();

 Future<bool> _emailExiste(String email) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('solucionesLC') // Se cambia la colección a "soluciones_lc"
      .where('correo', isEqualTo: email)
      .limit(1) // Limitar a 1 documento
      .get();

  return querySnapshot.docs.isNotEmpty;
}

void _guardarSolucionLC() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;

  final String marca = _marcaController.text.trim();
  final String correo = _correoController.text.trim();
  final String telefono = _telefonoController.text.trim();

  // Verificar si el correo ya está registrado
  bool existe = await _emailExiste(correo);
  if (existe) {
    _mostrarAlertaCorreoExistente();
    return;
  }

  final solucionLCData = {
    'marca': marca,
    'correo': correo,
    'telefono': telefono,
    'timestamp': FieldValue.serverTimestamp(),
  };

  try {
    await _databaseServices.addSolucionesLC(solucionLCData);
    widget.onNavigate(SolucionesLc(onNavigate: widget.onNavigate));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar la solución L.C.: $e')),
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

  String? _validateMarca(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La marca no puede ser vacia';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 🔹 Evita el error de overflow al abrir el teclado
      appBar: AppBar(
        title: const Text('Agregar solución L.C.', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
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
                  mainAxisSize: MainAxisSize.min, // 🔹 Evita expansión innecesaria
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
                                _buildTextField('Marca', _marcaController, validator: _validateMarca),
                                const SizedBox(height: 10),
                                _buildTextField('Correo', _correoController, validator: _validateEmail),
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
                                    onPressed: _guardarSolucionLC,
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
            widget.onNavigate(SolucionesLc(onNavigate: widget.onNavigate));
          });
        },
        backgroundColor: Colors.transparent,
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
      ),
    );
  }
}