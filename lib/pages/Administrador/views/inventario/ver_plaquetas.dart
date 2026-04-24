import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Administrador/views/inventario/lista_plaquetas.dart';

class VerPlaquetas extends StatefulWidget {
  final Function(Widget) onNavigate;
  final String plaquetaId;
  final String tipo; 

  const VerPlaquetas({super.key,
  required this.plaquetaId,
  required this.tipo, 
  required this.onNavigate});

  @override
  State<VerPlaquetas> createState() => _VerPlaquetasState();
}

class _VerPlaquetasState extends State<VerPlaquetas> {
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _plaquetas = [];
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
 
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _piezasController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlaquetas();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadPlaquetas();
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
    super.dispose();
  }

  Future<void> _loadPlaquetas() async {
  if (_isLoading || !_hasMore) return;

  setState(() {
    _isLoading = true;
  });

  try {
    Query query = _firestore
        .collection('plaquetas')
        .doc(widget.plaquetaId)
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
          _plaquetas.addAll(querySnapshot.docs);
          for (var doc in querySnapshot.docs) {
            print("plaqueta: ${doc.id} -> ${doc.data()}");
          }
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Error al cargar las plaquetas: $e");
    setState(() {
      _isLoading = false;
    });
  }
}

  void _mostrarFormularioEdicion(Map<String, dynamic> plaqueta) {
    _tipoController.text = plaqueta['modelo']?.toString() ?? 'Sin Modelo';
    _precioController.text = plaqueta['precio']?.toString() ?? '0';
    _costoController.text = plaqueta['costo']?.toString() ?? '0';
    _piezasController.text = plaqueta['piezas']?.toString() ?? '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          'Editar Plaqueta',
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
    DocumentSnapshot plaquetaDoc = await _firestore
        .collection('plaquetas')
        .doc(widget.plaquetaId)
        .collection('caracteristicas')
        .doc(plaqueta['id'])
        .get();

    if (!plaquetaDoc.exists) {
      print("⚠️ El plaqueta con ID ${plaqueta['id']} no existe en Firestore.");
      return;
    }

    print("✅ Documento encontrado, procediendo a actualizar.");

    await _firestore
        .collection('plaquetas')
        .doc(widget.plaquetaId)
        .collection('caracteristicas')
        .doc(plaqueta['id'])
        .update({
      'modelo': _tipoController.text,
      'precio': double.tryParse(_precioController.text) ?? 0,
      'costo': double.tryParse(_costoController.text) ?? 0,
      'piezas': _piezasController.text
    });

    print("✅ Actualización exitosa.");

    setState(() {
      _plaquetas = [];
      _lastDocument = null;
      _hasMore = true;
    });

    _loadPlaquetas();
    Navigator.pop(context);
  } catch (e) {
    print("❌ Error al actualizar la plaquetas: $e");
  }
},

            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder( 
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
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

void _eliminarPlaqueta(String plaquetaId) async {
  showDialog(
    //barrierColor: Colors.white,
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Eliminar'),
      content: const Text('¿Estás seguro de que deseas eliminar esta plaqueta?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _firestore
                  .collection('plaquetas')
                  .doc(widget.plaquetaId)
                  .collection('caracteristicas')
                  .doc(plaquetaId)
                  .delete();

              if (mounted) {
                setState(() {
                  _plaquetas.removeWhere((plaqueta) => plaqueta.id == plaquetaId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plaqueta eliminada con éxito')),
                );
              }
            } catch (e) {
              print(" Error al eliminar la plaqueta: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar plaqueta: $e')),
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
    body: _plaquetas.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _plaquetas.isEmpty
            ? const Center(child: Text('No hay plaquetas registradas'))
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
                    itemCount: _plaquetas.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _plaquetas.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var plaqueta = _plaquetas[index].data() as Map<String, dynamic>? ?? {};

                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            plaqueta['id'] = _plaquetas[index].id;
                            _mostrarFormularioEdicion(plaqueta);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Modelo de la plaqueta
                                Flexible(
                                  child: Text(
                                    plaqueta['modelo'] ?? 'Sin modelo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: titleSize.clamp(10, 14),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Piezas
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.layers,
                                        size: smallIconSize.clamp(10, 16),
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${plaqueta['piezas'] ?? 'Sin piezas'}',
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
                                // Precio
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
                                          '\$${plaqueta['precio'] ?? '0'}',
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
                                        plaqueta['id'] = _plaquetas[index].id;
                                        _mostrarFormularioEdicion(plaqueta);
                                      },
                                    ),
                                    IconButton(
                                      iconSize: smallIconSize.clamp(10, 22),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _eliminarPlaqueta(_plaquetas[index].id),
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
      onPressed: () => widget.onNavigate(ListaPlaquetas(onNavigate: widget.onNavigate)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    ),
  );
}
}