import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventario/pages/Administrador/views/inventario/editar_sujeta_lentes.dart';
import 'package:inventario/pages/Administrador/views/inventario/sujeta_lentes.dart';


class ListaSujetaLentes extends StatefulWidget {
  final Function(Widget) onNavigate; 
  const ListaSujetaLentes({super.key, required this.onNavigate});

  @override
  State<ListaSujetaLentes> createState() => _ListaSujetaLentesState();
}

class _ListaSujetaLentesState extends State<ListaSujetaLentes> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<DocumentSnapshot> _sujetaLentes = [];
  final ScrollController _scrollController = ScrollController();

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
    super.dispose();
  }

  Future<void> _loadSujetaLentes() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    Query query = _firestore.collection('sujetaLentes')
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
          _sujetaLentes.addAll(querySnapshot.docs);
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
        title: const Text('Lista de sujeta lentes',
            style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: const Center(child: Text('No hay sujeta lentes registrados')),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Lista de sujeta lentes',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      centerTitle: true,
      automaticallyImplyLeading: false,
    ),
    body: _sujetaLentes.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : LayoutBuilder(
            builder: (context, constraints) {
              // Configuración responsiva
              final crossAxisCount = constraints.maxWidth > 600 ? 5 : 3;
              final cardWidth = constraints.maxWidth / crossAxisCount - 24;
              final iconSize = cardWidth * 0.15;
              final titleFontSize = cardWidth * 0.08;
              final detailFontSize = cardWidth * 0.06;
              final childAspectRatio = crossAxisCount == 5 ? 1.2 : 1.1;

              return GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
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

                  var sujetaLentesDoc = _sujetaLentes[index];
                  var sujetaLente = sujetaLentesDoc.data() as Map<String, dynamic>;
                  var marca = sujetaLente['marca'] ?? 'Sin marca';
                  var correo = sujetaLente['correo'] ?? 'Sin correo';
                  var telefono = sujetaLente['telefono'] ?? 'Sin teléfono';

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      widget.onNavigate(EditarSujetaLentes(
                        sujetaLentesId: sujetaLentesDoc.id,
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
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                marca,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: titleFontSize.clamp(12, 18),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: iconSize.clamp(12, 18),
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        correo,
                                        style: TextStyle(
                                          fontSize: detailFontSize.clamp(10, 14),
                                          color: Colors.black54,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: iconSize.clamp(12, 18),
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        telefono,
                                        style: TextStyle(
                                          fontSize: detailFontSize.clamp(10, 14),
                                          color: Colors.black54,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                              iconSize: iconSize.clamp(18, 26),
                              onPressed: () {
                                widget.onNavigate(EditarSujetaLentes(
                                  sujetaLentesId: sujetaLentesDoc.id,
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
        widget.onNavigate(SujetaLentes(onNavigate: widget.onNavigate));
      },
      backgroundColor: Colors.transparent,
      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF131443)),
    ),
  );
}
}