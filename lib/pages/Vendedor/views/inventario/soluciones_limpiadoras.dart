import 'package:flutter/material.dart';
import 'package:inventario/pages/Vendedor/views/inventario.dart';
import 'package:inventario/pages/Vendedor/views/inventario/agregar_solucion.dart';
import 'package:inventario/pages/Vendedor/views/inventario/lista_soluciones_limpiadoras.dart';

class SolucionesLimpiadoras extends StatefulWidget {
  final Function(Widget) onNavigate;

  const SolucionesLimpiadoras({super.key, required this.onNavigate});

  @override
  State<SolucionesLimpiadoras> createState() => _SolucionesLimpiadorasState();
}

class _SolucionesLimpiadorasState extends State<SolucionesLimpiadoras> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soluciones Limpiadoras',
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
          // Cálculos responsivos
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          
          final cardWidth = (screenWidth * 0.5).clamp(150.0, 220.0);
          final cardHeight = (screenHeight * 0.5).clamp(160.0, 220.0);
          final spaceBetween = (screenWidth * 0.2).clamp(40.0, 60.0);
          final iconSize = (cardWidth * 0.3).clamp(36.0, 60.0);
          final textSize = (cardWidth * 0.12).clamp(14.0, 20.0);

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (screenWidth < 600) ...[
                    _buildCard(
                      context: context,
                      width: cardWidth,
                      height: cardHeight,
                      iconSize: iconSize,
                      textSize: textSize,
                      title: "Lista Soluciones",
                      icon: Icons.water_drop,
                      color: Colors.black,
                      onTap: () => widget.onNavigate(ListaSolucionesLimpiadoras(onNavigate: widget.onNavigate)),),
                    SizedBox(height: spaceBetween),
                    _buildCard(
                      context: context,
                      width: cardWidth,
                      height: cardHeight,
                      iconSize: iconSize,
                      textSize: textSize,
                      title: "Agregar Solución",
                      icon: Icons.add_circle_outline,
                      color: const Color(0xFFD4AF37),
                      onTap: () => widget.onNavigate(AgregarSolucion(onNavigate: widget.onNavigate)),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCard(
                          context: context,
                          width: cardWidth,
                          height: cardHeight,
                          iconSize: iconSize,
                          textSize: textSize,
                          title: "Lista Soluciones",
                          icon: Icons.water_drop,
                          color: Colors.black,
                          onTap: () => widget.onNavigate(ListaSolucionesLimpiadoras(onNavigate: widget.onNavigate)),
                        ),
                        SizedBox(width: spaceBetween),
                        _buildCard(
                          context: context,
                          width: cardWidth,
                          height: cardHeight,
                          iconSize: iconSize,
                          textSize: textSize,
                          title: "Agregar Solución",
                          icon: Icons.add_circle_outline,
                          color: const Color(0xFFD4AF37),
                          onTap: () => widget.onNavigate(AgregarSolucion(onNavigate: widget.onNavigate)),)
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
          widget.onNavigate(Inventario(onNavigate: widget.onNavigate));
        },
        backgroundColor: Colors.transparent,
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
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