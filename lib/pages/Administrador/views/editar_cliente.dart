import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/services/database_services.dart'; 
import 'package:inventario/pages/Administrador/views/lista_clientes.dart';

class EditarCliente extends StatefulWidget {
  final String clienteId;
  final String nombre;
  final String email;
  final String telefono;
  final Function(Widget) onNavigate;

  const EditarCliente({
    super.key,
    required this.clienteId,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.onNavigate,
  });

  @override
  State<EditarCliente> createState() => _EditarClienteState();
}

class _EditarClienteState extends State<EditarCliente> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;

  final DatabaseServices _databaseServices = DatabaseServices();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombre);
    _emailController = TextEditingController(text: widget.email);
    _telefonoController = TextEditingController(text: widget.telefono);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _editarCliente() async {
  if (_formKey.currentState?.validate() ?? false) {
    final String nombre = _nombreController.text;
    final String email = _emailController.text;
    final String telefono = _telefonoController.text;

    final clienteData = {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'timestamp': FieldValue.serverTimestamp(),
    };

    print("Intentando actualizar cliente en Firestore...");
    print("Cliente ID: ${widget.clienteId}");
    print("Datos a actualizar: $clienteData");

    try {
      await _databaseServices.updateCliente(widget.clienteId, clienteData);
      print("Cliente actualizado correctamente.");
      
      widget.onNavigate(ListaClientes(onNavigate: widget.onNavigate));
      print("Navegación completada.");
    } catch (e) {
      print("Error al actualizar cliente: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar cliente: $e')),
      );
    }
  }
}


  void _eliminarCliente() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que deseas eliminar este cliente? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _databaseServices.deleteCliente(widget.clienteId);
                if (mounted) {
                  Navigator.pop(context); 
                  widget.onNavigate(ListaClientes(onNavigate: widget.onNavigate));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente eliminado con éxito')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar cliente: $e')),
                );
              }
            },
            
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0),
            child: const Text('Eliminar', style: TextStyle(color: Color.fromARGB(255, 255, 17, 0))),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombre, style: TextStyle(color: Colors.black, fontSize: 24,fontWeight: FontWeight.bold) ,),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 350,
              child: Card(
                color: Colors.white,
                //color: const Color.fromARGB(102, 205, 205, 205), // Tarjeta en color gris
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título "Editar Cliente"
                      const Center(
                      ),
                      const SizedBox(height: 15),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField('Nombre', _nombreController),
                            _buildTextField('Email', _emailController),
                            _buildTextField('Teléfono', _telefonoController),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100, // Tamaño del botón Editar
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD4AF37),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed:  _editarCliente,
                                    child: const Text(
                                      'Editar',
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10), // Espacio entre botones
                                SizedBox(
                                  width: 100, // Tamaño del botón Eliminar
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 255, 17, 0),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _eliminarCliente,
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          widget.onNavigate(ListaClientes(onNavigate: widget.onNavigate)); 
        },
        backgroundColor: Colors.transparent, 
        child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF131443)), 
      ),
    );
  }
}