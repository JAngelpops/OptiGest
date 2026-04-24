import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Vendedor/views/inventario/lista_solucioneslc.dart';

class VerSolucionLc extends StatefulWidget {
  final Function(Widget) onNavigate;
  final String solucionId;
  final String marca;
  const VerSolucionLc({super.key, required this.solucionId, required this.marca, required this.onNavigate});

  @override
  State<VerSolucionLc> createState() => _VerSolucionLcState();
}

class _VerSolucionLcState extends State<VerSolucionLc> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _soluciones = [];
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
 
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _piezasController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSoluciones();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadSoluciones();
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

  Future<void> _loadSoluciones() async {
  if (_isLoading || !_hasMore) return;

  setState(() {
    _isLoading = true;
  });

  try {
    Query query = _firestore
        .collection('solucionesLC')
        .doc(widget.solucionId)
        .collection('soluciones')
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (mounted) {
      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
          _soluciones.addAll(querySnapshot.docs);
          for (var doc in querySnapshot.docs) {
            print("solucion: ${doc.id} -> ${doc.data()}");
          }
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Error al cargar soluciones: $e");
    setState(() {
      _isLoading = false;
    });
  }
}

  void _mostrarFormularioEdicion(Map<String, dynamic> solucion) {
    _tipoController.text = solucion['tipo']?.toString() ?? 'Sin tipo';
    _precioController.text = solucion['precio']?.toString() ?? '0';
    _costoController.text = solucion['costo']?.toString() ?? '0';
    _piezasController.text = solucion['piezas']?.toString() ?? '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          'Editar Solucion',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Tipo', _tipoController),
                _buildTextField('Precio', _precioController,keyboardType: TextInputType.number),
                _buildTextField('Costo', _costoController, keyboardType: TextInputType.number),
                _buildTextField('Piezas', _piezasController,keyboardType: TextInputType.number), 
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
    DocumentSnapshot solucionLCDoc = await _firestore
        .collection('solucionesLC')
        .doc(widget.solucionId)
        .collection('soluciones')
        .doc(solucion['id'])
        .get();

    if (!solucionLCDoc.exists) {
      print("⚠️ El documento con ID ${solucion['id']} no existe en Firestore.");
      return;
    }

    print("✅ Documento encontrado, procediendo a actualizar.");

    await _firestore
        .collection('solucionesLC')
        .doc(widget.solucionId)
        .collection('soluciones')
        .doc(solucion['id'])
        .update({
      'tipo': _tipoController.text,
      'precio': double.tryParse(_precioController.text) ?? 0,
      'costo': double.tryParse(_costoController.text) ?? 0,
      'piezas': _piezasController.text
    });

    print("✅ Actualización exitosa.");

    setState(() {
      _soluciones = [];
      _lastDocument = null;
      _hasMore = true;
    });

    _loadSoluciones();
    Navigator.pop(context);
  } catch (e) {
    print("❌ Error al actualizar la solucion: $e");
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
      title: Text(widget.marca, style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      centerTitle: true,
      automaticallyImplyLeading: false,
    ),
    body: _soluciones.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _soluciones.isEmpty
            ? const Center(child: Text('No hay soluciones registradas'))
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
                    itemCount: _soluciones.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _soluciones.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var solucion = _soluciones[index].data() as Map<String, dynamic>? ?? {};

                      return InkWell(
                        onTap: () {
                          solucion['id'] = _soluciones[index].id;
                          _mostrarFormularioEdicion(solucion);
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
                                // Tipo de solución
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Text(
                                      solucion['tipo'] ?? 'Sin tipo',
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
                                // Precio de la solución
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
                                          '\$${solucion['precio'] ?? '0'}',
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
                                // Piezas de la solución
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inventory,
                                        size: smallIconSize.clamp(10, 16),
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${solucion['piezas'] ?? '0'} piezas',
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
                                    solucion['id'] = _soluciones[index].id;
                                    _mostrarFormularioEdicion(solucion);
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
      onPressed: () => widget.onNavigate(ListaSolucioneslc(onNavigate: widget.onNavigate)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    ),
  );
}
}