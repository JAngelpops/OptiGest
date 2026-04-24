import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Administrador/views/ver_micas.dart';
import 'package:inventario/services/database_services.dart';
import 'package:inventario/pages/Administrador/views/provedores.dart'; 

class EditarProveedor extends StatefulWidget {
  final String proveedorId;
  final String nombre;
  final String email;
  final String telefono;
  final Function(Widget) onNavigate;

  const EditarProveedor({
    super.key,
    required this.proveedorId,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.onNavigate,
  });

  @override
  State<EditarProveedor> createState() => _EditarProveedorState();
}

class _EditarProveedorState extends State<EditarProveedor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  final _micaNombreController = TextEditingController();
  final _micaPrecioController = TextEditingController();
  final _micaTratamientoController = TextEditingController();
  final _micaMicaController = TextEditingController();
  final _micaMaterialController = TextEditingController();
  final _formKeyMica = GlobalKey<FormState>();
  final _micaCosto = TextEditingController();
  
  final DatabaseServices _databaseServices = DatabaseServices();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombre);
    _emailController = TextEditingController(text: widget.email);
    _telefonoController = TextEditingController(text: widget.telefono);

  }

  

  void _editarProveedor() async {
  if (!(_formKey.currentState?.validate() ?? false) || _isSaving) return;

  setState(() => _isSaving = true);

  final String nombre = _nombreController.text.trim();
  final String email = _emailController.text.trim();
  final String telefono = _telefonoController.text.trim();

  final proveedorData = {
    'nombre': nombre,
    'email': email,
    'telefono': telefono,
    'timestamp': FieldValue.serverTimestamp(),
  };

  try {
    await _databaseServices.updateProveedor(widget.proveedorId, proveedorData);
    
    if (mounted) {
      Navigator.pop(context); // Cierra el AlertDialog antes de navegar
      widget.onNavigate(Provedores(onNavigate: widget.onNavigate));
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar proveedor: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
void _eliminarProveedor() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Eliminar'),
      content: const Text('¿Estás seguro de que deseas eliminar este proveedor? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _databaseServices.deleteProveedor(widget.proveedorId); 
              if (mounted) {
                Navigator.pop(context); 
                widget.onNavigate(Provedores(onNavigate: widget.onNavigate)); 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proveedor eliminado con éxito')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar proveedor: $e')),
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


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.nombre, style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      centerTitle: true,
      automaticallyImplyLeading: false,
    ),
 body: SingleChildScrollView(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start, // 🔹 Alinea todo hacia arriba
    children: [
      const SizedBox(height: 40), // 🔹 Ajusta la altura superior (reduce si es necesario)
      Center( 
        child: Wrap(
          alignment: WrapAlignment.center, 
          spacing: 50, // 🔹 Espaciado más pequeño entre cards
          runSpacing: 30, // 🔹 Espaciado vertical reducido
          children: [
            _buildCardEditar(Icons.edit, 'Editar', _mostrarFormularioEdicion),
            _buildCardVer(Icons.visibility, 'Ver', () => _cargarMicas(widget.proveedorId, widget.nombre)),
            _buildCardAgregar(Icons.add, 'Agregar', _agregarMica),
          ],
        ),
      ),
      const SizedBox(height: 150),
      Center(
        child: IconButton(
          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 17, 0), size: 40),
          onPressed: _eliminarProveedor,
          tooltip: 'Eliminar Armazón',
        ),
      ),
    ],
  ),
),

    floatingActionButton: FloatingActionButton(
      onPressed: () {
        widget.onNavigate(Provedores(onNavigate: widget.onNavigate));
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
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
                _buildTextField('Nombre', _nombreController),
                _buildTextField('Email', _emailController),
                _buildTextField('Teléfono', _telefonoController),
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
          onPressed: _isSaving ? null : _editarProveedor,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFFD4AF37),
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

void _cargarMicas(String proveedorId, String nombre) {
  widget.onNavigate(VerMicas(
    onNavigate: widget.onNavigate, 
    proveedorId: proveedorId,
    nombre: nombre, 
  ));
}


  void _agregarMica() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
           // maxHeight: MediaQuery.of(context).size.height * 0.75, // 🔹 Ajusta altura
            maxWidth: MediaQuery.of(context).size.width * 0.4, // 🔹 Aumenta ancho
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nueva Mica',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Form(
                  key: _formKeyMica,
                  child: Column(
                    children: [
                      _buildTextField('Nombre', _micaNombreController),
                      _buildTextField('Material', _micaMaterialController),
                      _buildTextField('Tratamiento', _micaTratamientoController),
                       _buildTextField('Mica', _micaMicaController),
                      _buildTextField('Precio', _micaPrecioController, keyboardType: TextInputType.number),
                      _buildTextField('Costo', _micaCosto, keyboardType: TextInputType.number),
                     
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
                        if (!_formKeyMica.currentState!.validate()) return;

                        final nuevaMica = {
                          'nombre': _micaNombreController.text.trim(),
                          'material': _micaMaterialController.text.trim(),
                          'tratamiento': _micaTratamientoController.text.trim(),
                          'mica': _micaMicaController.text.trim(),
                          'precio': double.tryParse(_micaPrecioController.text.trim()) ?? 0.0,
                          //'stock': int.tryParse(_micaStockController.text.trim()) ?? 0,
                          'costo': double.tryParse(_micaCosto.text.trim()) ?? 0,
                          'timestamp': FieldValue.serverTimestamp(),
                        };

                        try {
                          await FirebaseFirestore.instance
                              .collection('proveedores')
                              .doc(widget.proveedorId)
                              .collection('micas')
                              .add(nuevaMica);

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mica agregada con éxito')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al agregar mica: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFFD4AF37),
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