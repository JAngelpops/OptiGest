import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
//import 'package:open_filex/open_filex.dart';





class GraficaVenta extends StatefulWidget {
  const GraficaVenta({super.key});

  @override
  State<GraficaVenta> createState() => _GraficaVentaState();
}

class _GraficaVentaState extends State<GraficaVenta> {
  String selectedMonth = '01';
  String selectedYear = DateTime.now().year.toString();
  String tempSelectedMonth = '01';
  String tempSelectedYear = DateTime.now().year.toString();

  final List<String> months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
  final List<String> years = List.generate(10, (index) => (DateTime.now().year - index).toString());

  Future<Map<String, dynamic>>? _ventasFuture;
  Future<Map<String, dynamic>>? _prediccionesFuture;


  @override
  void initState() {
    super.initState();
    print("📢 initState() ejecutado");
    obtenerDatosGrafica(selectedMonth, selectedYear);
    obtenerPredicciones(selectedMonth, selectedYear);
  }

  // Modificación en el método obtenerDatosGrafica
void obtenerDatosGrafica(String mes, String anio) {
  print("📢 Llamando a obtenerDatosGrafica() con Mes: $mes, Año: $anio");
  setState(() {
    selectedMonth = mes;
    selectedYear = anio;
    tempSelectedMonth = mes;
    tempSelectedYear = anio;
    _ventasFuture = _fetchDatosGrafica(mes, anio);
    _prediccionesFuture = _fetchPredicciones(mes, anio);
  });
}

void obtenerPredicciones(String mes, String anio) {
    setState(() {
      _prediccionesFuture = _fetchPredicciones(mes, anio);
    });
  }

String formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
  return formatter.format(value);
}

 Future<Map<String, dynamic>> _fetchDatosGrafica(String mes, String anio) async {
  try {
    print("📢 Ejecutando _fetchDatosGrafica()");

    User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      print("⚠️ No hay usuario autenticado.");
      return {};
    }

    String uid = usuario.uid;
    print("🔹 UID del usuario: $uid");

    DateTime inicioMes = DateTime(int.parse(anio), int.parse(mes), 1);
    DateTime finMes = DateTime(int.parse(anio), int.parse(mes) + 1, 0, 23, 59, 59);

    print("🔹 Consultando Firestore con idUser: $uid, mes: $mes, año: $anio");

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('ventas')
        .where('idUser', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioMes))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(finMes))
        .get();

    if (snapshot.docs.isEmpty) {
      print("⚠️ No se encontraron ventas en Firestore.");
      return {};
    }

    Map<String, double> data = {'Pendiente': 0, 'En proceso': 0, 'Terminado': 0};
    double totalPagado = 0.0;

    for (var doc in snapshot.docs) {
      print("📄 Documento encontrado: ${doc.data()}");
      String estatus = doc['estatus'] ?? 'Pendiente';
      double totalVenta = double.tryParse(doc['totalVenta'].toString()) ?? 0.0;
      double pagado = double.tryParse(doc['pagado'].toString()) ?? 0.0;

      data[estatus] = (data[estatus] ?? 0) + totalVenta;
      totalPagado += pagado;
    }

    print("✅ Datos obtenidos: $data, Total Pagado: $totalPagado");

    return {
      'data': data, // 🔹 Mapa con las ventas por estatus
      'totalPagado': totalPagado, // 🔹 Valor separado para el totalPagado
    };
  } catch (e) {
    print("❌ Error al obtener datos de Firestore: $e");
    return {};
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gráfica de Ventas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _ventasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }

          final Map<String, dynamic> datos = snapshot.data ?? {'data': {}, 'totalPagado': 0.0};
          final Map<String, double> ventasData = (datos['data'] as Map<String, double>?) ?? {};
          final double totalPagado = (datos['totalPagado'] as double?) ?? 0.0;


          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
if (datos.isEmpty) ...[Expanded(flex:2 ,child:Container() )],
if (datos.isNotEmpty) ...[
  Expanded(
  flex: 2,
  child: SingleChildScrollView( // Widget que permite el scroll
    child: Container(
      padding: const EdgeInsets.only(left: 20, top: 20),
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // PREDICCIONES EN LA PARTE SUPERIOR
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _prediccionesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                final maximo = snapshot.data?['maximo'] ?? 0.0;
                final medio = snapshot.data?['medio'] ?? 0.0;
                final minimo = snapshot.data?['minimo'] ?? 0.0;
                
                final bool hasPredictions = maximo != 0.0 || medio != 0.0 || minimo != 0.0;
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        'Predicciones ${_getMonthName(tempSelectedMonth)} $tempSelectedYear:',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!hasPredictions)
                        const Text(
                          'No hay predicciones\npara este período',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        )
                      else ...[
                        _buildPredictionRow('Máximo:', maximo, Colors.grey),
                        const SizedBox(height: 15),
                        _buildPredictionRow('Medio:', medio, Colors.grey),
                        const SizedBox(height: 15),
                        _buildPredictionRow('Mínimo:', minimo, Colors.grey),
                        const SizedBox(height: 20),
                        Text(
                          'Actual: \$${formatCurrency(ventasData.values.fold<double>(0, (sum, value) => sum + value))}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37)
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 60),
          // BOTÓN DE EXCEL DEBAJO
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: 'Exportar a Excel',
                child: IconButton(
                  icon: const Icon(Icons.table_chart, size: 30, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(40, 40),
                  ),
                  onPressed: _exportToExcel,
                ),
              ),
              const SizedBox(height: 0),
              const Text(
                'Excel',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),
],
                Expanded(
  flex: 6,
  child: Column(
    children: [
      // 🔹 Contenedor para los filtros (dropdowns y botón)
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: tempSelectedMonth,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  underline: Container(),
                  items: months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      tempSelectedMonth = value!;
                    });
                  },
                ),
                const SizedBox(width: 8),

                DropdownButton<String>(
                  value: tempSelectedYear,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  underline: Container(),
                  items: years.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      tempSelectedYear = value!;
                    });
                  },
                ),
                const SizedBox(width: 8),

                ElevatedButton(
  onPressed: () {
    obtenerDatosGrafica(tempSelectedMonth, tempSelectedYear);
  },
  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
  child: const Text('Graficar', style: TextStyle(color: Colors.white)),
),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 8), // 🔹 Espaciado entre filtros y contenido

      // 🔹 Contenedor que ocupa todo el espacio disponible para centrar la gráfica o el mensaje
      Expanded(
        child: Center(
          child: datos.isEmpty
              ? const Text(
                  'No hay ventas disponibles',
                  style: TextStyle(fontSize: 18, ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    double chartSize = constraints.maxWidth * 0.7;
                    return SizedBox(
                      width: chartSize,
                      height: chartSize,
                      child: PieChart(
                        PieChartData(
                          sections: ventasData.entries.map((entry) {
                            return PieChartSectionData(
                              value: entry.value,
                              title: '',
                              color: _obtenerColor(entry.key),
                              radius: chartSize * 0.4,
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    ],
  ),
),



             Expanded(
  flex: 2,
  child: SingleChildScrollView( // Añadido SingleChildScrollView
    child: Container(
      padding: const EdgeInsets.only(left: 20, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Cambiado de center a start
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Mostrar las ventas por estatus
          ...ventasData.keys.map((key) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(width: 12, height: 12, color: _obtenerColor(key)),
                  const SizedBox(width: 4, height: 40),
                  Expanded(
                    child: Text(
                      '$key: \$${formatCurrency(ventasData[key] ?? 0.0)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          if (datos.isNotEmpty) ...[
            const SizedBox(width: 2, height: 50),
            const Divider(color: Colors.grey),
            
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pagado:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Flexible(
                            child: Text(
                              '\$${formatCurrency(totalPagado)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Flexible(
                            child: Text(
                              '\$${formatCurrency(ventasData.values.fold<double>(0, (sum, value) => sum + value))}',
                              style: const TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold, 
                                color: Color(0xFFD4AF37)
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  ),
),


              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/vendedor');
        },
        backgroundColor: Colors.transparent,
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
      ),
    );
  }

  Color _obtenerColor(String estatus) {
    switch (estatus) {
      case 'Pendiente':
        return Colors.black;
      case 'En proceso':
        return const Color(0xFFD4AF37);
      case 'Terminado':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

String _getMonthName(String month) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[int.parse(month) - 1];
  }
  

Future<void> _exportToExcel() async {
  try {
    print("⏳ Iniciando exportación a Excel...");

    // Obtener datos
    final datos = await _fetchDatosGrafica(tempSelectedMonth, tempSelectedYear);
    if (datos['data']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay datos para exportar')));
      return;
    }

    // Crear Excel
    final excel = Excel.createExcel();
    final sheet = excel['Ventas'];
    
    // Encabezados
    sheet.appendRow(['Reporte de Ventas - ${_getMonthName(tempSelectedMonth)} $tempSelectedYear']);
    sheet.appendRow(['Estatus', 'Total Ventas (\$)', 'Pagado (\$)']);
    
    // Datos
    final ventasData = datos['data']! as Map<String, double>;
    ventasData.forEach((estatus, total) {
      sheet.appendRow([
        estatus,
        total,
        estatus == 'Terminado' ? total : total / 2
      ]);
    });

    // Totales
    sheet.appendRow(['', 'Total General:', ventasData.values.fold(0.0, (sum, value) => sum + value)]);
    sheet.appendRow(['', 'Total Pagado:', datos['totalPagado']!]);

    // Guardar archivo
    final fileName = 'ventas_${tempSelectedMonth}_$tempSelectedYear.xlsx';
    final bytes = excel.encode()!;

    if (kIsWeb) {
      // Para web
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Para móvil/desktop
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      
      // Abrir automáticamente con open_file
      final result = await OpenFile.open(filePath);
      
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo guardado en: $filePath')),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte exportado y abierto')),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al exportar: ${e.toString()}')),
    );
  }
}


  // Método modificado para obtener predicciones
Future<Map<String, dynamic>> _fetchPredicciones(String mes, String anio) async {
  try {
    User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return {};

    // Convertir a números enteros como los guardas
    int anioNum = int.tryParse(anio) ?? 0;
    int mesNum = int.tryParse(mes) ?? 0;
    
    print('🔍 Buscando predicciones para: Año $anioNum, Mes $mesNum');
    
    if (anioNum == 0 || mesNum == 0) return {};

    // Consultar la colección de predicciones
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('predicciones')
        .where('idUser', isEqualTo: usuario.uid)
        .where('anio', isEqualTo: anioNum)
        .where('mes', isEqualTo: mesNum)
        .get();

    if (snapshot.docs.isEmpty) {
      print('⚠️ No se encontraron predicciones para estas fechas');
      return {'maximo': 0.0, 'medio': 0.0, 'minimo': 0.0};
    }

    // Tomamos la primera predicción (asumiendo que solo hay una por mes)
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    
    print('✅ Predicciones encontradas: $data');
    
    return {
      'maximo': (data['maximo'] as num?)?.toDouble() ?? 0.0,
      'medio': (data['medio'] as num?)?.toDouble() ?? 0.0,
      'minimo': (data['minimo'] as num?)?.toDouble() ?? 0.0,
    };
  } catch (e) {
    print("❌ Error al obtener predicciones: $e");
    return {'maximo': 0.0, 'medio': 0.0, 'minimo': 0.0};
  }
}


// Método auxiliar para construir filas de predicción
Widget _buildPredictionRow(String label, double value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Flexible(
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis, // Añade puntos suspensivos si no cabe
      ),
    ),
    Flexible(
      child: Text(
        '\$${formatCurrency(value)}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
  );
}
}