import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Administrador/views/inventario/lista_soluciones_limpiadoras.dart';

class VerSoluciones extends StatefulWidget {
  final Function(Widget) onNavigate;
  final String solucionId;
  final String tipo;

  const VerSoluciones({
  super.key,
  required this.solucionId,
  required this.tipo,
  required this.onNavigate});

  @override
  State<VerSoluciones> createState() => _VerSolucionesState();
}

class _VerSolucionesState extends State<VerSoluciones> {
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
        .collection('solucionesLimpiadoras')
        .doc(widget.solucionId)
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
    print("Error al cargar los soluciones: $e");
    setState(() {
      _isLoading = false;
    });
  }
}

  void _mostrarFormularioEdicion(Map<String, dynamic> solucion) {
    _tipoController.text = solucion['tipo']?.toString() ?? 'Sin Modelo';
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
                _buildTextField('tipo', _tipoController),
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
    DocumentSnapshot solucionDoc = await _firestore
        .collection('solucionesLimpiadoras')
        .doc(widget.solucionId)
        .collection('caracteristicas')
        .doc(solucion['id'])
        .get();

    if (!solucionDoc.exists) {
      print("⚠️ El solucion con ID ${solucion['id']} no existe en Firestore.");
      return;
    }

    print("✅ Documento encontrado, procediendo a actualizar.");

    await _firestore
        .collection('solucionesLimpiadoras')
        .doc(widget.solucionId)
        .collection('caracteristicas')
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



void _eliminarSolucion(String solucionId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Eliminar'),
      content: const Text('¿Estás seguro de que deseas eliminar esta solución? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color:  Colors.black)),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _firestore
                  .collection('solucionesLimpiadoras')
                  .doc(widget.solucionId)
                  .collection('caracteristicas')
                  .doc(solucionId)
                  .delete();

              if (mounted) {
                setState(() {
                  _soluciones.removeWhere((solucion) => solucion.id == solucionId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Solución eliminada con éxito')),
                );
              }
            } catch (e) {
              print("❌ Error al eliminar solución: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar solución: $e')),
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
      title: Text(
        widget.tipo,
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold
        )
      ),
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
                  final titleSize = cardWidth * 0.08;
                  final detailSize = cardWidth * 0.06;
                  final childAspectRatio = crossAxisCount == 5 ? 1.2 : 1.1;

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

                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            solucion['id'] = _soluciones[index].id;
                            _mostrarFormularioEdicion(solucion);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Tipo de solución
                                Flexible(
                                  child: Text(
                                    solucion['tipo'] ?? 'Sin Tipo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: titleSize.clamp(12, 16),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                
                                // Precio con icono
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: smallIconSize.clamp(10, 16),
                                        color:  Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${solucion['precio'] ?? '0'}',
                                          style: TextStyle(
                                            fontSize: detailSize.clamp(10, 14),
                                            fontWeight: FontWeight.w500,
                                            color:  Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Costo con icono
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.money_off,
                                        size: smallIconSize.clamp(10, 16),
                                        color:  Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${solucion['costo'] ?? '0'}',
                                          style: TextStyle(
                                            fontSize: detailSize.clamp(10, 14),
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
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
                                        solucion['id'] = _soluciones[index].id;
                                        _mostrarFormularioEdicion(solucion);
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      iconSize: smallIconSize.clamp(10, 22),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _eliminarSolucion(_soluciones[index].id),
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
      onPressed: () => widget.onNavigate(ListaSolucionesLimpiadoras(onNavigate: widget.onNavigate)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    ),
  );
}
}