import 'package:flutter/material.dart';
import 'package:inventario/pages/Administrador/views/clientes.dart';
import 'package:inventario/pages/Administrador/views/inventario.dart';
import 'package:inventario/pages/Administrador/views/provedores.dart';
import 'package:inventario/pages/Administrador/views/ventas.dart';

class AdminInicio extends StatefulWidget {
  const AdminInicio({super.key});

  @override
  State<AdminInicio> createState() => _AdminInicioState();
}

class _AdminInicioState extends State<AdminInicio> {
  int _selectedIndex = 1;
  late List<Widget> _views;

  // Función para cambiar la vista actual
  void _changeView(Widget newView) {
    setState(() {
      _views[_selectedIndex] = newView;
    });
  }

  @override
  void initState() {
    super.initState();
    _views = [
      Inventario(onNavigate: (view) => _changeView(view)),
      const Ventas(),
      Clientes(onNavigate: (view) => _changeView(view)),
      Provedores(onNavigate: (view) => _changeView(view)),
    ];
  }

  // Función para manejar el cambio de índice en el BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
  }

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
 Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Asegura que el widget ocupe solo el espacio necesario
      children: [
        // Línea difuminada
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        // BottomNavigationBar
        BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          selectedItemColor: Color(0xFFD4AF37),
          unselectedItemColor: Colors.black,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_added_sharp),
              label: 'Inventario',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.money),
              label: 'Ventas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Proveedores',
            ),
          ],
          elevation: 0,
        ),
      ],
    );
  }
}