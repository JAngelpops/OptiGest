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
  // Controladores
  final _gastoDescripcionController = TextEditingController();
  final _gastoMontoController = TextEditingController();
  final _prediccionAnioController = TextEditingController();
  final _prediccionMesController = TextEditingController();
  final _prediccionMaxController = TextEditingController();
  final _prediccionMedController = TextEditingController();
  final _prediccionMinController = TextEditingController();
  final _cajaChicaController = TextEditingController();
  
  final _formKeyGastos = GlobalKey<FormState>();
  final _formKeyPredicciones = GlobalKey<FormState>();
  bool _isSaving = false;

  final double cardWidth= 220.0;
  final double cardHeight = 220.0;
  final double iconSize= 40.0;
  final double textSize = 16.0;

  @override
  void dispose() {
    _gastoDescripcionController.dispose();
    _gastoMontoController.dispose();
    _prediccionAnioController.dispose();
    _prediccionMesController.dispose();
    _prediccionMaxController.dispose();
    _prediccionMedController.dispose();
    _prediccionMinController.dispose();
    _cajaChicaController.dispose();
    super.dispose();
  }
  
@override
  Widget build(BuildContext context) {
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
                  _buildCard(
                            context: context,
                            width: cardWidth,
                            height: cardHeight,
                            iconSize: iconSize,
                            textSize: textSize,
                            title: "Caja Chica",
                            icon: Icons.account_balance_wallet,
                            color: Colors.black,
                            onTap: _mostrarRegistroCajaChica,
                          ),
                          _buildCard(
                            context: context,
                            width: cardWidth,
                            height: cardHeight,
                            iconSize: iconSize,
                            textSize: textSize,
                            title: "Gastos",
                            icon: Icons.money_off,
                            color: const Color(0xFFD4AF37),
                            onTap: _mostrarFormularioGastos,
                          ),
                          _buildCard(
                            context: context,
                            width: cardWidth,
                            height: cardHeight,
                            iconSize: iconSize,
                            textSize: textSize,
                            title: "Predicciones",
                            icon: Icons.trending_up,
                            color: Colors.black,
                            onTap: _mostrarFormularioPredicciones,
                          ),
                ],
              ),
            ),
            const SizedBox(height: 70,),
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
      ],
    ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: iconSize, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
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

 
void _mostrarRegistroCajaChica() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final doc = await FirebaseFirestore.instance
          .collection('finanzas')
          .doc(user.uid)
          .collection('cajaChica')
          .doc(today.toString())
          .get();

      if (!doc.exists) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text(
                'Caja Chica',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              content: const Text('No hay registro de caja chica para hoy.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar', style: TextStyle(color: Color(0xFFD4AF37)),),
                ),
                
              ],
            ),
          );
        }
        return;
      }

      final monto = doc.data()?['montoInicial'] ?? 0.0;
      final fecha = (doc.data()?['fecha'] as Timestamp?)?.toDate() ?? now;

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            contentPadding: const EdgeInsets.all(20),
            title: const Text(
              'Caja Chica',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(fecha)}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'Monto Inicial: \$${monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Cerrar', style: TextStyle(color:Color(0xFFD4AF37) ),),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener registro: $e')),
        );
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