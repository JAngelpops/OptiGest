import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Vendedor/views/lista_provedores.dart';

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
  final int _limit = 16;
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
                _buildTextField('Precio', _precioController,keyboardType: TextInputType.number),
                _buildTextField('Costo', _costoController,keyboardType: TextInputType.number),
                _buildTextField('Mica', _micaController,keyboardType: TextInputType.number), 
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
              foregroundColor: const Color(0xFFD4AF37),
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
      borderSide: BorderSide(color: Color(0xFFD4AF37), width: 2),
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


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.nombre, style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      centerTitle: true,
      automaticallyImplyLeading: false,
    ),
    body: _micas.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _micas.isEmpty
            ? const Center(child: Text('No hay micas registradas para este proveedor'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Determinar el número de columnas basado en el ancho de pantalla
                  final crossAxisCount = constraints.maxWidth > 600 ? 5 : 3;
                  // Cálculos responsivos ajustados según el número de columnas
                  final cardWidth = constraints.maxWidth / crossAxisCount - 20;
                  final smallIconSize = cardWidth * 0.12;
                  final titleSize = cardWidth * 0.07;
                  final detailSize = cardWidth * 0.05;
                  // Ajustar el aspect ratio según el número de columnas
                  final childAspectRatio = crossAxisCount == 5 ? 1.3 : 1.1;

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: _micas.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _micas.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var mica = _micas[index].data() as Map<String, dynamic>? ?? {};

                      return InkWell(
                        onTap: () {
                          mica['id'] = _micas[index].id;
                          _mostrarFormularioEdicion(mica);
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Nombre de la mica
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Text(
                                      '${mica['nombre'] ?? 'Sin nombre'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: titleSize.clamp(10, 14),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                // Fila de material con icono
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.layers,
                                        size: smallIconSize.clamp(10, 16),
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${mica['material'] ?? 'Sin material'}',
                                          style: TextStyle(
                                            fontSize: detailSize.clamp(8, 10),
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Fila de precio con icono
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: smallIconSize.clamp(10, 16),
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${mica['precio'] ?? 'Sin precio'}',
                                          style: TextStyle(
                                            fontSize: detailSize.clamp(8, 10),
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Botón de edición
                                IconButton(
                                  iconSize: smallIconSize.clamp(12, 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                                  onPressed: () {
                                    mica['id'] = _micas[index].id;
                                    _mostrarFormularioEdicion(mica);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => widget.onNavigate(ListaProveedores(onNavigate: widget.onNavigate)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    ),
  );}
}