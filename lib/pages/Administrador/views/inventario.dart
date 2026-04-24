import 'package:flutter/material.dart';
import 'package:inventario/pages/Administrador/views/inventario/armazon.dart';
import 'package:inventario/pages/Administrador/views/inventario/cordones.dart';
import 'package:inventario/pages/Administrador/views/inventario/estuches.dart';
import 'package:inventario/pages/Administrador/views/inventario/panos.dart';
import 'package:inventario/pages/Administrador/views/inventario/plaquetas.dart';
import 'package:inventario/pages/Administrador/views/inventario/soluciones_lc.dart';
import 'package:inventario/pages/Administrador/views/inventario/soluciones_limpiadoras.dart';
import 'package:inventario/pages/Administrador/views/inventario/sujeta_lentes.dart';
import 'package:inventario/pages/Administrador/views/inventario/tornillos.dart';


class Inventario extends StatelessWidget {
  final Function(Widget) onNavigate;

  const Inventario({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // Lista de 9 items para la cuadrícula 3x3
    final inventoryItems = [
      {
        'title': 'Armazones',
        'color': Colors.black,
        'page': Armazon(onNavigate: onNavigate),
      },
      {
        'title': 'Soluciones L.C.',
        'color': const Color(0xFFD4AF37),
        'page': SolucionesLc(onNavigate: onNavigate),
      },
      {
        'title': 'Estuches',
        'color': Colors.black,
        'page': Estuches(onNavigate: onNavigate),
      },
      {
        'title': 'Paños',
        'color': Colors.black,
        'page': Panos(onNavigate: onNavigate),
      },
      {
        'title': 'Soluciones limpiadoras',
        'color': const Color(0xFFD4AF37),
        'page': SolucionesLimpiadoras(onNavigate: onNavigate),
      },
      {
        'title': 'Plaquetas',
        'color': Colors.black,
        'page': Plaquetas(onNavigate: onNavigate),
      },
      {
        'title': 'Tornillos',
        'color': Colors.black,
        'page': Tornillos(onNavigate: onNavigate),
      },
      {
        'title': 'Cordones',
        'color': const Color(0xFFD4AF37),
        'page': Cordones(onNavigate: onNavigate),
      },
      {
        'title': 'Sujeta Lentes',
        'color': Colors.black,
        'page': SujetaLentes(onNavigate: onNavigate),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario',
            style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculamos el tamaño de las cards
          final screenWidth = constraints.maxWidth;
          final padding = screenWidth * 0.04; // Padding adaptable (4% del ancho)
          final columnSpacing = screenWidth * 0.08; // Espaciado entre columnas (3%)
          //final rowSpacing = screenWidth * 0.08; // Espaciado base entre filas (4%)
          final middleRowSpacing = screenWidth * 0.03; // Más espacio para filas centrales (6%)
          
          final cardSize = (screenWidth - 2 * padding - 2 * columnSpacing) / 3;
          
          // Tamaños mínimos/máximos
          final minCardSize = 100.0;
          final maxCardSize = 220.0;
          final effectiveCardSize = cardSize.clamp(minCardSize, maxCardSize);
          final effectivePadding = padding.clamp(8.0, 20.0);

          return SingleChildScrollView(
            padding: EdgeInsets.all(effectivePadding),
            child: Column(
              children: [
                // Fila 1 (arriba)
                _buildCardRow(
                  items: inventoryItems.sublist(0, 3),
                  cardSize: effectiveCardSize,
                  spacing: columnSpacing,
                  padding: effectivePadding,
                ),
                SizedBox(height: middleRowSpacing), // Más espacio después de fila 1
                
                // Fila 2 (centro)
                _buildCardRow(
                  items: inventoryItems.sublist(3, 6),
                  cardSize: effectiveCardSize,
                  spacing: columnSpacing,
                  padding: effectivePadding,
                ),
                SizedBox(height: middleRowSpacing), // Más espacio después de fila 2
                
                // Fila 3 (abajo)
                _buildCardRow(
                  items: inventoryItems.sublist(6, 9),
                  cardSize: effectiveCardSize,
                  spacing: columnSpacing,
                  padding: effectivePadding,
                ),
              ],
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

  Widget _buildCardRow({
    required List<Map<String, dynamic>> items,
    required double cardSize,
    required double spacing,
    required double padding,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildInventoryCard(
          item: items[0],
          size: cardSize,
          padding: padding,
        ),
        SizedBox(width: spacing),
        _buildInventoryCard(
          item: items[1],
          size: cardSize,
          padding: padding,
        ),
        SizedBox(width: spacing),
        _buildInventoryCard(
          item: items[2],
          size: cardSize,
          padding: padding,
        ),
      ],
    );
  }

  Widget _buildInventoryCard({
    required Map<String, dynamic> item,
    required double size,
    required double padding,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Card(
        color: item['color'] as Color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => onNavigate(item['page'] as Widget),
          child: Container(
            padding: EdgeInsets.all(padding),
            alignment: Alignment.center,
            child: Text(
              item['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: _calculateFontSize(item['title'] as String, size/1.5),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  double _calculateFontSize(String text, double cardSize) {
    final baseSize = cardSize * 0.15;
    if (text.length <= 8) return baseSize;
    if (text.length <= 15) return baseSize * 0.85;
    return baseSize * 0.7;
  }
}