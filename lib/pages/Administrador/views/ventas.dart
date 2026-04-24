import 'package:flutter/material.dart';
import 'package:inventario/pages/Administrador/views/editar_venta.dart';
import 'nueva_venta.dart';
import 'grafica_venta.dart';
import 'finanzas.dart';
import 'package:inventario/services/database_services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Ventas extends StatefulWidget {
  const Ventas({super.key});

  @override
  State<Ventas> createState() => _VentasState();
}
 
class _VentasState extends State<Ventas> {
  String currentView = 'inicio';
  final DatabaseServices _dbService = DatabaseServices();
  late Future<List<Map<String, dynamic>>> _ventasFuture;
  String filtroEstatus = ''; // Variable para almacenar el filtro de estado

 @override
void initState() {
  super.initState();
  filtroEstatus = ""; // 🔹 Sin filtro al inicio
  _ventasFuture = _dbService.getVentas(); // 🔹 Carga todas las ventas del mes
}


  void cambiarVista(String vista) {
    setState(() {
      currentView = vista;
    });
  }

  String formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
  return formatter.format(value);
}

  void aplicarFiltro(String estatus) {
    setState(() {
      filtroEstatus = estatus;
      _ventasFuture = _dbService.getVentas(estatus: filtroEstatus); // Actualiza la consulta con el filtro
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Expanded(child: _obtenerVistaActual()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _obtenerVistaActual() {
    switch (currentView) {
      case 'nuevaVenta':
        return const NuevaVenta();
      case 'graficaVenta':
        return const GraficaVenta();
      case 'finanzas':
        return const Finanzas();
      default:
        return _vistaPrincipal();
    }
  }

  void abrirEdicionVenta(Map<String, dynamic> venta, String idDocumento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarVenta(
          onNavigate: (widget) {}, 
          venta: {
            ...venta, 
            'id': idDocumento, // Ahora agregamos correctamente el ID
          },
        ),
      ),
    ).then((resultado) {
      if (resultado != null) {
        setState(() {
          _ventasFuture = _dbService.getVentas(estatus: filtroEstatus); // Recargar ventas después de editar
        });
      }
    });
  }

  Widget _vistaPrincipal() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas', style: TextStyle(color: Colors.black, fontSize: 24,fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        
        children: [
          Expanded(
  flex: 1,
  child: Column(
    children: [
      // 🔹 Primer botón alineado arriba
      Align(
        alignment: Alignment.topCenter,
        child: _botonAccion(
          Icons.bar_chart,
          'Gráficas',
          'graficaVenta',
          abajo: false,
          color: Color(0xFFD4AF37),
        ),
      ),

      // 🔹 Espacio flexible para centrar el segundo botón
      Expanded(child: Container()),
      Expanded(child: Container()),

      // 🔹 Segundo botón alineado en el centro
      Align(
        alignment: Alignment.center,
        child: _botonAccion(
          Icons.attach_money_outlined,
          'Finanzas',
          'finanzas',
          abajo: false,
          color: Colors.black,
        ),
      ),Expanded(child: Container()),
      Expanded(child: Container()),

      // 🔹 Espacio flexible para que el segundo botón no quede pegado al borde inferior
      Expanded(child: Container()),
      Expanded(child: Container()),
      Expanded(child: Container()),
    ],
  ),
),


          Expanded(
            flex: 6,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _filtroBoton('Pendiente', Colors.black),
                    const SizedBox(width: 24,),
                    _filtroBoton('En proceso',const Color(0xFFD4AF37)
),
                    const SizedBox(width: 24),
                    _filtroBoton('Terminado', Colors.black),
                    const SizedBox(height: 40),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _ventasFuture, // Usamos el _ventasFuture que ahora se actualiza con el filtro
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error al cargar ventas'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No hay ventas disponibles'));
                      }

                      final ventas = snapshot.data!;
                      return ListView.builder(
                        itemCount: ventas.length,
                        itemBuilder: (context, index) {
                          final venta = ventas[index];
                          final idDocumento = venta['id'] ?? ''; // Obtenemos el ID del documento

                          return Card(
                            color: const Color.fromARGB(255, 246, 246, 246),
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text('Estatus: ${venta['estatus'] ?? 'Sin título'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Código: ${venta['idVenta'] ?? 'Desconocido'}'),
                              trailing: Text(
  '\$${formatCurrency((venta['totalVenta'] as num?)?.toDouble() ?? 0.0)}',
  style: const TextStyle(color: Color(0xFFD4AF37)),
),

                              onTap: () => abrirEdicionVenta(venta, idDocumento), // Pasamos el ID
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
  flex: 1,
  child: Column(
    children: [
      // 🔹 Primer botón alineado arriba
      Align(
        alignment: Alignment.topCenter,
        child: _botonAccion(
          Icons.add_circle_outline,
          'Nueva venta',
          'nuevaVenta',
          color: Colors.black,
        ),
      ),

      // 🔹 Espacio flexible para centrar el segundo botón
      Expanded(child: Container()),

      // 🔹 Segundo botón alineado en el centro
      Align(
        alignment: Alignment.center,
        child: _botonAccion(
          Icons.search,
          'Buscar',
          'buscarVenta',
          abajo: true,
          color: Color(0xFFD4AF37),
          onPressed: _mostrarOpcionesBusqueda,
        ),
      ),

      // 🔹 Espacio flexible para que no quede pegado abajo
      Expanded(child: Container()),
    ],
  ),
),

        ],
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

  Widget _filtroBoton(String texto, Color color) {
    return ElevatedButton(
      onPressed: () => aplicarFiltro(texto), // Aplica el filtro cuando se presiona
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Se usa el color personalizado
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

Widget _botonAccion(IconData icono, String texto, String vista, {bool abajo = false, Color color = Colors.black, VoidCallback? onPressed}) {
  return Align(
    alignment: abajo ? Alignment.bottomCenter : Alignment.topCenter,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!abajo) const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onPressed ?? () => cambiarVista(vista), // 🔹 Usa onPressed si se proporciona, sino cambia de vista
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const CircleBorder(),
          ),
          child: Icon(icono, color: color, size: 40), // Ícono con color personalizado
        ),
        const SizedBox(height: 1),
        Text(
          texto,
          style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold), // Texto con color personalizado
        ),
        if (abajo) const SizedBox(height: 100),
      ],
    ),
  );
}

 void _mostrarOpcionesBusqueda() {
  final TextEditingController anioController = TextEditingController();
  final TextEditingController mesController = TextEditingController();
  final TextEditingController diaController = TextEditingController();

  String? errorAnio;
  String? errorMes;
  String? errorDia;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            //backgroundColor: Colors.white,
            title: const Text(
              "Buscar Venta",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(
                        "Año (Obligatorio)", 
                        anioController, 
                        errorAnio, 
                        setState,
                        length: 4,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        "Mes (Obligatorio)", 
                        mesController, 
                        errorMes, 
                        setState,
                        length: 2,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        "Día", 
                        diaController, 
                        errorDia, 
                        setState,
                        length: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        errorAnio = (anioController.text.trim().length == 4) 
                          ? null 
                          : "Debe tener 4 dígitos";

                        errorMes = (mesController.text.trim().length == 2) 
                          ? null 
                          : "Debe tener 2 dígitos";

                      });

                      if (errorAnio != null || errorMes != null ) {
                        return;
                      }

                      String anio = anioController.text.trim();
                      String mes = mesController.text.trim();
                      String dia = diaController.text.trim();

                      // 🔍 Depuración
                      print("🔍 Buscando ventas en: $anio-$mes-$dia");

                      // 🔄 Actualizar la consulta con la fecha ingresada
                      _buscarVentasPorFecha(anio, mes, dia);

                      Navigator.of(context).pop(); // Cerrar cuadro de diálogo
                    },
                    child: const Text(
                      "Buscar",
                      style: TextStyle(fontSize: 14, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

// 🔹 Componente reutilizable para los campos de entrada con validación
Widget _buildTextField(String label, TextEditingController controller, String? errorText, Function setState, {int? length}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: length, // 🔹 Limita el número de caracteres permitidos
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          counterText: "", // 🔹 Oculta el contador de caracteres
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD4AF37)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        ),
      ),
      if (errorText != null) // 🔥 Si hay error, mostrarlo en rojo debajo del campo
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            errorText,
            style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
    ],
  );
}



void _buscarVentasPorFecha(String anio, String mes, String dia) {
  int year = int.parse(anio);
  int month = int.parse(mes);

  DateTime fechaInicio;
  DateTime fechaFin;

  if (dia.isEmpty) {
    // Si no hay día, buscar todas las ventas del mes
    fechaInicio = DateTime(year, month, 1);
    fechaFin = DateTime(year, month + 1, 0, 23, 59, 59); // Último día del mes
  } else {
    // Si hay día, buscar solo esa fecha
    int day = int.parse(dia);
    fechaInicio = DateTime(year, month, day);
    fechaFin = fechaInicio.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
  }

  // Convertimos las fechas a Timestamp para Firestore
  Timestamp tsInicio = Timestamp.fromDate(fechaInicio);
  Timestamp tsFin = Timestamp.fromDate(fechaFin);

  // Depuración
  print("🔍 Buscando ventas entre: ${fechaInicio.toIso8601String()} y ${fechaFin.toIso8601String()}");

  setState(() {
    _ventasFuture = _dbService.getVentasPorFecha(tsInicio, tsFin);
  });
}
}