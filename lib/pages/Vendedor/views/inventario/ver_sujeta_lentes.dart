import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Vendedor/views/inventario/lista_sujeta_lentes.dart';

class VerSujetaLentes extends StatefulWidget {
  final Function(Widget) onNavigate;
  final String sujetaLentesId;
  final String tipo; 

  const VerSujetaLentes({
  super.key,
  required this.sujetaLentesId,
  required this.tipo,
  required this.onNavigate
  });

  @override
  State<VerSujetaLentes> createState() => _VerSujetaLentesState();
}

class _VerSujetaLentesState extends State<VerSujetaLentes> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _sujetaLentes = [];
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
 
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _piezasController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSujetaLentes();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadSujetaLentes();
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
    _materialController.dispose();
    _colorController.dispose;
    super.dispose();
  }

  Future<void> _loadSujetaLentes() async {
  if (_isLoading || !_hasMore) return;

  setState(() {
    _isLoading = true;
  });

  try {
    Query query = _firestore
        .collection('sujetaLentes')
        .doc(widget.sujetaLentesId)
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
          _sujetaLentes.addAll(querySnapshot.docs);
          for (var doc in querySnapshot.docs) {
            print("sujeta lente: ${doc.id} -> ${doc.data()}");
          }
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Error al cargar los sujeta lentes: $e");
    setState(() {
      _isLoading = false;
    });
  }
}

  void _mostrarFormularioEdicion(Map<String, dynamic> sujetaLente) {
    _tipoController.text = sujetaLente['modelo']?.toString() ?? 'Sin Modelo';
    _materialController.text= sujetaLente['material']?.toString() ?? 'Sin material';
    _colorController.text = sujetaLente['color']?.toString() ?? 'Sin color';
    _precioController.text = sujetaLente['precio']?.toString() ?? '0';
    _costoController.text = sujetaLente['costo']?.toString() ?? '0';
    _piezasController.text = sujetaLente['piezas']?.toString() ?? '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          'Editar Sujeta lente',
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
                _buildTextField('material', _materialController),
                _buildTextField('color', _colorController),
                _buildTextField('Precio', _precioController, keyboardType: TextInputType.number),
                _buildTextField('Costo', _costoController, keyboardType: TextInputType.number),
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
    DocumentSnapshot sujetaLenteDoc = await _firestore
        .collection('sujetaLentes')
        .doc(widget.sujetaLentesId)
        .collection('caracteristicas')
        .doc(sujetaLente['id'])
        .get();

    if (!sujetaLenteDoc.exists) {
      print("⚠️ El sujeta lente con ID ${sujetaLente['id']} no existe en Firestore.");
      return;
    }

    print("✅ Documento encontrado, procediendo a actualizar.");

    await _firestore
        .collection('sujetaLentes')
        .doc(widget.sujetaLentesId)
        .collection('caracteristicas')
        .doc(sujetaLente['id'])
        .update({
      'modelo': _tipoController.text,
      'color': _colorController.text,
      'material': _materialController.text,
      'precio': double.tryParse(_precioController.text) ?? 0,
      'costo': double.tryParse(_costoController.text) ?? 0,
      'piezas': _piezasController.text
    });

    print("✅ Actualización exitosa.");

    setState(() {
      _sujetaLentes = [];
      _lastDocument = null;
      _hasMore = true;
    });

    _loadSujetaLentes();
    Navigator.pop(context);
  } catch (e) {
    print("❌ Error al actualizar los sujeta lentes: $e");
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
    body: _sujetaLentes.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _sujetaLentes.isEmpty
            ? const Center(child: Text('No hay sujeta lentes registrados'))
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
                    itemCount: _sujetaLentes.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _sujetaLentes.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var sujetaLente = _sujetaLentes[index].data() as Map<String, dynamic>? ?? {};

                      return InkWell(
                        onTap: () {
                          sujetaLente['id'] = _sujetaLentes[index].id;
                          _mostrarFormularioEdicion(sujetaLente);
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
                                // Modelo del sujeta lentes
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Text(
                                      sujetaLente['modelo'] ?? 'Sin modelo',
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
                                // Color del sujeta lentes
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.palette,
                                        size: smallIconSize.clamp(10, 16),
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${sujetaLente['color'] ?? 'Sin color'}',
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
                                // Material del sujeta lentes
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
                                          '${sujetaLente['material'] ?? 'Sin material'}',
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
                                // Precio del sujeta lentes
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
                                          '\$${sujetaLente['precio'] ?? '0'}',
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
                                    sujetaLente['id'] = _sujetaLentes[index].id;
                                    _mostrarFormularioEdicion(sujetaLente);
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
      onPressed: () => widget.onNavigate(ListaSujetaLentes(onNavigate: widget.onNavigate)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    ),
  );
}
}