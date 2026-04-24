import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/pages/Administrador/views/inventario/lista_tornillos.dart';

class VerTornillos extends StatefulWidget {
  final Function(Widget) onNavigate;
  final String tornilloId;
  final String medida; 
  const VerTornillos({super.key,
  required this.tornilloId,
  required this.medida,
  required this.onNavigate});

  @override
  State<VerTornillos> createState() => _VerTornillosState();
}

class _VerTornillosState extends State<VerTornillos> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _tornillos = [];
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
 
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _piezasController = TextEditingController();
  final TextEditingController _medidaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTornillos();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadTornillos();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _piezasController.dispose();
    _precioController.dispose();
    _costoController.dispose();
    _medidaController.dispose();
    super.dispose();
  }

  Future<void> _loadTornillos() async {
  if (_isLoading || !_hasMore) return;

  setState(() {
    _isLoading = true;
  });

  try {
    Query query = _firestore
        .collection('tornillos')
        .doc(widget.tornilloId)
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
          _tornillos.addAll(querySnapshot.docs);
          for (var doc in querySnapshot.docs) {
            print("tornillo: ${doc.id} -> ${doc.data()}");
          }
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Error al cargar los tornillos: $e");
    setState(() {
      _isLoading = false;
    });
  }
}

  void _mostrarFormularioEdicion(Map<String, dynamic> tornillo) {
    _medidaController.text = tornillo['medida']?.toString() ?? 'Sin Medida';
    _precioController.text = tornillo['precio']?.toString() ?? '0';
    _costoController.text = tornillo['costo']?.toString() ?? '0';
    _piezasController.text = tornillo['piezas']?.toString() ?? '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          'Editar Tornillo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Medida', _medidaController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
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
    DocumentSnapshot tornilloDoc = await _firestore
        .collection('tornillos')
        .doc(widget.tornilloId)
        .collection('caracteristicas')
        .doc(tornillo['id'])
        .get();

    if (!tornilloDoc.exists) {
      print("⚠️ El tornillo con ID ${tornillo['id']} no existe en Firestore.");
      return;
    }

    print("✅ Documento encontrado, procediendo a actualizar.");

    await _firestore
        .collection('tornillos')
        .doc(widget.tornilloId)
        .collection('caracteristicas')
        .doc(tornillo['id'])
        .update({
      'medida': _medidaController.text,
      'precio': double.tryParse(_precioController.text) ?? 0,
      'costo': double.tryParse(_costoController.text) ?? 0,
      'piezas': _piezasController.text
    });

    print("✅ Actualización exitosa.");

    setState(() {
      _tornillos = [];
      _lastDocument = null;
      _hasMore = true;
    });

    _loadTornillos();
    Navigator.pop(context);
  } catch (e) {
    print("❌ Error al actualizar los tornillos: $e");
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


void _eliminarTornillo(String tornilloId) async {
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
                await _firestore
                    .collection('tornillos')
                    .doc(widget.tornilloId)
                    .collection('caracteristicas')
                    .doc(tornilloId)
                    .delete();

                if (mounted) {
                  setState(() {
                    _tornillos.removeWhere((tornillo) => tornillo.id == tornilloId);
                  });
                  Navigator.pop(context);
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
        widget.medida,
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold
        )
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
    ),
    body: _tornillos.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _tornillos.isEmpty
            ? const Center(child: Text('No hay tornillos registrados'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Configuración responsiva
                  final crossAxisCount = constraints.maxWidth > 600 ? 5 : 3;
                  final cardWidth = constraints.maxWidth / crossAxisCount - 20;
                  final smallIconSize = cardWidth * 0.12;
                  final titleSize = cardWidth * 0.08;
                  final detailSize = cardWidth * 0.06;
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
                    itemCount: _tornillos.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _tornillos.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var tornillo = _tornillos[index].data() as Map<String, dynamic>? ?? {};

                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            tornillo['id'] = _tornillos[index].id;
                            _mostrarFormularioEdicion(tornillo);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Medida del tornillo
                                Flexible(
                                  child: Text(
                                    tornillo['medida'] ?? 'Sin Medida',
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
                                        size: smallIconSize.clamp(12, 16),
                                        color: Colors.grey[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '\$${tornillo['precio'] ?? '0'}',
                                          style: TextStyle(
                                            fontSize: detailSize.clamp(10, 14),
                                            fontWeight: FontWeight.w500,
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
                                        tornillo['id'] = _tornillos[index].id;
                                        _mostrarFormularioEdicion(tornillo);
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      iconSize: smallIconSize.clamp(0,22),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _eliminarTornillo(_tornillos[index].id),
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
      onPressed: () => widget.onNavigate(ListaTornillos(onNavigate: widget.onNavigate)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    ),
  );
}
}