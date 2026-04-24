import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Administrador/views/provedores.dart';
import 'package:inventario/services/database_services.dart';

class VerMicas extends StatefulWidget {
  final Function(Widget) onNavigate;
  final String proveedorId;
  final String nombre;

  const VerMicas({super.key, required this.onNavigate, required this.proveedorId, required this.nombre});

  @override
  State<VerMicas> createState() => _VerMicasState();
}

class _VerMicasState extends State<VerMicas> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _micas = [];
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tratamientoController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _micaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final DatabaseServices _databaseServices = DatabaseServices();

  @override
  void initState() {
    super.initState();
    _loadMicas();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMicas();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nombreController.dispose();
    _tratamientoController.dispose();
    _precioController.dispose();
    _costoController.dispose();
    _micaController.dispose();
    _marcaController.dispose();
    super.dispose();
  }

  Future<void> _loadMicas() async {
  if (_isLoading || !_hasMore) return;

  setState(() {
    _isLoading = true;
  });
 
  try {
    Query query = _firestore
        .collection('proveedores')
        .doc(widget.proveedorId)
        .collection('micas')
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (mounted) {
      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
          _micas.addAll(querySnapshot.docs);
          for (var doc in querySnapshot.docs) {
            print("Mica cargada: ${doc.id} -> ${doc.data()}");
          }
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Error al cargar micas: $e");
    setState(() {
      _isLoading = false;
    });
  }
}

  void _mostrarFormularioEdicion(Map<String, dynamic> mica) {
    _nombreController.text = mica['nombre']?.toString() ?? 'Sin nombre';
    _tratamientoController.text = mica['tratamiento']?.toString() ?? 'Sin descripción';
    _precioController.text = mica['precio']?.toString() ?? '0';
    _costoController.text = mica['costo']?.toString() ?? '0';
    _micaController.text = mica['mica']?.toString() ?? 'Sin nombre';
    _materialController.text = mica['material']?.toString() ?? 'Sin material';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          'Editar Mica',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Nombre', _nombreController),
                _buildTextField('Tratamiento', _tratamientoController),
                _buildTextField('Material', _materialController),
                _buildTextField('Precio', _precioController),
                _buildTextField('Costo', _costoController),
                _buildTextField('Mica', _micaController), 
              ],
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
            onPressed: () async {
  try {
    // 🔍 Verificar si el documento existe antes de actualizar
    DocumentSnapshot micaDoc = await _firestore
        .collection('proveedores')
        .doc(widget.proveedorId)
        .collection('micas')
        .doc(mica['id'])
        .get();

    if (!micaDoc.exists) {
      print("⚠️ El documento con ID ${mica['id']} no existe en Firestore.");
      return;
    }

    print("✅ Documento encontrado, procediendo a actualizar.");

    await _firestore
        .collection('proveedores')
        .doc(widget.proveedorId)
        .collection('micas')
        .doc(mica['id'])
        .update({
      'nombre': _nombreController.text,
      'tratamiento': _tratamientoController.text,
      'precio': double.tryParse(_precioController.text) ?? 0,
      'costo': double.tryParse(_costoController.text) ?? 0,
      'mica': _micaController.text ,
      'marca': _marcaController.text,
      'material': _materialController.text
    });

    print("✅ Actualización exitosa.");

    setState(() {
      _micas = [];
      _lastDocument = null;
      _hasMore = true;
    });

    _loadMicas();
    Navigator.pop(context);
  } catch (e) {
    print("❌ Error al actualizar la mica: $e");
  }
},

            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
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


void _eliminarMica(String micaId) async {
  showDialog(
    //barrierColor: Colors.white,
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Eliminar Mica'),
      content: const Text('¿Estás seguro de que deseas eliminar esta mica?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _databaseServices.deleteMica(widget.proveedorId, micaId);

              if (mounted) {
                setState(() {
                  _micas.removeWhere((mica) => mica.id == micaId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mica eliminada con éxito')), 
                );
              }
            } catch (e) {
              print("Error al eliminar mica: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar mica: $e')),
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
        title: Text(widget.nombre,style: TextStyle(color: Colors.black, fontSize: 24,fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _micas.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _micas.isEmpty
              ? const Center(child: Text('No hay micas registradas para este proveedor'))
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _micas.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
  if (index == _micas.length) {
    return const Center(child: CircularProgressIndicator());
  }

  var mica = _micas[index].data() as Map<String, dynamic>? ?? {};
  mica['id'] = _micas[index].id;

  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${mica['nombre'] ?? 'Sin nombre'}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '${mica['material'] ?? 'Sin material'}',
            style: const TextStyle(fontSize: 8),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Precio: ${mica['precio'] ?? 'Sin precio'}',
            style: const TextStyle(fontSize: 8),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // 🔴 NUEVOS BOTONES
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)
 ),
                onPressed: () => _mostrarFormularioEdicion(mica),
                tooltip: 'Editar Mica',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 17, 0)),
                onPressed: () => _eliminarMica(mica['id']),
                tooltip: 'Eliminar Mica',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {widget.onNavigate(Provedores(onNavigate: widget.onNavigate)),},
        backgroundColor: Colors.transparent, elevation: 0,
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black,),
      ),
    );
  }
}