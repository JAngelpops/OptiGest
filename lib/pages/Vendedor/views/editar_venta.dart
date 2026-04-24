import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventario/services/database_services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart'; 
import 'dart:math';

class EditarVenta extends StatefulWidget {
  final Function(Widget) onNavigate;
  final Map<String, dynamic> venta;

  const EditarVenta({super.key, required this.onNavigate, required this.venta});

  @override
  State<EditarVenta> createState() => _EditarVentaState();
}

class _EditarVentaState extends State<EditarVenta> {
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
void _actualizarMicasProveedor(String? proveedor) {
  if (proveedor == null || proveedor.isEmpty) return; // Evita valores nulos o vacíos
  setState(() {
    _micasFuture = _databaseServices.getMicasPorProveedor(proveedor);
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
    @override
  void initState() {

    // Obtener el usuario actual
    final userId = FirebaseAuth.instance.currentUser?.uid;

    super.initState();
    _proveedoresFuture = _databaseServices.getProveedores();
    _armazonesFuture = _databaseServices.getArmazones();

    // Cargar los valores seleccionados de la venta
    _armazonSeleccionado = widget.venta['armazon'];
    _modeloSeleccionado = widget.venta['modeloLente'];
    _proveedorSeleccionado = widget.venta['proveedor'];
    _micaSeleccionada = widget.venta['mica'];

    // Inicializar los controladores de texto
    armazonController.text = _armazonSeleccionado ?? '';
    proveedorController.text = _proveedorSeleccionado ?? '';
    fechaController.text = widget.venta['fecha'] ?? '';
    adicionalController.text = widget.venta['adicional'] ?? '';
    vendedorController.text = widget.venta['vendedor'] ?? '';
    anguloPanoramicoController.text = widget.venta['anguloPanoramico'] ?? '';
    anguloPuntoscopicoController.text = widget.venta['anguloPuntoscopico'] ?? '';
    distanciaVerticeDerechoController.text = widget.venta['distanciaOjoDerecho'] ?? '';
    distanciaVerticeIzquierdoController.text = widget.venta['distanciaOjoIzquierdo'] ?? '';
    telefonoController.text=widget.venta['telefono'] ?? '';
    clienteController.text = widget.venta['cliente'] ?? '';
    otroController.text = widget.venta['otro'] ?? '';
    pagadoController.text = widget.venta['pagado'].toString(); // Convertir a String


    // Inicializar los valores seleccionados
    estatusSeleccionado = widget.venta['estatus'];
    tipoPagoSeleccionado = widget.venta['tipoPago'];
    revisionSubsecuente = widget.venta['revisionSubsecuente'] ?? false;
    requiereFactura = widget.venta['requiereFactura'] ?? false;
    diagnosticoVisual = widget.venta['diagnosticoVisual'] ?? false;
    parametros = widget.venta['parametros'] ?? false;
    _totalVenta = widget.venta['totalVenta'] ?? 0.0;

    // Si hay un armazón, cargar los modelos asociados
    if (_armazonSeleccionado != null) {
      _actualizarModelos(_armazonSeleccionado);
    }

    // Si hay un proveedor, cargar las micas asociadas
    if (_proveedorSeleccionado != null) {
      _actualizarMicasProveedor(_proveedorSeleccionado);
    }

    // Cargar los costos del usuario desde Firebase
  if (userId != null) {
    _cargarCostosUsuario(userId);
  }
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
    pagadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
      title: Text(
        widget.venta['idVenta'] ?? 'Sin ID', // Muestra el idVenta o "Sin ID" si es nulo
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                           _buildTextField('Anticipo', pagadoController, keyboardType: TextInputType.number),
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
                Stack(
  children: [
    // Botón centrado "Aceptar"
    Center(
      child: ElevatedButton(
        onPressed: _guardarVenta,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Aceptar',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    ),
    
    // Botón PDF flotante a la izquierda
    Positioned(
      left: 30, // Distancia desde el borde izquierdo
      bottom: 0, // Distancia desde el borde inferior
      child: IconButton(
        onPressed: _generarPDF,
        icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red,size: 40,),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        tooltip: 'Generar PDF',
        
      ),
      
    ),
  ],
),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {  Navigator.pushReplacementNamed(context, '/vendedor');},
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
              setState(() {
                _armazonSeleccionado = value;
                _modeloSeleccionado = null;
                _proveedorSeleccionado = null;
                _micaSeleccionada = null;
                _precioMicaAnterior = 0.0;
                _totalVenta = 0.0; // Reinicia el total completamente

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
      if (_armazonSeleccionado != null) _buildSeleccionModeloLente(), // Agrega esta línea
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

      return _buildDropdownFormFieldMica(
        'Seleccionar Mica',
        micas,
        _micaSeleccionada,
        (value) {
          if (value == null) return;
          
          setState(() {
            _micaSeleccionada = value; // Guarda solo el nombre básico
          });

          // Obtener el precio de la mica seleccionada
          var mica = micas.firstWhere(
            (e) => e['nombre'] == value,
            orElse: () => {},
          );
          
          if (mica.isNotEmpty && mica.containsKey('precio')) {
            _actualizarTotalMica((mica['precio'] as num).toDouble());
          }
        },
      );
    },
  );
}


Widget _buildDropdownFormField(
  String label,
  List<String> items,
  String? value,
  Function(String?) onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white,
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
      value: items.contains(value) ? value : null, // Maneja el caso cuando value es solo parte del nombre
      items: items.map((nombreCompleto) {
        return DropdownMenuItem<String>(
          value: nombreCompleto, // Valor completo para la selección
          child: Text(nombreCompleto), // Muestra el nombre completo
        );
      }).toList(),
      onChanged: onChanged,
    ),
  );
}

Widget _buildDropdownFormFieldMica(
  String label,
  List<Map<String, dynamic>> micas,
  String? value,
  Function(String?) onChanged,
) {
  // Filtrar micas para asegurar que no haya valores nulos en el nombre
  micas = micas.where((m) => m['nombre'] != null).toList();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white,
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
      value: micas.firstWhere((m) => m['nombre'] == value, orElse: () => {})['id']?.toString(),
      selectedItemBuilder: (BuildContext context) {
        return micas.map<Widget>((mica) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              mica['nombre'],
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList();
      },
      items: micas.map((mica) {
        String nombre = mica['nombre'] as String;
        String? tratamiento = mica['tratamiento']?.toString();
        String? material = mica['material']?.toString();
        
        return DropdownMenuItem<String>(
          value: mica['id'].toString(), // Usar ID único
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (material != null && material.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Material: $material',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                if (tratamiento != null && tratamiento.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Tratamiento: $tratamiento',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          final selectedMica = micas.firstWhere((m) => m['id'].toString() == newValue);
          onChanged(selectedMica['nombre']);
        } else {
          onChanged(null);
        }
      },
      isExpanded: true,
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

      return _buildDropdownFormField(
        'Seleccionar Modelo de Lente',
        modelos.map((e) => e['modelo'] as String).toList(),
        _modeloSeleccionado,
        (value) {
          setState(() {
            _modeloSeleccionado = value;
          });

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

 String formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
  return formatter.format(value);
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
          icon: const Icon(Icons.add, color: Colors.black), // Ícono de confirmación
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
        fillColor: Colors.white,
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
          activeColor: const Color(0xFFD4AF37),
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
      // Resto del código de guardado...
      String? idDocumento;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('ventas')
          .where('idVenta', isEqualTo: widget.venta['idVenta'])
          .limit(1)
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        idDocumento = docSnapshot.docs.first.id;
      }

      if (idDocumento == null || idDocumento.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontró el ID de la venta para actualizar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      DateTime now = DateTime.now();
      String fechaFormateada = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      Map<String, dynamic> ventaActualizada = {
        'idUser': FirebaseAuth.instance.currentUser!.uid,
        'fecha': fechaFormateada,
        'vendedor': vendedorController.text,
        'armazon': _armazonSeleccionado,
        'modeloLente': _modeloSeleccionado,
        'proveedor': _proveedorSeleccionado,
        'mica': _micaSeleccionada,
        'precioMica': _precioMicaAnterior,
        'tipoPago': tipoPagoSeleccionado,
        'estatus': estatusSeleccionado,
        'totalVenta': total, 
        'cliente': clienteController.text,
        'telefono': telefonoController.text,
        'pagado': pagado,
        'adicional': adicionalController.text,
        'anguloPanoramico': anguloPanoramicoController.text,
        'anguloPuntoscopico': anguloPuntoscopicoController.text,
        'distanciaOjoDerecho': distanciaVerticeDerechoController.text,
        'distanciaOjoIzquierdo': distanciaVerticeIzquierdoController.text,
        'otro': otroController.text,
        'diagnosticoVisual': diagnosticoVisual,
        'revisionSubsecuente': revisionSubsecuente,
        'requiereFactura': requiereFactura,
        'parametros': parametros
      };

      await FirebaseFirestore.instance
          .collection('ventas')
          .doc(idDocumento)
          .update(ventaActualizada);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Venta Actualizada'),
            content: const Text('Los datos de la venta han sido actualizados correctamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/vendedor');
                },
                child: const Text('Aceptar', style: TextStyle(color: Color(0xFFD4AF37))),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo actualizar la venta: $e'),
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
                  const Expanded(child: Text('Otro:',style: TextStyle(color:Colors.black))),
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
            child: const Text('Aceptar', style: TextStyle(color: Color(0xFFD4AF37))),
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
        hintStyle: TextStyle(color: const Color.fromARGB(255, 172, 172, 172)), // Color más claro para el hintText
        filled: true,
        fillColor: Colors.transparent, // Hace el fondo transparente
        border: InputBorder.none, // Elimina el borde por defecto
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400), // Línea sutil debajo
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD4AF37)), // Borde al enfocar
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
      controller: fechaController,
      keyboardType: TextInputType.datetime, // Permite entrada manual
      decoration: InputDecoration(
        hintText: "YYYY-MM-DD",
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



Future<void> _generarPDF() async {
  final pdf = pw.Document();
  
  final ByteData imageData = await rootBundle.load('assets/logoSinFondo.png');
  final Uint8List imageBytes = imageData.buffer.asUint8List();
  final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes);

  final now = DateTime.now();
  final dia = now.day.toString().padLeft(2, '0');
  final mes = now.month.toString().padLeft(2, '0');
  final ano = now.year.toString();

  final double total = _totalVenta;
  final double anticipo = double.tryParse(pagadoController.text) ?? 0;
  final double restante = max(0, total - anticipo);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 0,
        marginBottom: 0,
       // marginLeft: 0,
        //marginRight: 0
      ),
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.robotoRegular(),
        bold: await PdfGoogleFonts.robotoBold(),
      ),
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            
            
            // Contenido principal
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Espacio para la decoración superior
                pw.SizedBox(height: 20),
                
                // Logo centrado
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Image(logoImage, width: 160, height: 160),
                  ],
                ),

                pw.SizedBox(height: 20),
                
                pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    // Columna izquierda con ID VENTA, NOMBRE y TELEFONO
    pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        // ID VENTA
        pw.Container(
          width: 300,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Row(
            children: [
              // Etiqueta
              pw.Container(
                width: 90,
                decoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(4),
                    bottomLeft: pw.Radius.circular(4),
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  'ID VENTA',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              // Dato
              pw.Container(
                width: 200,
                color: PdfColors.white,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  widget.venta['idVenta'] ?? 'N/A',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 4),

        // NOMBRE
        pw.Container(
          width: 300,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                width: 90,
                decoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(4),
                    bottomLeft: pw.Radius.circular(4),
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  'NOMBRE',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 200,
                color: PdfColors.white,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  clienteController.text,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 4),

        // TELEFONO
        pw.Container(
          width: 300,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                width: 90,
                decoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(4),
                    bottomLeft: pw.Radius.circular(4),
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  'TELÉFONO',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 200,
                color: PdfColors.white,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  telefonoController.text.isNotEmpty
                      ? telefonoController.text
                      : 'N/A',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),

    // Sección de FECHA (si ya tienes esta función definida)
    _buildDateSection(dia, mes, ano),
  ],
),


  
            pw.SizedBox(height: 40),
            

pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    // Columna izquierda ahora como Column de dos Containers
    pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        // Container para ESTATUS
        pw.Container(
          width: 280,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(4),
              bottomLeft: pw.Radius.circular(4),
              topRight: pw.Radius.circular(4),
              bottomRight: pw.Radius.circular(4)
          ),
        ),
          child: pw.Row(
            children: [
              // Etiqueta TIPO DE PAGO
              pw.Container(
                width: 90,
                decoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: const pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(4),
                    topLeft: pw.Radius.circular(4)
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  'ESTATUS',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              // Valor TIPO DE PAGO
              pw.Container(
                width: 180,
                color: PdfColors.white,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  estatusSeleccionado ?? 'N/A',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Espacio entre los dos containers
        pw.SizedBox(height: 4),
        // Container para TIPO DE PAGO
        pw.Container(
          width: 280,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(4),
              topLeft: pw.Radius.circular(4),
              bottomRight: pw.Radius.circular(4),
              topRight: pw.Radius.circular(4)
            ),
          ),
          child: pw.Row(
            children: [
              // Etiqueta TIPO DE PAGO
              pw.Container(
                width: 90,
                decoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: const pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(4),
              topLeft: pw.Radius.circular(4),
              
              ),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  'TIPO DE PAGO',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              // Valor TIPO DE PAGO
              pw.Container(
                width: 180,
                color: PdfColors.white,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  tipoPagoSeleccionado ?? 'N/A',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    
    // Container de VENDEDOR (se mantiene igual)
    pw.Container(
      height: 64,
      width: 200,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.only(
          topRight: pw.Radius.circular(4),
          bottomRight: pw.Radius.circular(4),
          topLeft: pw.Radius.circular(4),
          bottomLeft: pw.Radius.circular(4),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.black,
              borderRadius: const pw.BorderRadius.only(
                topRight: pw.Radius.circular(4),
              ),
            ),
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            child: pw.Text(
              'VENDEDOR',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Container(
            width: double.infinity,
            color: PdfColors.white,
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            child: pw.Text(
              vendedorController.text,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 14,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),

            pw.SizedBox(height: 50),
          

pw.Container(
  width: double.infinity, // Abarca todo el ancho
  decoration: pw.BoxDecoration(
    border: pw.Border.all(color: PdfColors.grey300), // Borde gris claro alrededor de toda la sección
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)), // Bordes redondeados
  ),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Parte superior: Título con fondo negro y texto blanco
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.black, // Fondo negro
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(4), // Bordes redondeados solo en la parte superior
            topRight: pw.Radius.circular(4), // Bordes redondeados solo en la parte superior
          ),
        ),
        child: pw.Text(
          'DETALLES DEL PEDIDO', 
          textAlign: pw.TextAlign.center, // Texto centrado
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 10),
      
      // Parte inferior: Detalles en texto continuo, con negrita solo en algunos casos
      if (_armazonSeleccionado != null)
        pw.Text(
          '  Armazón: ${_armazonSeleccionado!}', 
          style: pw.TextStyle(
            fontSize: 14,
           // Texto en negrita
          ),
        ),
      pw.SizedBox(height: 6),
      if (_modeloSeleccionado != null)
        pw.Text(
          '  Modelo: ${_modeloSeleccionado!}', 
          style: pw.TextStyle(
            fontSize: 14,
            
          ),
        ),
      pw.SizedBox(height: 6),
      if (_micaSeleccionada != null)
        pw.Text(
          '  Mica: ${_micaSeleccionada!}', 
          style: pw.TextStyle(
            fontSize: 14,
            
          ),
        ),
      pw.SizedBox(height: 6),
      if (diagnosticoVisual)
        pw.Text(
          '  Diagnóstico Visual: Sí', 
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.normal, // Texto sin negrita
          ),
        ),
      pw.SizedBox(height: 6),
      if (revisionSubsecuente)
        pw.Text(
          '  Revisión Subsecuente: Sí', 
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.normal, // Texto sin negrita
          ),
        ),
      pw.SizedBox(height: 6),
      if (adicionalController.text.isNotEmpty)
        pw.Text(
          '  Adicional: ${adicionalController.text}', 
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.normal, // Texto sin negrita
          ),
        ),
        pw.SizedBox(height: 12),
    ],
  ),
),



            pw.SizedBox(height: 60),
            
    // Columna de los totales
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _buildStyledTotalBox('TOTAL', total),
        pw.SizedBox(height: 4),
        _buildStyledTotalBox('ANTICIPO', anticipo),
        pw.SizedBox(height: 4),
        _buildStyledTotalBox('RESTANTE', restante),
        pw.SizedBox(height: 20), // Espacio adicional si es necesario
      ],
    ),

          ],
        ),
                
                // Agrega aquí el resto de tus widgets...
              ],
        );
      },
    ),
  );

  await _guardarPDFEnDispositivo(pdf, 'Nota_${widget.venta['idVenta'] ?? 'venta'}.pdf');
}

// Función auxiliar para la sección de fecha
pw.Widget _buildDateSection(String dia, String mes, String ano) {
  return pw.Container(
    width: 180,
    height: 100,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Column(
      children: [
        // Encabezado negro con texto blanco
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColors.black,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(4),
              topRight: pw.Radius.circular(4),
            ),
          ),
          child: pw.Text(
            'FECHA',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        // Recuadros para Día, Mes y Año
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildDateBox('DÍA', dia),
              _buildDateBox('MES', mes),
              _buildDateBox('AÑO', ano),
            ],
          ),
        ),
      ],
    ),
  );
}



//Funcion auxiliar para crear la caja de cosotos
pw.Widget _buildStyledTotalBox(String label, double value) {
  const double boxWidth = 240; // Aproximadamente 40% del ancho de una hoja A4

  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.end,
    children: [
      // Caja de etiqueta con fondo negro y texto blanco
      pw.Container(
        width: boxWidth * 0.4,
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.black,
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(4),
            bottomLeft: pw.Radius.circular(4),
          ),
        ),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      // Caja de valor con fondo blanco y texto negro
      pw.Container(
        width: boxWidth * 0.4,
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300), // Borde más tenue y sutil
          borderRadius: const pw.BorderRadius.only(
            topRight: pw.Radius.circular(4), // Cuadrado en las esquinas
            bottomRight: pw.Radius.circular(4), // Cuadrado en las esquinas
          ),
        ),
        child: pw.Text(
          '\$${value.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 12,
            
            color: PdfColors.black,
          ),
        ),
      ),
    ],
  );
}



// Función auxiliar para cajas de fecha (CORREGIDA)
pw.Widget _buildDateBox(String label, String value) {
  return pw.Container(
    width: 55,
    height: 55,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    //padding: const pw.EdgeInsets.all(6),
    child: pw.Column(
      children: [
        pw.SizedBox(height: 4),
        pw.Text(label, style:  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            
          ),
        ),
      ],
    ),
  );
}




// Función para guardar el PDF en el dispositivo
 Future<void> _guardarPDFEnDispositivo(pw.Document pdf, String fileName) async {
  try {
    // Obtener directorio de documentos
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    
    // Guardar PDF
    await file.writeAsBytes(await pdf.save());
    
    // Abrir automáticamente
    final result = await OpenFile.open(filePath);
    
    // Mostrar feedback al usuario
    if (mounted) {
      if (result.type == ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generado y abierto'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF guardado pero no se pudo abrir: ${result.message}'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Ver ubicación',
              onPressed: () => OpenFile.open(filePath),
            ),
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
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