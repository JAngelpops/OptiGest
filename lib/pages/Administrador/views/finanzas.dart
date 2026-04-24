import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Finanzas extends StatefulWidget {
  const Finanzas({super.key});

  @override
  State<Finanzas> createState() => _FinanzasState();
}

class _FinanzasState extends State<Finanzas> {
  final DatabaseServices _databaseServices = DatabaseServices();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  // Controladores para Gastos
  final _gastoDescripcionController = TextEditingController();
  final _gastoMontoController = TextEditingController();
  final _formKeyGastos = GlobalKey<FormState>();

  // Controladores para Predicciones
  final _prediccionAnioController = TextEditingController();
  final _prediccionMesController = TextEditingController();
  final _prediccionMaxController = TextEditingController();
  final _prediccionMedController = TextEditingController();
  final _prediccionMinController = TextEditingController();
  final _formKeyPredicciones = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controlador para Costos
  final _costoRevisionController = TextEditingController();
  final _costoDiagnosticoController = TextEditingController();

  @override
  void dispose() {
    _gastoDescripcionController.dispose();
    _gastoMontoController.dispose();
    _prediccionAnioController.dispose();
    _prediccionMesController.dispose();
    _prediccionMaxController.dispose();
    _prediccionMedController.dispose();
    _prediccionMinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Finanzas',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 50,
                runSpacing: 30,
                children: [
                  _buildCardCajaChica(Icons.account_balance_wallet, 'Caja Chica'),
                  _buildCardGastos(Icons.money_off, 'Gastos', _mostrarFormularioGastos),
                  _buildCardPredicciones(Icons.trending_up, 'Predicciones', _mostrarFormularioPredicciones),
                ],
              ),
            ),
            // Botón de Costos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: ElevatedButton(
                onPressed: _mostrarDialogoCostos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFFD4AF37),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 25),
                    const SizedBox(width: 8),
                    const Text('Costos', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
 // Nueva sección: Costos Configurados
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Costos Configurados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                _buildCostosSection(), // Nuevo método para mostrar costos
              ],
            ),
          ),
        ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registros del Mes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMonthSummary(),
                    const SizedBox(height: 20),
                    const Text(
                      'Historial de Caja Chica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildCajaChicaList(firstDayOfMonth, lastDayOfMonth),
                    const SizedBox(height: 20),
                    const Text(
                      'Historial de Gastos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildGastosList(firstDayOfMonth, lastDayOfMonth),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
         
        const SizedBox(height: 30),
      ],
    ),
  ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/admin');
        },
        backgroundColor: Colors.transparent,
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
      ),
    );
  }

 // Lista de meses en español (debe estar declarada a nivel de clase)
final List<String> meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];

Widget _buildMonthSummary() {
  final now = DateTime.now();
  final monthName = '${meses[now.month - 1]} ${now.year}';

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('gastos')
        .where('idUser', isEqualTo: _currentUser?.uid)
        .where('fecha', isGreaterThanOrEqualTo: DateTime(now.year, now.month, 1))
        .where('fecha', isLessThanOrEqualTo: DateTime(now.year, now.month + 1, 0))
        .snapshots(),
    builder: (context, gastosSnapshot) {
      double totalGastos = 0;
      if (gastosSnapshot.hasData) {
        totalGastos = gastosSnapshot.data!.docs.fold(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + (data['monto'] as num).toDouble();
        });
      }

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('finanzas')
            .doc(_currentUser?.uid)
            .collection('cajaChica')
            .where('fecha', isGreaterThanOrEqualTo: DateTime(now.year, now.month, 1))
            .where('fecha', isLessThanOrEqualTo: DateTime(now.year, now.month + 1, 0))
            .snapshots(),
        builder: (context, cajaSnapshot) {
          double totalCaja = 0;
          if (cajaSnapshot.hasData) {
            totalCaja = cajaSnapshot.data!.docs.fold(0, (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              return sum + (data['montoInicial'] as num).toDouble();
            });
          }

          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  'Resumen de $monthName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Caja Chica:'),
                    Text(
                      '\$${totalCaja.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Gastos:'),
                    Text(
                      '\$${totalGastos.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
              ],
            ),
          );
        },
      );
    },
  );
}


  Widget _buildCajaChicaList(DateTime startDate, DateTime endDate) {
    if (_currentUser == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('finanzas')
          .doc(_currentUser.uid)
          .collection('cajaChica')
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('fecha', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'No hay registros de caja chica este mes',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final fecha = (data['fecha'] as Timestamp).toDate();
            final monto = (data['montoInicial'] as num).toDouble();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              color: Colors.white,
              elevation: 1,
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Color(0xFFD4AF37)),
                title: Text('Caja Chica Inicial'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(fecha)),
                trailing: Text(
                  '\$${monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGastosList(DateTime startDate, DateTime endDate) {
    if (_currentUser == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('gastos')
          .where('idUser', isEqualTo: _currentUser.uid)
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('fecha', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'No hay gastos registrados este mes',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final fecha = (data['fecha'] as Timestamp).toDate();
            final descripcion = data['descripcion'] as String;
            final monto = (data['monto'] as num).toDouble();

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 5),
              elevation: 1,
              child: ListTile(
                leading: const Icon(Icons.money_off, color: Colors.red),
                title: Text(descripcion),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(fecha)),
                trailing: Text(
                  '-\$${monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Diálogo para Gastos simplificado
  void _mostrarFormularioGastos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          'Registrar Gasto',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4, // Reducido para evitar overflow
            ),
            child: Form(
              key: _formKeyGastos,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField('Descripción', _gastoDescripcionController, validator: _validarCampoRequerido),
                  const SizedBox(height: 16),
                  _buildTextField('Monto', _gastoMontoController, 
                      keyboardType: TextInputType.numberWithOptions(decimal: true), 
                      validator: _validarMonto),
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
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : _guardarGasto,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      )
                    : const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Diálogo para Predicciones
void _mostrarFormularioPredicciones() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.4, // Reduciendo el ancho
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Registrar Predicción',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Form(
                  key: _formKeyPredicciones,
                  child: Column(
                    children: [
                      _buildTextField(
                        'Año (2023)',
                        _prediccionAnioController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese el año';
                          if (int.tryParse(value) == null) return 'Año inválido';
                          if (int.parse(value) < 2000 || int.parse(value) > 2100) {
                            return 'Año fuera de rango';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Mes (1-12)',
                        _prediccionMesController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese el mes';
                          final month = int.tryParse(value);
                          if (month == null) return 'Mes inválido';
                          if (month < 1 || month > 12) return 'Mes debe ser 1-12';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Montos Estimados',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Máximo (\$)',
                        _prediccionMaxController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _validarMonto,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Medio (\$)',
                        _prediccionMedController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _validarMonto,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Mínimo (\$)',
                        _prediccionMinController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _validarMonto,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildDialogActions(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

List<Widget> _buildDialogActions() {
  return [
    TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text(
        'Cancelar', 
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    ElevatedButton(
      onPressed: _isSaving ? null : _guardarPrediccion,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFD4AF37),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Guardar', 
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
    ),
  ];
}

  Future<void> _guardarGasto() async {
    if (!_formKeyGastos.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    try {
      final gastoData = {
        'descripcion': _gastoDescripcionController.text.trim(),
        'monto': double.parse(_gastoMontoController.text.trim()),
        'fecha': Timestamp.now(), // Usamos la fecha actual automáticamente
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _databaseServices.addGasto(gastoData);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto registrado correctamente')),
        );
        _gastoDescripcionController.clear();
        _gastoMontoController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar gasto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _guardarPrediccion() async {
  if (_formKeyPredicciones.currentState == null || !_formKeyPredicciones.currentState!.validate()) {
    return;
  }

  final max = double.tryParse(_prediccionMaxController.text) ?? 0;
  final med = double.tryParse(_prediccionMedController.text) ?? 0;
  final min = double.tryParse(_prediccionMinController.text) ?? 0;

  if (max <= med || med <= min) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los montos deben ser: Máximo > Medio > Mínimo')),
      );
    }
    return;
  }

  setState(() => _isSaving = true);
  
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
      }
      return;
    }

    final anio = int.tryParse(_prediccionAnioController.text.trim()) ?? 0;
    final mes = int.tryParse(_prediccionMesController.text.trim()) ?? 0;

    if (anio == 0 || mes == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Año y mes deben ser valores válidos')),
        );
      }
      return;
    }

    final prediccionData = {
      'idUser': currentUser.uid,
      'anio': anio,
      'mes': mes,
      'maximo': max,
      'medio': med,
      'minimo': min,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Primero verificamos si ya existe una predicción para este año y mes
    final existingPrediction = await _databaseServices.getPrediccionByYearAndMonth(anio, mes,  currentUser.uid );
    
    if (existingPrediction != null) {
      // Si existe, actualizamos
      await _databaseServices.updatePrediccion(existingPrediction.id, prediccionData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Predicción actualizada correctamente')),
        );
      }
    } else {
      // Si no existe, creamos una nueva
      await _databaseServices.addPrediccion(prediccionData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Predicción registrada correctamente')),
        );
      }
    }
    
    if (mounted) {
      Navigator.pop(context);
      _prediccionAnioController.clear();
      _prediccionMesController.clear();
      _prediccionMaxController.clear();
      _prediccionMedController.clear();
      _prediccionMinController.clear();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}

  // Validadores
  String? _validarCampoRequerido(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _validarMonto(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese un monto';
    }
    if (double.tryParse(value) == null) {
      return 'Ingrese un número válido';
    }
    return null;
  }

  // Widgets de construcción
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, String? Function(String?)? validator, int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
        validator: validator,
      ),
    );
  }

 Widget _buildCardCajaChica(IconData icon, String text) {
  return Card(
    color: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 5,
    child: InkWell(
      onTap: _mostrarDialogoCajaChica,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCardGastos(IconData icon, String text, VoidCallback onTap) {
    return Card(
      color: Color(0xFFD4AF37),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 180,
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPredicciones(IconData icon, String text, VoidCallback onTap) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 180,
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Nuevo método para mostrar el diálogo de caja chica
void _mostrarDialogoCajaChica() {
  final montoController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.all(20),
      title: const Text(
        'Registrar Caja Chica',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  'Monto Inicial', 
                  montoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese un monto';
                    if (double.tryParse(value) == null) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingrese el monto con el que inicia el día',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Cancelar', 
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                if (formKey.currentState!.validate()) {
                  setState(() => _isSaving = true);
                  await _guardarCajaChica(double.parse(montoController.text));
                  if (mounted) {
                    setState(() => _isSaving = false);
                    Navigator.pop(context);
                  }
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
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4AF37),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Guardar', 
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Nuevo método para guardar en Firestore
Future<void> _guardarCajaChica(double monto) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Referencia al documento del día en la subcolección cajaChica
    final docRef = FirebaseFirestore.instance
        .collection('finanzas')
        .doc(user.uid)
        .collection('cajaChica')
        .doc(today.toString());

    await docRef.set({
      'montoInicial': monto,
      'fecha': Timestamp.fromDate(today),
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caja chica registrada correctamente')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }
}


// Método para mostrar el diálogo de costos
  void _mostrarDialogoCostos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Configurar Costos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  'Costo de Revisión Subsecuente',
                  _costoRevisionController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: _validarMonto,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  'Costo de Diagnóstico Visual',
                  _costoDiagnosticoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: _validarMonto,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),),
              ElevatedButton(
                onPressed: _guardarCostos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  foregroundColor: const Color(0xFFD4AF37),
                ),
                child: const Text('Guardar', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              
            ],
          ),
        ],
      ),
    );
  }


 Future<void> _guardarCostos() async {
  if (_costoRevisionController.text.isEmpty || _costoDiagnosticoController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor ingrese todos los costos')));
    return;
  }

  setState(() => _isSaving = true);
  
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Guardar o actualizar el documento usando el user.uid como ID
    await FirebaseFirestore.instance
        .collection('costos')
        .doc(user.uid)  // Usamos el UID como ID del documento
        .set({
          'costoRevision': double.parse(_costoRevisionController.text),
          'costoDiagnostico': double.parse(_costoDiagnosticoController.text),
          'usuarioId': user.uid,
          'usuarioEmail': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: false));  // merge: false → Sobrescribe todo el documento

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Costos guardados correctamente')));
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar costos: ${e.toString()}')));
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}


Widget _buildCostosSection() {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('costos')
        .doc(_currentUser?.uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const Text(
          'No hay costos configurados',
          style: TextStyle(color: Colors.grey),
        );
      }

      final data = snapshot.data!.data() as Map<String, dynamic>;
      final costoRevision = (data['costoRevision'] as num).toDouble();
      final costoDiagnostico = (data['costoDiagnostico'] as num).toDouble();

      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            _buildCostoItem(
              'Revisión Subsecuente',
              costoRevision,
              Icons.medical_services_sharp,
              const Color(0xFFD4AF37),),
            const Divider(height: 20),
            _buildCostoItem(
              'Diagnóstico Visual',
              costoDiagnostico,
              Icons.remove_red_eye,
              Color(0xFFD4AF37)),
          ],
        ),
      );
    },
  );
}

Widget _buildCostoItem(String title, double amount, IconData icon, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color),
        ),
      ],
    ),
  );
}
}