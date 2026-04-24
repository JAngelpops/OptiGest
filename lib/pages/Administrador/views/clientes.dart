import 'package:flutter/material.dart';
import 'lista_clientes.dart';
import 'agregar_cliente.dart';

class Clientes extends StatefulWidget {
  final Function(Widget) onNavigate;

  const Clientes({super.key, required this.onNavigate});

  @override
  _ClientesState createState() => _ClientesState();
} 

class _ClientesState extends State<Clientes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes', 
          style: TextStyle(
            color: Colors.black, 
            fontSize: 24,
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Cálculos responsivos mejorados
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          
          // Tamaño de las cards (45% del ancho con límites)
          final cardWidth = (screenWidth * 0.5).clamp(150.0, 220.0);
          final cardHeight = (screenHeight * 0.5).clamp(160.0, 220.0);
          
          // Espacio entre cards (4% del ancho con límites)
          final spaceBetween = (screenWidth * 0.2).clamp(40.0, 60.0);
          
          // Tamaño de iconos (proporcional pero con límites)
          final iconSize = (cardWidth * 0.3).clamp(36.0, 60.0);
          
          // Tamaño de texto responsivo mejorado
          final textSize = (cardWidth * 0.12).clamp(14.0, 20.0);

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ajuste para pantallas pequeñas (orientación vertical)
                  if (screenWidth < 600) ...[
                    _buildCard(
                      context: context,
                      width: cardWidth,
                      height: cardHeight,
                      iconSize: iconSize,
                      textSize: textSize,
                      title: "Lista clientes",
                      icon: Icons.person,
                      color: Colors.black,
                      onTap: () => widget.onNavigate(ListaClientes(onNavigate: widget.onNavigate)),
                    ),
                    SizedBox(height: spaceBetween),
                    _buildCard(
                      context: context,
                      width: cardWidth,
                      height: cardHeight,
                      iconSize: iconSize,
                      textSize: textSize,
                      title: "Agregar cliente",
                      icon: Icons.add_circle_outline,
                      color: const Color(0xFFD4AF37),
                      onTap: () => widget.onNavigate(AgregarCliente(onNavigate: widget.onNavigate)),
                    ),
                  ] else ...[
                    // Diseño horizontal para pantallas más anchas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCard(
                          context: context,
                          width: cardWidth,
                          height: cardHeight,
                          iconSize: iconSize,
                          textSize: textSize,
                          title: "Lista clientes",
                          icon: Icons.person,
                          color: Colors.black,
                          onTap: () => widget.onNavigate(ListaClientes(onNavigate: widget.onNavigate)),),
                        SizedBox(width: spaceBetween),
                        _buildCard(
                          context: context,
                          width: cardWidth,
                          height: cardHeight,
                          iconSize: iconSize,
                          textSize: textSize,
                          title: "Agregar cliente",
                          icon: Icons.add_circle_outline,
                          color: const Color(0xFFD4AF37),
                          onTap: () => widget.onNavigate(AgregarCliente(onNavigate: widget.onNavigate)),)
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        backgroundColor: Colors.transparent,
        child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF131443)),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required double width,
    required double height,
    required double iconSize,
    required double textSize,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: Colors.white,
                ),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}