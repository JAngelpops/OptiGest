import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventario/services/database_services.dart'; 
import 'package:intl/intl.dart';

class NuevaVenta extends StatefulWidget {
  const NuevaVenta({super.key});

  @override
  State<NuevaVenta> createState() => _NuevaVentaState();
}
 
class _NuevaVentaState extends State<NuevaVenta> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController armazonController = TextEditingController();
  final TextEditingController proveedorController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController adicionalController = TextEditingController();
  final TextEditingController vendedorController = TextEditingController();
  final TextEditingController anguloPanoramicoController = TextEditingController();
  final TextEditingController anguloPuntoscopicoController = TextEditingController();
  final TextEditingController distanciaVerticeDerechoController = TextEditingController();
  final TextEditingController distanciaVerticeIzquierdoController = TextEditingController();
  final TextEditingController otroController = TextEditingController();
  final TextEditingController clienteController = TextEditingController();
 final TextEditingController telefonoController = TextEditingController();
 final TextEditingController pagadoController = TextEditingController();



  final DatabaseServices _databaseServices = DatabaseServices();


  late Future<List<Map<String, dynamic>>> _proveedoresFuture;
  late Future<List<Map<String, dynamic>>> _modelosFuture = Future.value([]); // Inicializa con lista vacía
  late Future<List<Map<String, dynamic>>> _micasFuture = Future.value([]);

void _actualizarModelos(String? marcaArmazon) {
  if (marcaArmazon == null || marcaArmazon.isEmpty) return; // Evita valores nulos o vacíos
  setState(() {
    _modelosFuture = _databaseServices.getModelosPorArmazon(marcaArmazon);
  });
}


  late Future<List<Map<String, dynamic>>> _armazonesFuture;

  String? _proveedorSeleccionado;
  String? _micaSeleccionada;
  String? _armazonSeleccionado;
  String? _modeloSeleccionado;

  String? estatusSeleccionado;
  String? tipoPagoSeleccionado;

  bool revisionSubsecuente = false;
  bool requiereFactura = false;
  bool diagnosticoVisual = false;
  bool parametros = false;

  double _totalVenta = 0.0;
  double _precioMicaAnterior = 0.0;
  double _costoRevision = 0.0;  
  double _costoDiagnostico = 0.0;  

  final List<String> estatusOpciones = ["Pendiente", "En proceso", "Terminado"];
  final List<String> tipoPagoOpciones = ["Combinado", "Efectivo", "Tarjeta"];

  DateTime? fechaSeleccionada;

  @override
void initState() {
  super.initState();
  
  final userId = FirebaseAuth.instance.currentUser?.uid;
  print("Usuario autenticado: $userId"); 

  if (userId != null) {
    _proveedoresFuture = _databaseServices.getProveedoresPorUsuario(userId);
    _armazonesFuture = _databaseServices.getArmazonesPorUsuario(userId);
    _cargarCostosUsuario(userId);
  } else {
    _proveedoresFuture = Future.value([]);
    _armazonesFuture = Future.value([]);
  }

  DateTime now = DateTime.now();
  fechaController.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
}




  @override
  void dispose() {
    armazonController.dispose();
    proveedorController.dispose();
    fechaController.dispose();
    adicionalController.dispose();
    vendedorController.dispose();
    clienteController.dispose();  
    telefonoController.dispose(); 
    super.dispose();
  }

   String formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
  return formatter.format(value);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta', style: TextStyle(color: Colors.black, fontSize: 24,fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //_buildTextField('Armazón', armazonController),
                          //_buildTextField('Proveedor', proveedorController),
                          _buildTextField('Vendedor', vendedorController),
                           _buildTextField('Cliente', clienteController),    // Campo de cliente
                           _buildTextField('Teléfono', telefonoController,keyboardType: TextInputType.phone),
                            _buildTextFieldConIcono(
  'Adicional', 
  adicionalController, 
  keyboardType: TextInputType.number,
  onIconPressed: () {
    double adicional = double.tryParse(adicionalController.text) ?? 0.0;
    _actualizarTotalAdicional(adicional);
  },
),
                          _buildSeleccionArmazon(),
                          _buildSeleccionProveedor(),
                          
                          //_buildTotal(), // Muestra el total acumulado
                          Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total:",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "\$${formatCurrency(_totalVenta)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    ),
                          
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           _buildFechaSeleccion(),
                          _buildTextField(
  'Anticipo',
  pagadoController,
  keyboardType: TextInputType.number,
),



                          _buildDropdown('Estatus', estatusOpciones, (value) {
                            setState(() {
                              estatusSeleccionado = value;
                            });
                          }, estatusSeleccionado),
                           _buildDropdown('Tipo de Pago', tipoPagoOpciones, (value) {
                            setState(() {
                              tipoPagoSeleccionado = value;
                            });
                          }, tipoPagoSeleccionado),
                          _buildSwitch('Revisión Subsecuente', revisionSubsecuente, (value) {
                            setState(() {
                              revisionSubsecuente = value;
                              _actualizarTotalRevision();
                            });
                          }),
                          _buildSwitch('Requiere Factura', requiereFactura, (value) {
                            setState(() {
                              requiereFactura = value;
                            });
                          }),
                          _buildSwitch('Diagnóstico Visual', diagnosticoVisual, (value) {
                            setState(() {
                              diagnosticoVisual = value;
                              _actualizarTotalDiagnostico();
                            });
                          }),
                          _buildSwitch('Parámetros especiales', parametros, (value) {
                            setState(() {
                             parametros = value;
                          });

                          if (value) {
                           _mostrarFormularioParametros();
                          }
                         }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: _guardarVenta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {  Navigator.pushReplacementNamed(context, '/admin');},
        backgroundColor: Colors.transparent, 
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black), 
      ),
    );
  }

  void _actualizarTotal(double nuevoPrecio, {bool reiniciar = false}) {
  setState(() {
    if (reiniciar) {
      _totalVenta = nuevoPrecio; // Reinicia con el nuevo precio
    } else {
      _totalVenta += nuevoPrecio; // Suma el nuevo precio
    }
  });
}



void _actualizarTotalMica(double precioMica) {
  setState(() {
    // Solo restar el precio anterior si había una mica seleccionada previamente
    if (_micaSeleccionada != null) {
      _totalVenta -= _precioMicaAnterior;
    }

    // Sumar el nuevo precio de la mica
    _totalVenta += precioMica;

    // Guardar el precio de la mica actual para futuras actualizaciones
    _precioMicaAnterior = precioMica;

    // Asegurar que el total nunca sea negativo
    if (_totalVenta < 0) {
      _totalVenta = 0.0;
    }
  });
}

void _actualizarTotalAdicional(double adicional) {
  setState(() {
    _totalVenta += adicional; // Se acumula el adicional al total
  });
}


void _actualizarTotalRevision() {
  setState(() {
    if (revisionSubsecuente) {
      _totalVenta += _costoRevision;
    } else {
      _totalVenta -= _costoRevision;
    }

    // Asegurar que el total nunca sea negativo
    if (_totalVenta < 0) {
      _totalVenta = 0.0;
    }
  });
}

void _actualizarTotalDiagnostico() {
  setState(() {

    if (diagnosticoVisual) {
      _totalVenta += _costoDiagnostico;
    } else {
      _totalVenta -= _costoDiagnostico;
    }

    // Asegurar que el total nunca sea negativo
    if (_totalVenta < 0) {
      _totalVenta = 0.0;
    }
  });
}



Widget _buildSeleccionArmazon() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _armazonesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            );
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Container();
          }

          List<Map<String, dynamic>> armazones = snapshot.data!;

          return _buildDropdownFormField(
            'Seleccionar Marca de Armazón',
            armazones.map((e) => e['marca'] as String).toList(),
            _armazonSeleccionado,
            (value) async {
              // Función para reiniciar todos los valores relacionados
              void resetValues() {
                setState(() {
                  _modeloSeleccionado = null;
                  _proveedorSeleccionado = null;
                  _micaSeleccionada = null;
                  _precioMicaAnterior = 0.0;
                  adicionalController.clear();
                  revisionSubsecuente = false;
                  diagnosticoVisual = false;
                  _totalVenta = 0.0;
                });
              }

              if (value == null) {
                resetValues();
                return;
              }

              setState(() {
                _armazonSeleccionado = value;
                resetValues();
                _actualizarModelos(value); // Cargar modelos nuevamente
              });

              // Obtener el precio del armazón seleccionado
              double precioArmazon = 0.0;
              var armazon = armazones.firstWhere(
                (e) => e['marca'] == value,
                orElse: () => {},
              );

              if (armazon.isNotEmpty && armazon.containsKey('precio')) {
                precioArmazon = (armazon['precio'] as num).toDouble();
              }

              // Reinicia el total con solo el nuevo precio del armazón
              _actualizarTotal(precioArmazon, reiniciar: true);
            },
          );
        },
      ),
      if (_armazonSeleccionado != null) _buildSeleccionModeloLente(),
    ],
  );
}

/// Método para actualizar las micas al seleccionar un proveedor
void _actualizarMicas(String? proveedor) {
  if (proveedor == null || proveedor.isEmpty) return;

  setState(() {
    _micaSeleccionada = null;
    _micasFuture = _databaseServices.getMicasPorProveedor(proveedor);
  });
}




/// Widget para seleccionar un proveedor
Widget _buildSeleccionProveedor() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _proveedoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            );
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(); // No muestra nada si no hay proveedores disponibles
          }

          List<String> proveedores = snapshot.data!
              .map((item) => item['nombre'] as String)
              .toList();

          return _buildDropdownFormField(
            'Seleccionar Proveedor',
            proveedores,
            _proveedorSeleccionado,
            (value) {
              setState(() {
                _proveedorSeleccionado = value;
                _actualizarMicas(value);
              });
            },
          );
        },
      ),
      if (_proveedorSeleccionado != null) _buildSeleccionMica(),
    ],
  );
}


/// Widget para seleccionar una mica
Widget _buildSeleccionMica() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: _micasFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: LinearProgressIndicator(),
        );
      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text("No hay micas disponibles.");
      }

      List<Map<String, dynamic>> micas = snapshot.data!;

      return _buildDropdownFormField(
        'Seleccionar Mica',
        micas,
        _micaSeleccionada,
        (value) {
          if (value == null) return;

          setState(() {
            _micaSeleccionada = value;
          });

          // Obtener la mica completa usando el ID
          var micaSeleccionada = micas.firstWhere(
            (mica) => mica['id'] == value,
            orElse: () => {},
          );

          if (micaSeleccionada.isNotEmpty && micaSeleccionada.containsKey('precio')) {
            double precioMica = (micaSeleccionada['precio'] as num).toDouble();
            _actualizarTotalMica(precioMica);
          }
        },
        isMica: true,
      );
    },
  );
}


Widget _buildDropdownFormField(
  String label,
  dynamic items,
  String? value,
  Function(String?) onChanged, {
  bool isMica = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD4AF37)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
      dropdownColor: Colors.white,
      value: value,
      selectedItemBuilder: (context) {
        return items.map<Widget>((item) {
          final displayValue = isMica ? (item as Map)['nombre'] : item as String;
          return Text(
            displayValue,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black),
          );
        }).toList();
      },
      items: isMica
          ? (items as List<Map<String, dynamic>>).map<DropdownMenuItem<String>>((item) {
              final itemId = item['id'] as String; // Usamos el ID como valor
              final itemName = item['nombre'] as String;
              return DropdownMenuItem<String>(
                value: itemId, // Usamos el ID como valor
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['tratamiento'] ?? 'Sin tratamiento'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${item['material'] ?? 'Sin material'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList()
          : (items as List<String>).map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    ),
  );
}


Widget _buildSeleccionModeloLente() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: _modelosFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: LinearProgressIndicator(),
        );
      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return Container();
      }

      List<Map<String, dynamic>> modelos = snapshot.data!;
      List<String> modeloItems = modelos.map((e) => e['modelo'] as String).toList();

      // Ensure the selected value is either null or exists in the list exactly once
      if (_modeloSeleccionado != null && !modeloItems.contains(_modeloSeleccionado)) {
        _modeloSeleccionado = null;
      }

      return _buildDropdownFormField(
        'Seleccionar Modelo de Lente',
        modeloItems,
        _modeloSeleccionado,
        (value) {
          // Función para reiniciar valores relacionados
          void resetRelatedValues() {
            setState(() {
              _proveedorSeleccionado = null;
              _micaSeleccionada = null;
              _precioMicaAnterior = 0.0;
              _micasFuture = Future.value([]); // Resetear future de micas
            });
          }

          setState(() {
            _modeloSeleccionado = value;
            if (value != null) {
              resetRelatedValues();
            }
          });

          if (value == null) {
            _actualizarTotal(0.0, reiniciar: true);
            return;
          }

          // Obtener el precio del modelo seleccionado
          double precioModelo = 0.0;
          var modelo = modelos.firstWhere((e) => e['modelo'] == value, orElse: () => {});
          if (modelo.isNotEmpty && modelo.containsKey('precio')) {
            precioModelo = (modelo['precio'] as num).toDouble();
          }

          // Obtener el precio del armazón actual
          double precioArmazon = 0.0;
          if (_armazonSeleccionado != null) {
            var armazon = snapshot.data!.firstWhere(
              (e) => e['marca'] == _armazonSeleccionado,
              orElse: () => {},
            );
            if (armazon.isNotEmpty && armazon.containsKey('precio')) {
              precioArmazon = (armazon['precio'] as num).toDouble();
            }
          }

          // Reiniciar total con el precio del armazón y el nuevo modelo de lente
          _actualizarTotal(precioArmazon + precioModelo, reiniciar: true);
        },
      );
    },
  );
}


  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, Function(String)? onChanged}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      onChanged: onChanged, // Se ejecutará cuando el usuario escriba
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD4AF37)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
    ),
  );
}

Widget _buildTextFieldConIcono(String label, TextEditingController controller, {TextInputType? keyboardType, VoidCallback? onIconPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD4AF37)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add, color:  Colors.black), // Ícono de confirmación
          onPressed: onIconPressed, // Ejecuta la acción al presionar el ícono
        ),
      ),
    ),
  );
}



Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD4AF37)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
      dropdownColor: Colors.white,
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    ),
  );
}

Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const  Color(0xFFD4AF37),
        ),
      ],
    ),
  );
}

  
  void _guardarVenta() async {
 if (_formKey.currentState!.validate()) {
    double pagado = double.tryParse(pagadoController.text) ?? 0.0;
    double total = _totalVenta;

    // Validación cuando el estatus es "Terminado"
    if (estatusSeleccionado == "Terminado") {
      if (pagado < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Para marcar como Terminado, el pago debe ser completo (\$${formatCurrency(total)})'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    // Validación de pago mínimo para otros estatus
    else {
      double minimoRequerido = total / 2;
      if (pagado < minimoRequerido) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El pago mínimo debe ser de \$${formatCurrency(minimoRequerido)}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Resto de validaciones
    if (estatusSeleccionado == null || estatusSeleccionado!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un Estatus antes de guardar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (tipoPagoSeleccionado == null || tipoPagoSeleccionado!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un Tipo de Pago antes de guardar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      DateTime now = DateTime.now();
      String fechaHoy = now.toLocal().toString().split(' ')[0];

      // Generar código de venta (idVenta)
      String year = now.year.toString().substring(2, 4);
      String month = now.month.toString().padLeft(2, '0');
      String day = now.day.toString().padLeft(2, '0');
      String codigoBase = "$year$month$day";

      // Contar ventas del día para asignar un número consecutivo
      QuerySnapshot ventasHoy = await FirebaseFirestore.instance
          .collection('ventas')
          .where('fecha', isEqualTo: fechaHoy)
          .where('idUser', isEqualTo: userId)  // Filtra por usuario
          .get();

      int contadorVenta = ventasHoy.docs.length + 1;
      String numeroVenta = contadorVenta.toString().padLeft(2, '0');  // Usa 3 dígitos
      String idVenta = "$codigoBase$numeroVenta"; // Ejemplo: 250303001

      // Crear el objeto de la venta
      Map<String, dynamic> venta = {
        'idVenta': idVenta,
        'idUser': userId,
        'fecha': now.toLocal().toString().split(' ')[0],
        'timestamp': now,
        'vendedor': vendedorController.text,
        'armazon': _armazonSeleccionado,
        'modeloLente': _modeloSeleccionado,
        'proveedor': _proveedorSeleccionado,
        'mica': _micaSeleccionada,
        'precioMica': _precioMicaAnterior,
        'tipoPago': tipoPagoSeleccionado,
        'estatus': estatusSeleccionado,
        'totalVenta': _totalVenta,
        'adicional': adicionalController.text,
        'pagado': pagado, // 🔹 Se guarda el valor validado
        'diagnosticoVisual': diagnosticoVisual,
        'revisionSubsecuente': revisionSubsecuente,
        'requiereFactura': requiereFactura,
        'cliente': clienteController.text,
        'telefono': telefonoController.text,
        'parametros': parametros
      };

      // Guardar en Firebase Firestore
      await FirebaseFirestore.instance.collection('ventas').add(venta);

      // Mostrar confirmación
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Registrado'),
            content: Text('Venta guardada exitosamente con código: $idVenta'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/admin');
                },
                child: const Text('Aceptar', style: TextStyle(color: Color(0xFFD4AF37))),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Manejo de errores
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error al guardar la venta: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Aceptar', style: TextStyle(color: Color(0xFFD4AF37))),
              ),
            ],
          );
        },
      );
    }
  }
}




void _mostrarFormularioParametros() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        //title: const Text('Parámetros Especiales'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fila 1: Ángulo Panorámico
              Row(
                children: [
                  const Expanded(child: Text('Ángulo Panorámico:',style: TextStyle(color:Colors.black))),
                  Expanded(flex: 2, child: _buildTextFieldSimple(anguloPanoramicoController, 'Ingrese el ángulo panorámico')),
                ],
              ),
              const SizedBox(height: 10),

              // Fila 2: Ángulo Puntoscópico
              Row(
                children: [
                  const Expanded(child: Text('Ángulo Puntoscópico:',style: TextStyle(color:Colors.black))),
                  Expanded(flex: 2, child: _buildTextFieldSimple(anguloPuntoscopicoController, 'Ingrese el ángulo puntoscópico')),
                ],
              ),
              const SizedBox(height: 40),

              // Fila 3: Distancia al Vértice + Campos de Ojo Derecho e Izquierdo
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Texto "Distancia al Vértice" alineado al centro con separación
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(height: 20), // Espacio superior
                        Text('Distancia al Vértice:',style: TextStyle(color:Colors.black), textAlign: TextAlign.center),
                        SizedBox(height: 25), // Espacio inferior
                      ],
                    ),
                  ), SizedBox(height: 30),
                  // Campos de Ojo Derecho e Izquierdo
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildTextFieldSimple(distanciaVerticeDerechoController, 'Ojo derecho'),
                        const SizedBox(height: 10),
                        _buildTextFieldSimple(distanciaVerticeIzquierdoController, 'Ojo izquierdo'),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Fila 4: Otro
              Row(
                children: [
                  const Expanded(child: Text('Otro:',style: TextStyle(color:Color(0xFF131443)))),
                  Expanded(flex: 2, child: _buildTextFieldSimple(otroController, 'Ingrese otro valor')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar sin guardar
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar después de guardar
            },
            child: const Text('Aceptar', style: TextStyle(color:  Color(0xFFD4AF37))),
          ),
        ],
      );
    },
  );
}

// Campo de texto con placeholder y borde azul
Widget _buildTextFieldSimple(TextEditingController controller, String hintText) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400), // Color más claro para el hintText
        filled: true,
        fillColor: Colors.transparent, // Hace el fondo transparente
        border: InputBorder.none, // Elimina el borde por defecto
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400), // Línea sutil debajo
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color:  Color(0xFFD4AF37)), // Borde al enfocar
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    ),
  );
}


Widget _buildFechaSeleccion() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: fechaController, // Asegúrate de que el controller esté asignado
      readOnly: true, // Evita que el usuario edite manualmente
      decoration: InputDecoration(
        //labelText: "Fecha",
        hintText: "YYYY-MM-DD",
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color:  Color(0xFFD4AF37)),
        ),
        suffixIcon: const Icon(Icons.calendar_today, color:  Colors.black), 
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
    ),
  );
}


Future<void> _cargarCostosUsuario(String userId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('costos')
        .doc(userId)
        .get();

    if (doc.exists) {
      setState(() {
        _costoRevision = (doc['costoRevision'] as num).toDouble();
        _costoDiagnostico = (doc['costoDiagnostico'] as num).toDouble();
      });
    }
  } catch (e) {
    print("Error al cargar costos: $e");
  }
}
}