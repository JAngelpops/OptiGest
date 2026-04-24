import 'package:flutter/material.dart';
import 'package:inventario/pages/Administrador/views/provedores.dart';
import 'package:inventario/pages/Administrador/views/editar_provedores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListaProveedores extends StatefulWidget {
  final Function(Widget) onNavigate;

  const ListaProveedores({super.key, required this.onNavigate});

  @override
  State<ListaProveedores> createState() => _ListaProveedoresState();
}

class _ListaProveedoresState extends State<ListaProveedores> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<DocumentSnapshot> _proveedores = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProveedores();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadProveedores();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProveedores() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Query query = _firestore
        .collection('proveedores')
        .where('idUser', isEqualTo: _auth.currentUser?.uid)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (mounted) {
      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
          _proveedores.addAll(querySnapshot.docs);
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
        title: const Text('Lista de proveedores', 
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)
        ),
      ),
      body: const Center(child: Text('No hay proveedores registrados')),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Lista de proveedores', 
        style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
    ),
    body: _proveedores.isEmpty && _isLoading
        ? const Center(child: CircularProgressIndicator())
        : LayoutBuilder(
            builder: (context, constraints) {
              // Determinar columnas según ancho de pantalla
              final crossAxisCount = constraints.maxWidth > 600 ? 5 : 3;
              // Cálculos responsivos basados en columnas
              final cardWidth = constraints.maxWidth / crossAxisCount - 20;
              final iconSize = cardWidth * 0.2;
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
                itemCount: _proveedores.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _proveedores.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var proveedor = _proveedores[index].data() as Map<String, dynamic>;
                  var proveedorId = _proveedores[index].id;
                  var nombre = proveedor['nombre'] ?? 'Sin nombre';
                  var email = proveedor['email'] ?? 'Sin email';
                  var telefono = proveedor['telefono'] ?? 'Sin teléfono';

                  return InkWell(
                    onTap: () {
                      widget.onNavigate(EditarProveedor(
                        proveedorId: proveedorId,
                        nombre: nombre,
                        email: email,
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
                            Icon(
                              Icons.person,
                              color: const Color(0xFFD4AF37),
                              size: iconSize.clamp(20, 40),
                            ),
                            const SizedBox(height: 8),
                            Flexible(
                              child: Text(
                                nombre,
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
                                      email,
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
                                      telefono,
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
        widget.onNavigate(Provedores(onNavigate: widget.onNavigate));
      },
      backgroundColor: Colors.transparent,
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
    ),
  );
}
}