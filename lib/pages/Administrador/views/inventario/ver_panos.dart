import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Administrador/views/inventario/lista_panos.dart';

class VerPanos extends StatefulWidget {
  final Function(Widget) onNavigate;
  final String panoId;
  final String tipo; 

  const VerPanos({
  super.key,
  required this.panoId,
  required this.tipo,
  required this.onNavigate
  });

  @override
  State<VerPanos> createState() => _VerPanosState();
}

class _VerPanosState extends State<VerPanos> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _panos = [];
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
 
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _piezasController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _colorController =TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPanos();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadPanos();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _piezasController.dispose();
    _precioController.dispose();
    _costoController.dispose();
    _tipoController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _loadPanos() async {
  if (_isLoading || !_hasMore) return;

  setState(() {
    _isLoading = true;
  });

  try {
    Query query = _firestore
        .collection('panos')
        .doc(widget.panoId)
        .collection('caracteristicas')
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (mounted) {
      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
          _panos.addAll(querySnapshot.docs);
          for (var doc in querySnapshot.docs) {
            print("paño: ${doc.id} -> ${doc.data()}");
          }
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Error al cargar los paños: $e");
    setState(() {
      _isLoading = false;
    });
  }
}

  void _mostrarFormularioEdicion(Map<String, dynamic> pano) {
    _tipoController.text = pano['modelo']?.toString() ?? 'Sin Modelo';
    _colorController.text=pano['color']?.toString() ??'Sin color';
    _precioController.text = pano['precio']?.toString() ?? '0';
    _costoController.text = pano['costo']?.toString() ?? '0';
    _piezasController.text = pano['piezas']?.toString() ?? '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          'Editar Paño',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('modelo', _tipoController),
                _buildTextField('color', _colorController),
                _buildTextField('Precio', _precioController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                _buildTextField('Costo', _costoController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                _buildTextField('Piezas', _piezasController, keyboardType: TextInputType.number), 
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
    DocumentSnapshot panoDoc = await _firestore
        .collection('panos')
        .doc(widget.panoId)
        .collection('caracteristicas')
        .doc(pano['id'])
        .get();

    if (!panoDoc.exists) {
      print("⚠️ El pano con ID ${pano['id']} no existe en Firestore.");
      return;
    }

    print("✅ Documento encontrado, procediendo a actualizar.");

    await _firestore
        .collection('panos')
        .doc(widget.panoId)
        .collection('caracteristicas')
        .doc(pano['id'])
        .update({
      'modelo': _tipoController.text,
      'color':_colorController.text,
      'precio': double.tryParse(_precioController.text) ?? 0,
      'costo': double.tryParse(_costoController.text) ?? 0,
      'piezas': _piezasController.text
    });

    print("✅ Actualización exitosa.");

    setState(() {
      _panos = [];
      _lastDocument = null;
      _hasMore = true;
    });

    _loadPanos();
    Navigator.pop(context);
  } catch (e) {
    print("❌ Error al actualizar el paño: $e");
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


void _eliminarPano(String panoId) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Eliminar'),
      content: const Text('¿Estás seguro de que deseas eliminar este paño?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _firestore
                  .collection('panos')
                  .doc(widget.panoId)
                  .collection('caracteristicas')
                  .doc(panoId)
                  .delete();

              if (mounted) {
                setState(() {
                  _panos.removeWhere((pano) => pano.id == panoId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paño eliminado con éxito')),
                );
              }
            } catch (e) {
              print("Error al eliminar el paño: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar el paño: $e')),
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
      title: Text(widget.tipo, 
        style: TextStyle(
          color: Colors.black, 
          fontSize: 24,
          fontWeight: FontWeight.bold
        )
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
    ),
    body: _panos.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _panos.isEmpty
            ? const Center(child: Text('No hay paños registrados'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Configuración responsiva
                  final crossAxisCount = constraints.maxWidth > 600 ? 5 : 3;
                  final cardWidth = constraints.maxWidth / crossAxisCount - 20;
                  final smallIconSize = cardWidth * 0.12;
                  final titleSize = cardWidth * 0.07;
                  final detailSize = cardWidth * 0.05;
                  final childAspectRatio = crossAxisCount == 5 ? 1.2 : 1.0;

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: _panos.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _panos.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var pano = _panos[index].data() as Map<String, dynamic>? ?? {};

                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            pano['id'] = _panos[index].id;
                            _mostrarFormularioEdicion(pano);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Modelo del paño
                                Flexible(
                                  child: Text(
                                    pano['modelo'] ?? 'Sin modelo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: titleSize.clamp(10, 14),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Color del paño
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.color_lens,
                                        size: smallIconSize.clamp(10, 16),
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          pano['color'] ?? 'Sin color',
                                          style: TextStyle(
                                            fontSize: detailSize.clamp(8, 10),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Precio del paño
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: smallIconSize.clamp(10, 16),
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '\$${pano['precio'] ?? '0'}',
                                          style: TextStyle(
                                            fontSize: detailSize.clamp(8, 10),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Botones de acción
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      iconSize: smallIconSize.clamp(10, 22),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                                      onPressed: () {
                                        pano['id'] = _panos[index].id;
                                        _mostrarFormularioEdicion(pano);
                                      },
                                    ),
                                    IconButton(
                                      iconSize: smallIconSize.clamp(10, 22),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _eliminarPano(_panos[index].id),
                                    ),
                                  ],
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
      onPressed: () => widget.onNavigate(ListaPanos(onNavigate: widget.onNavigate)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    ),
  );
}
}