import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Administrador/views/inventario/lista_tornillos.dart';
import 'package:inventario/pages/Administrador/views/inventario/ver_tornillos.dart';
import 'package:inventario/services/database_services.dart';

class EditarTornillos extends StatefulWidget {
  final String tornilloId;
  final String marca;
  final String correo;
  final String telefono;
  final  Function(Widget) onNavigate;

  const EditarTornillos({
  super.key,
    required this.tornilloId,
    required this.marca,
    required this.correo,
    required this.telefono,
    required this.onNavigate,});

  @override
  State<EditarTornillos> createState() => _EditarTornillosState();
}

class _EditarTornillosState extends State<EditarTornillos> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyTornillo= GlobalKey<FormState>();
  late TextEditingController _correoController;
  late TextEditingController _marcaController;
  late TextEditingController _telefonoController;
  final DatabaseServices _databaseServices = DatabaseServices();
  final _medidaController = TextEditingController() ;
  final _piezasController = TextEditingController() ;
  final _precioController = TextEditingController();
  final _costoController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.marca);
    _correoController = TextEditingController(text: widget.correo);
    _telefonoController = TextEditingController(text: widget.telefono);
  }

  void _editarTornillo() async {
  if (!(_formKey.currentState?.validate() ?? false) || _isSaving) return;

  setState(() => _isSaving = true);

  final String correo = _correoController.text.trim();
  final String marca = _marcaController.text.trim();
  final String telefono = _telefonoController.text.trim();

  final tornilloData = {
    'correo': correo,
    'marca': marca,
    'telefono': telefono,
    'timestamp': FieldValue.serverTimestamp(),
  };

  try {
    print("Actualizando tornillo con ID: ${widget.tornilloId}");
    print("Datos: $tornilloData");

    await _databaseServices.updateTornillo(widget.tornilloId, tornilloData);
    
    print("Actualización exitosa en Firestore");

    if (mounted) {
      Navigator.pop(context);
      widget.onNavigate(EditarTornillos(
        tornilloId: widget.tornilloId,
        correo: correo,
        marca: marca,
        telefono: telefono,
        onNavigate: widget.onNavigate,
      ));
    }
  } catch (e) {
    print("Error al actualizar en Firestore: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar tornillo: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}

// 🔥 Método para eliminar un tornillo
void _eliminarTornillo() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Eliminar'),
      content: const Text('¿Estás seguro de que deseas eliminar este tornillo?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _databaseServices.deleteTornillo(widget.tornilloId);
              if (mounted) {
                Navigator.pop(context);
                widget.onNavigate(ListaTornillos(onNavigate: widget.onNavigate));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tornillo eliminado con éxito')),
                );
              }
            } catch (e) {
              print("Error al eliminar tornillo: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar tornillo: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0),
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.marca, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      centerTitle: true,
      automaticallyImplyLeading: false,
    ),
    body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 🔹 Alinear todo arriba
        children: [
          const SizedBox(height: 40), // 🔹 Espaciado superior

          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 50, // 🔹 Espaciado horizontal entre tarjetas
              runSpacing: 30, // 🔹 Espaciado vertical entre tarjetas
              children: [
                _buildCardEditar(Icons.edit, 'Editar Tornillo', _mostrarFormularioEdicion),
                _buildCardVer(Icons.visibility, 'Ver Tornillos', () => _verTornillos(widget.tornilloId, widget.marca)),
                _buildCardAgregar(Icons.add, 'Agregar Tornillo', _agregarTornillo),
              ],
            ),
          ),

          const SizedBox(height: 150), // 🔹 Espaciado antes del botón de eliminar

          Center(
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 40),
              onPressed: _eliminarTornillo,
              tooltip: 'Eliminar Tornillo',
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      elevation: 0,
      onPressed: () {
        widget.onNavigate(ListaTornillos(onNavigate: widget.onNavigate));
      },
      backgroundColor: Colors.transparent,
      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF131443)),
    ),
  );
}


 Widget _buildCardEditar(IconData icon, String text, VoidCallback onTap) {
  return Card(
    color: Colors.black, 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
    elevation: 5, 
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12), 
      child: Container(
        width: 180,
        height: 180,
        padding: const EdgeInsets.all(16), 
        decoration: BoxDecoration(
          color: Colors.black, 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildCardVer(IconData icon, String text, VoidCallback onTap) {
    return Card(
    color: Color(0xFFD4AF37), 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
    elevation: 5, 
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12), 
      child: Container(
        width: 180,
        height: 180,
        padding: const EdgeInsets.all(16), 
        decoration: BoxDecoration(
          color: Color(0xFFD4AF37), 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildCardAgregar(IconData icon, String text, VoidCallback onTap) {
    return Card(
    color: Colors.black, 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
    elevation: 5, 
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12), 
      child: Container(
        width: 180,
        height: 180,
        padding: const EdgeInsets.all(16), 
        decoration: BoxDecoration(
          color: Colors.black, 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  void _mostrarFormularioEdicion() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.all(20),
      title: const Text(
        'Editar',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView( // 🔹 Permite hacer scroll si el teclado cubre contenido
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5, // 🔹 Limita la altura máxima
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Marca', _marcaController),
                _buildTextField('Email', _correoController),
                _buildTextField('Teléfono', _telefonoController,keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _editarTornillo,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFD4AF37),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              //side: const BorderSide(color: Color(0xFF1A578A)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _isSaving
              ? const CircularProgressIndicator(color: Color(0xFFD4AF37))
              : const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}


  void _verTornillos(String tornilloId, String medida) {
    widget.onNavigate(VerTornillos(
    onNavigate: widget.onNavigate, 
    tornilloId: tornilloId,
    medida: medida, 
  ));
  }

  void _agregarTornillo() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.4, // 🔹 Aumenta ancho
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nuevo tornillo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Form(
                  key: _formKeyTornillo,
                  child: Column(
                    children: [
                      _buildTextField('Medida', _medidaController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                      _buildTextField('Piezas', _piezasController, keyboardType: TextInputType.number), // ✅ Teclado numérico
                      _buildTextField('Precio', _precioController, keyboardType: TextInputType.numberWithOptions(decimal: true)), // ✅ Permite decimales
                      _buildTextField('Costo', _costoController, keyboardType: TextInputType.numberWithOptions(decimal: true)), // ✅ Permite decimales
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: Colors.black),
                      child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKeyTornillo.currentState!.validate()) return;

                        final nuevaMica = {
                          'medida': _medidaController.text.trim(),
                          'precio': double.tryParse(_precioController.text.trim()) ?? 0.0,
                          'piezas': int.tryParse(_piezasController.text.trim()) ?? 0,
                          'costo': double.tryParse(_costoController.text.trim()) ?? 0,
                          'timestamp': FieldValue.serverTimestamp(),
                        };

                        try {
                          await FirebaseFirestore.instance
                              .collection('tornillos')
                              .doc(widget.tornilloId)
                              .collection('caracteristicas')
                              .add(nuevaMica);

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tornillo agregado con éxito')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al agregar tornillo: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

InputDecoration customInputDecoration({String? labelText, String? errorText}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(color: Colors.grey),
    floatingLabelStyle: TextStyle(color: Colors.grey),
    errorText: errorText,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Color(0xFF1A578A), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.red, width: 2),
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
}