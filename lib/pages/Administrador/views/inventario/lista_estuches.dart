import 'package:flutter/material.dart';
import 'package:inventario/pages/Administrador/views/inventario/editar_estuche.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventario/pages/Administrador/views/inventario/estuches.dart';

class ListaEstuches extends StatefulWidget { 
  final Function(Widget) onNavigate;

  const ListaEstuches({super.key,required this.onNavigate});

  @override
  State<ListaEstuches> createState() => _ListaEstuchesState();
}

class _ListaEstuchesState extends State<ListaEstuches> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<DocumentSnapshot> _estuches = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadEstuches();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadEstuches();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEstuches() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    Query query = _firestore.collection('estuches')
        .where('idUser', isEqualTo: userId)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (mounted) {
      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
          _estuches.addAll(querySnapshot.docs);
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  final String? uid = _auth.currentUser?.uid;

  if (uid == null) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de estuches',
            style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: const Center(child: Text('No hay estuches registrados')),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Lista de estuches',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      centerTitle: true,
      automaticallyImplyLeading: false,
    ),
    body: _estuches.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : LayoutBuilder(
            builder: (context, constraints) {
              // Determinar columnas según ancho de pantalla
              final crossAxisCount = constraints.maxWidth > 600 ? 5 : 3;
              // Cálculos responsivos basados en columnas
              final cardWidth = constraints.maxWidth / crossAxisCount - 20;
              final smallIconSize = cardWidth * 0.12;
              final titleSize = cardWidth * 0.07;
              final detailSize = cardWidth * 0.05;
              // Ajustar aspect ratio según columnas
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
                itemCount: _estuches.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _estuches.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var estucheDoc = _estuches[index];
                  var estuche = estucheDoc.data() as Map<String, dynamic>;
                  var marca = estuche['marca'] ?? 'Sin marca';
                  var correo = estuche['correo'] ?? 'Sin correo';
                  var telefono = estuche['telefono'] ?? 'Sin teléfono';

                  return InkWell(
                    onTap: () {
                      widget.onNavigate(EditarEstuche(
                        estucheId: estucheDoc.id,
                        marca: marca,
                        correo: correo,
                        telefono: telefono,
                        onNavigate: widget.onNavigate,
                      ));
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            Flexible(
                              child: Text(
                                marca,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: titleSize.clamp(10, 16),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: smallIconSize.clamp(12, 18),
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '$correo',
                                      style: TextStyle(
                                        fontSize: detailSize.clamp(8, 12),
                                        color: Colors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: smallIconSize.clamp(12, 18),
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '$telefono',
                                      style: TextStyle(
                                        fontSize: detailSize.clamp(8, 12),
                                        color: Colors.black,
                                      ),
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                              iconSize: smallIconSize.clamp(16, 24),
                              onPressed: () {
                                widget.onNavigate(EditarEstuche(
                                  estucheId: estucheDoc.id,
                                  marca: marca,
                                  correo: correo,
                                  telefono: telefono,
                                  onNavigate: widget.onNavigate,
                                ));
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
      elevation: 0,
      onPressed: () {
        widget.onNavigate(Estuches(onNavigate: widget.onNavigate));
      },
      backgroundColor: Colors.transparent,
      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF131443)),
    ),
  );
}
}