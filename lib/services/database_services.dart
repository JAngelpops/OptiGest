import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class DatabaseServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final CollectionReference ventasCollection = _db.collection('ventas');
  late final CollectionReference clienteCollection = _db.collection('clientes');
  late final CollectionReference proveedorCollection = _db.collection('proveedores');
  late final CollectionReference armazonCollection = _db.collection('armazones');
  late final CollectionReference estuchesCollection = _db.collection('estuches');
  late final CollectionReference solucionesLCCollection = _db.collection('solucionesLC');
  late final CollectionReference panosCollection = _db.collection('panos');
  late final CollectionReference solucionesLimpiadorasCollection = _db.collection('solucionesLimpiadoras');
  late final CollectionReference tornillosCollection = _db.collection('tornillos');
  late final CollectionReference plaquetasCollection = _db.collection('plaquetas');
  late final CollectionReference cordonesCollection = _db.collection('cordones');
  late final CollectionReference sujetaLentesCollection = _db.collection('sujetaLentes');
  late final CollectionReference gastosCollection = _db.collection('gastos');
  late final CollectionReference cajaChicaCollection = _db.collection('cajaChica');
  late final CollectionReference prediccionesCollection = _db.collection('predicciones');


  // Obtener ventas del usuario autenticado (con opción de filtrar por estatus)
  Future<List<Map<String, dynamic>>> getVentas({String? estatus}) async {
  User? user = _auth.currentUser;
  if (user == null) throw Exception('Usuario no autenticado');

  Query query = ventasCollection.where('idUser', isEqualTo: user.uid);

  // 🔹 Obtener la fecha de inicio y fin del mes actual
  DateTime now = DateTime.now();
  Timestamp tsInicio = Timestamp.fromDate(DateTime(now.year, now.month, 1));
  Timestamp tsFin = Timestamp.fromDate(DateTime(now.year, now.month + 1, 0, 23, 59, 59));

  query = query
      .where('timestamp', isGreaterThanOrEqualTo: tsInicio)
      .where('timestamp', isLessThanOrEqualTo: tsFin);

  // 🔹 Si hay un filtro de estatus, lo aplicamos
  if (estatus != null && estatus.isNotEmpty) {
    query = query.where('estatus', isEqualTo: estatus);
  }

  print("🔍 Ejecutando consulta con:");
  print(" - idUser: ${user.uid}");
  print(" - Timestamp >= $tsInicio");
  print(" - Timestamp <= $tsFin");
  if (estatus != null && estatus.isNotEmpty) print(" - Estatus: $estatus");

  try {
    QuerySnapshot result = await query.get();
    print("✅ Ventas encontradas: ${result.docs.length}");
    return result.docs.map((e) {
      Map<String, dynamic> data = e.data() as Map<String, dynamic>;
      data['id'] = e.id;
      return data;
    }).toList();
  } catch (e) {
    print("❌ Error al obtener ventas: $e");
    return [];
  }

}

Future<List<Map<String, dynamic>>> getVentasPorFecha(Timestamp inicio, Timestamp fin) async {
  User? user = _auth.currentUser;
  if (user == null) throw Exception('Usuario no autenticado');

  Query query = ventasCollection
      .where('idUser', isEqualTo: user.uid)
      .where('timestamp', isGreaterThanOrEqualTo: inicio)
      .where('timestamp', isLessThanOrEqualTo: fin);

  try {
    QuerySnapshot result = await query.get();
    print("✅ Ventas encontradas: ${result.docs.length}"); // 🔍 Depuración

    return result.docs.map((e) {
      Map<String, dynamic> data = e.data() as Map<String, dynamic>;
      data['id'] = e.id;
      return data;
    }).toList();
  } catch (e) {
    print("❌ Error al obtener ventas por fecha: $e");
    return [];
  }
}

//Obtener datos de las ventas

Future<List<FlSpot>> obtenerDatosVentas() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('ventas')
      .orderBy('timestamp', descending: false) // Ordenar por fecha
      .get();

  List<FlSpot> puntos = [];
  int i = 0;

  for (var doc in querySnapshot.docs) {
    double total = (doc['totalVenta'] as num).toDouble();
    puntos.add(FlSpot(i.toDouble(), total));
    i++;
  }
  return puntos;
}


  // Agregar una nueva venta
  Future<void> addVenta(Map<String, dynamic> ventaData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    ventaData['idUser'] = user.uid;
    ventaData['email'] = user.email;
    ventaData['timestamp'] = FieldValue.serverTimestamp();

    await ventasCollection.add(ventaData);
  }

  // Agregar un nuevo cliente
  Future<void> addCliente(Map<String, dynamic> clienteData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no identificado');

    clienteData['idUser'] = user.uid;
    clienteData['timestamp'] = FieldValue.serverTimestamp();

    await clienteCollection.add(clienteData);
  }

  // Metodó para obtener clientes (opcionalmente filtrados por usuario)
  Future<List<Map<String, dynamic>>> getClientes({String? idUser}) async {
    Query query = clienteCollection;

    if (idUser != null && idUser.isNotEmpty) {
      query = query.where('idUser', isEqualTo: idUser);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  //Método para agregar armazon

   Future<void> addArmazon(Map<String, dynamic> armazonData) async {
  User? user = _auth.currentUser;
  if (user == null) throw Exception('Usuario no identificado');

  armazonData['idUser'] = user.uid;
  armazonData['timestamp'] = FieldValue.serverTimestamp();

  // Agregar el armazón solo una vez
  await armazonCollection.add(armazonData);
}



  // Obtener armazones (opcionalmente filtrados por usuario)
  Future<List<Map<String, dynamic>>> getArmazones({String? idUser}) async {
    Query query = armazonCollection;

    if (idUser != null && idUser.isNotEmpty) {
      query = query.where('idUser', isEqualTo: idUser);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Actualizar datos de un armazón
  Future<void> updateArmazon(String armazonId, Map<String, dynamic> armazonData) async {
    try {
      await armazonCollection.doc(armazonId).update(armazonData);
    } catch (e) {
      throw Exception('Error al actualizar el armazón: $e');
    }
  }

  // Obtener los lentes de un armazón específico
  Future<List<Map<String, dynamic>>> getLentes(String armazonId) async {
    QuerySnapshot querySnapshot =
        await armazonCollection.doc(armazonId).collection('lentes').get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
  //Método para eliminar un armazon
  Future<void> deleteArmazon(String armazonId) async {
  try {
    //  Eliminar todos los lentes dentro del armazón antes de eliminarlo
    final lentesCollection = FirebaseFirestore.instance
        .collection('armazones')
        .doc(armazonId)
        .collection('lentes');

    final lentesSnapshot = await lentesCollection.get();
    for (var doc in lentesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Ahora sí eliminar el armazón
    await FirebaseFirestore.instance.collection('armazones').doc(armazonId).delete();

    print(" Armazón y sus lentes eliminados correctamente");
  } catch (e) {
    print(" Error al eliminar armazón: $e");
    throw Exception("Error al eliminar armazón: $e");
  }
}

  // Agregar un lente a un armazón específico
  Future<void> addLente(String armazonId, Map<String, dynamic> lenteData) async {
    await armazonCollection.doc(armazonId).collection('lentes').add(lenteData);
  }

  // Actualizar datos de un lente específico dentro de un armazón
  Future<void> updateLente(String armazonId, String lenteId, Map<String, dynamic> lenteData) async {
    DocumentReference lenteRef = armazonCollection.doc(armazonId).collection('lentes').doc(lenteId);
    
    await lenteRef.update(lenteData).catchError((error) {
      throw Exception("Error al actualizar lente: $error");
    });
  }


// Agregar una nueva solución LC con subcolección "soluciones"
Future<void> addSolucionesLC(Map<String, dynamic> solucionesLCData) async {
  User? user = _auth.currentUser;
  if (user == null) throw Exception('Usuario no identificado');

  solucionesLCData['idUser'] = user.uid;
  solucionesLCData['timestamp'] = FieldValue.serverTimestamp();

  // Agregar la solución LC sin crear un documento vacío en la subcolección
  await solucionesLCCollection.add(solucionesLCData);
}


// Obtener las soluciones de una solución LC específica
Future<List<Map<String, dynamic>>> getSoluciones(String solucionLCId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('solucionesLC')
        .doc(solucionLCId)
        .collection('soluciones')
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("No se encontraron soluciones.");
      return [];
    }

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Agregar el ID del documento
      return data;
    }).toList();
  } catch (e) {
    print("Error al obtener soluciones: $e");
    return [];
  }
}


// Agregar una nueva solución a una solución LC existente
Future<void> addSolucion(String solucionLCId, Map<String, dynamic> solucionData) async {
  await solucionesLCCollection.doc(solucionLCId).collection('soluciones').add(solucionData);
}

// Actualizar datos de una solución LC
Future<void> updateSolucionLC(String solucionId, Map<String, dynamic> solucionLCData) async {
  try {
    await solucionesLCCollection.doc(solucionId).update(solucionLCData);
  } catch (e) {
    throw Exception('Error al actualizar la solución LC: $e');
  }
}

// Método para eliminar una solución LC
Future<void> deleteSolucionLC(String solucionId) async {
  try {
    // 🔹 Referencia al documento de la solución LC
    DocumentReference solucionRef = FirebaseFirestore.instance.collection('solucionesLC').doc(solucionId);

    // 🔹 Obtener la subcolección 'soluciones' y eliminar sus documentos
    QuerySnapshot solucionesSnapshot = await solucionRef.collection('soluciones').get();
    for (var doc in solucionesSnapshot.docs) {
      await doc.reference.delete();
    }

    // 🔹 Eliminar el documento principal de la solución LC
    await solucionRef.delete();

    print("✅ Solución LC eliminada correctamente.");
  } catch (e) {
    print("❌ Error al eliminar la solución LC: $e");
    throw Exception("No se pudo eliminar la solución LC.");
  }
}


  // Agregar un nuevo estuche con la subcolección "características"
Future<void> addEstuche(Map<String, dynamic> estucheData) async {
  User? user = _auth.currentUser;
  if (user == null) throw Exception('Usuario no identificado');

  estucheData['idUser'] = user.uid;
  estucheData['timestamp'] = FieldValue.serverTimestamp();

  // Agregar el estuche sin crear un documento vacío en la subcolección
  await estuchesCollection.add(estucheData);
}


// Obtener las características de un estuche específico
Future<List<Map<String, dynamic>>> getCaracteristicas(String estucheId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('estuches')
        .doc(estucheId)
        .collection('caracteristicas')
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("No se encontraron características.");
      return [];
    }

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Agregar el ID del documento
      return data;
    }).toList();
  } catch (e) {
    print("Error al obtener características: $e");
    return [];
  }
}

// Agregar una nueva característica a un estuche existente
Future<void> addCaracteristica(String estucheId, Map<String, dynamic> caracteristicaData) async {
  await estuchesCollection.doc(estucheId).collection('caracteristicas').add(caracteristicaData);
}

// Actualizar datos de un estuche
Future<void> updateEstuche(String estucheId, Map<String, dynamic> estucheData) async {
  try {
    await estuchesCollection.doc(estucheId).update(estucheData);
  } catch (e) {
    throw Exception('Error al actualizar el estuche: $e');
  }
}

// Actualizar datos de una característica específica dentro de un estuche
Future<void> updateCaracteristica(String estucheId, String caracteristicaId, Map<String, dynamic> caracteristicaData) async {
  try {
    await estuchesCollection.doc(estucheId).collection('caracteristicas').doc(caracteristicaId).update(caracteristicaData);
  } catch (e) {
    throw Exception('Error al actualizar la característica: $e');
  }
}

// Método para eliminar un estuche
Future<void> deleteEstuche(String estucheId) async {
  try {
    // 🔹 Referencia al documento del estuche
    DocumentReference estucheRef = FirebaseFirestore.instance.collection('estuches').doc(estucheId);

    // 🔹 Obtener la subcolección 'caracteristicas' y eliminar sus documentos
    QuerySnapshot caracteristicasSnapshot = await estucheRef.collection('caracteristicas').get();
    for (var doc in caracteristicasSnapshot.docs) {
      await doc.reference.delete();
    }

    // 🔹 Eliminar el documento principal del estuche
    await estucheRef.delete();

    print("Estuche eliminado correctamente.");
  } catch (e) {
    print("Error al eliminar el estuche: $e");
    throw Exception("No se pudo eliminar el estuche.");
  }
}

  // Agregar un nuevo pano
  Future<void> addPano(Map<String, dynamic> panoData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no identificado');

    panoData['idUser'] = user.uid;
    panoData['timestamp'] = FieldValue.serverTimestamp();

    await panosCollection.add(panoData);
  }

  // Metodó para obtener paños (opcionalmente filtrados por usuario)
  Future<List<Map<String, dynamic>>> getPanos({String? idUser}) async {
    Query query = panosCollection;

    if (idUser != null && idUser.isNotEmpty) {
      query = query.where('idUser', isEqualTo: idUser);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  //Método para actualizar el estuche
  Future<void> updatePano(String panoId, Map<String, dynamic> panoData) async {
  try {
    await panosCollection.doc(panoId).update(panoData);
  } catch (e) {
    throw Exception('Error al actualizar el paño: $e');
  }
}

// Método para eliminar un paño
Future<void> deletePano(String panoId) async {
  try {
    // 🔹 Referencia al documento del paño
    DocumentReference panoRef = FirebaseFirestore.instance.collection('panos').doc(panoId);

    // 🔹 Obtener la subcolección 'caracteristicas' y eliminar sus documentos
    QuerySnapshot caracteristicasSnapshot = await panoRef.collection('caracteristicas').get();
    for (var doc in caracteristicasSnapshot.docs) {
      await doc.reference.delete();
    }

    // 🔹 Eliminar el documento principal del paño
    await panoRef.delete();

    print(" Paño eliminado correctamente.");
  } catch (e) {
    print(" Error al eliminar el paño: $e");
    throw Exception("No se pudo eliminar el paño.");
  }
}

  // Agregar una nueva solucion limpiadora
  Future<void> addSolucionesLimpiadoras(Map<String, dynamic> solucionesLimpiadorasData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no identificado');

    solucionesLimpiadorasData['idUser'] = user.uid;
    solucionesLimpiadorasData['timestamp'] = FieldValue.serverTimestamp();

    await solucionesLimpiadorasCollection.add(solucionesLimpiadorasData);
  }

  // Metodó para obtener soluciones limpiadoras (opcionalmente filtrados por usuario)
  Future<List<Map<String, dynamic>>> getSolucionesLimpiadoras({String? idUser}) async {
    Query query = solucionesLimpiadorasCollection;

    if (idUser != null && idUser.isNotEmpty) {
      query = query.where('idUser', isEqualTo: idUser);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
//Método para actualizar el solucionesLimpiadoraa
  Future<void> updateSolucionesLimpiadoras(String solucionesLimpiadorasId, Map<String, dynamic> solucionesLimpiadorasData) async {
  try {
    await solucionesLimpiadorasCollection.doc(solucionesLimpiadorasId).update(solucionesLimpiadorasData);
  } catch (e) {
    throw Exception('Error al actualizar la solucion: $e');
  }
}

//Método para eliminar la solucion limpiadora

Future<void> deleteSolucionesLimpiadoras(String solucionId) async {
  try {
    // 🔹 Referencia a la colección de soluciones limpiadoras
    DocumentReference solucionRef = FirebaseFirestore.instance.collection('solucionesLimpiadoras').doc(solucionId);

    // 🔹 Obtener la subcolección 'caracteristicas' y eliminar sus documentos
    QuerySnapshot caracteristicasSnapshot = await solucionRef.collection('caracteristicas').get();
    for (var doc in caracteristicasSnapshot.docs) {
      await doc.reference.delete();
    }

    // 🔹 Eliminar el documento principal de la solución limpiadora
    await solucionRef.delete();

    print(" Solución limpiadora eliminada correctamente.");
  } catch (e) {
    print(" Error al eliminar la solución limpiadora: $e");
    throw Exception("No se pudo eliminar la solución limpiadora.");
  }
}

  // Agregar un nuevo tornillo
  Future<void> addTornillo(Map<String, dynamic> tornillosData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no identificado');

    tornillosData['idUser'] = user.uid;
    tornillosData['timestamp'] = FieldValue.serverTimestamp();

    await tornillosCollection.add(tornillosData);
  }  

  // Metodó para obtener tornillos (opcionalmente filtrados por usuario)
  Future<List<Map<String, dynamic>>> getTornillos({String? idUser}) async {
    Query query = tornillosCollection;

    if (idUser != null && idUser.isNotEmpty) {
      query = query.where('idUser', isEqualTo: idUser);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  //Método para actualizar el estuche
  Future<void> updateTornillo(String tornilloId, Map<String, dynamic> tornilloData) async {
  try {
    await tornillosCollection.doc(tornilloId).update(tornilloData);
  } catch (e) {
    throw Exception('Error al actualizar el tornillo: $e');
  }
}

// Método para eliminar un Tornillo
Future<void> deleteTornillo(String tornilloId) async {
  try {
    // 🔹 Referencia al documento del Tornillo
    DocumentReference tornilloRef = FirebaseFirestore.instance.collection('tornillos').doc(tornilloId);

    // 🔹 Obtener la subcolección 'caracteristicas' y eliminar sus documentos
    QuerySnapshot caracteristicasSnapshot = await tornilloRef.collection('caracteristicas').get();
    for (var doc in caracteristicasSnapshot.docs) {
      await doc.reference.delete();
    }

    // 🔹 Eliminar el documento principal del Tornillo
    await tornilloRef.delete();

    print("✅ Tornillo eliminado correctamente.");
  } catch (e) {
    print("❌ Error al eliminar el Tornillo: $e");
    throw Exception("No se pudo eliminar el Tornillo.");
  }
}


  // Agregar una nueva plaqueta
  Future<void> addPlaqueta(Map<String, dynamic> plaquetasData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no identificado');

    plaquetasData['idUser'] = user.uid;
    plaquetasData['timestamp'] = FieldValue.serverTimestamp();

    await plaquetasCollection.add(plaquetasData);
  } 

  // Metodó para obtener plaquetas (opcionalmente filtrados por usuario)
  Future<List<Map<String, dynamic>>> getPlaquetas({String? idUser}) async {
    Query query = plaquetasCollection;

    if (idUser != null && idUser.isNotEmpty) {
      query = query.where('idUser', isEqualTo: idUser);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  //Método para actualizar la plaqueta
  Future<void> updatePlaqueta(String plaquetaId, Map<String, dynamic> plaquetaData) async {
  try {
    await plaquetasCollection.doc(plaquetaId).update(plaquetaData);
  } catch (e) {
    throw Exception('Error al actualizar la plaqueta: $e');
  }
}

// Método para eliminar una plaqueta
Future<void> deletePlaqueta(String plaquetaId) async {
  try {
    // 🔹 Referencia al documento de la plaqueta
    DocumentReference plaquetaRef = FirebaseFirestore.instance.collection('plaquetas').doc(plaquetaId);

    // 🔹 Obtener la subcolección 'caracteristicas' y eliminar sus documentos
    QuerySnapshot caracteristicasSnapshot = await plaquetaRef.collection('caracteristicas').get();
    for (var doc in caracteristicasSnapshot.docs) {
      await doc.reference.delete();
    }

    // 🔹 Eliminar el documento principal de la plaqueta
    await plaquetaRef.delete();

    print(" Plaqueta eliminada correctamente.");
  } catch (e) {
    print(" Error al eliminar la plaqueta: $e");
    throw Exception("No se pudo eliminar la plaqueta.");
  }
}

  // Agregar un nuevo cordon
  Future<void> addCordon(Map<String, dynamic> cordonesData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no identificado');

    cordonesData['idUser'] = user.uid;
    cordonesData['timestamp'] = FieldValue.serverTimestamp();

    await cordonesCollection.add(cordonesData);
  } 

  // Metodó para obtener cordones (opcionalmente filtrados por usuario)
  Future<List<Map<String, dynamic>>> getCordones({String? idUser}) async {
    Query query = cordonesCollection;

    if (idUser != null && idUser.isNotEmpty) {
      query = query.where('idUser', isEqualTo: idUser);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  //Método para actualizar el cordon
  Future<void> updateCordon(String cordonId, Map<String, dynamic> cordonData) async {
  try {
    await cordonesCollection.doc(cordonId).update(cordonData);
  } catch (e) {
    throw Exception('Error al actualizar el cordon: $e');
  }
}

 // Método para eliminar un cordón
Future<void> deleteCordon(String cordonId) async {
  try {
    // 🔹 Referencia al documento del cordón
    DocumentReference cordonRef = FirebaseFirestore.instance.collection('cordones').doc(cordonId);

    // 🔹 Obtener la subcolección 'caracteristicas' y eliminar sus documentos
    QuerySnapshot caracteristicasSnapshot = await cordonRef.collection('caracteristicas').get();
    for (var doc in caracteristicasSnapshot.docs) {
      await doc.reference.delete();
    }

    // 🔹 Eliminar el documento principal del cordón
    await cordonRef.delete();

    print(" Cordón eliminado correctamente.");
  } catch (e) {
    print(" Error al eliminar el cordón: $e");
    throw Exception("No se pudo eliminar el cordón.");
  }
}

  // Agregar un nuevo sujeta lentes
  Future<void> addSujetaLentes(Map<String, dynamic> sujetaLentesData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no identificado');

    sujetaLentesData['idUser'] = user.uid;
    sujetaLentesData['timestamp'] = FieldValue.serverTimestamp();

    await sujetaLentesCollection.add(sujetaLentesData);
  } 

  // Metodó para obtener sujeta lentes (opcionalmente filtrados por usuario)
  Future<List<Map<String, dynamic>>> getSujetaLentes({String? idUser}) async {
    Query query = sujetaLentesCollection;

    if (idUser != null && idUser.isNotEmpty) {
      query = query.where('idUser', isEqualTo: idUser);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  //Método para actualizar el sujetalentes
  Future<void> updateSujetaLentes(String sujetaLentesId, Map<String, dynamic> sujetaLentesData) async {
  try {
    await sujetaLentesCollection.doc(sujetaLentesId).update(sujetaLentesData);
  } catch (e) {
    throw Exception('Error al actualizar el sujeta lentes: $e');
  }
}

// Método para eliminar un Sujeta Lentes
Future<void> deleteSujetaLentes(String sujetaLentesId) async {
  try {
    // 🔹 Referencia al documento del sujeta lentes
    DocumentReference sujetaLentesRef = FirebaseFirestore.instance.collection('sujetaLentes').doc(sujetaLentesId);

    // 🔹 Obtener la subcolección 'caracteristicas' y eliminar sus documentos
    QuerySnapshot caracteristicasSnapshot = await sujetaLentesRef.collection('caracteristicas').get();
    for (var doc in caracteristicasSnapshot.docs) {
      await doc.reference.delete();
    }

    // 🔹 Eliminar el documento principal del sujeta lentes
    await sujetaLentesRef.delete();

    print("✅ Sujeta Lentes eliminado correctamente.");
  } catch (e) {
    print("❌ Error al eliminar el Sujeta Lentes: $e");
    throw Exception("No se pudo eliminar el Sujeta Lentes.");
  }
}


  // Obtener Proveedores (opcionalmente filtrados por usuario)
  Future<List<Map<String, dynamic>>> getProveedores({String? idUser}) async {
    Query query = proveedorCollection;

    if (idUser != null && idUser.isNotEmpty) {
      query = query.where('idUser', isEqualTo: idUser);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Agregar un proveedor con una subcolección "micas"
  Future<void> addProveedor(Map<String, dynamic> proveedorData) async {
  User? user = _auth.currentUser;
  if (user == null) throw Exception('Usuario no identificado');

  proveedorData['idUser'] = user.uid;
  proveedorData['timestamp'] = FieldValue.serverTimestamp();

  // Agregar proveedor a Firestore sin crear una mica vacía
  await proveedorCollection.add(proveedorData);
}


  // Obtener las micas de un proveedor específico
  Future<List<Map<String, dynamic>>> getMicas(String proveedorId) async {
    QuerySnapshot querySnapshot =
        await proveedorCollection.doc(proveedorId).collection('micas').get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Metodó para agregar una mica a un proveedor específico
  Future<void> addMica(String proveedorId, Map<String, dynamic> micaData) async {
    await proveedorCollection.doc(proveedorId).collection('micas').add(micaData);
  }

  // Método para actualizar datos de un proveedor
  Future<void> updateProveedor(String proveedorId, Map<String, dynamic> proveedorData) async {
    await proveedorCollection.doc(proveedorId).update(proveedorData);
  }

  //Método para eliminar un provedor en espeficico
  Future<void> deleteProveedor(String proveedorId) async {
  try {
    // Eliminar todas las micas dentro del proveedor antes de eliminarlo
    var micasRef = FirebaseFirestore.instance
        .collection('proveedores')
        .doc(proveedorId)
        .collection('micas');

    var micasSnapshot = await micasRef.get();
    for (var doc in micasSnapshot.docs) {
      await doc.reference.delete();
    }

    // Ahora elimina el proveedor
    await FirebaseFirestore.instance.collection('proveedores').doc(proveedorId).delete();
    
    print(" Proveedor eliminado correctamente.");
  } catch (e) {
    print(" Error al eliminar proveedor: $e");
    throw Exception("Error al eliminar proveedor: $e");
  }
}

  // Método para eliminar una mica en espeficio
  Future<void> deleteMica(String proveedorId, String micaId) async {
  try {
    await FirebaseFirestore.instance
        .collection('proveedores')
        .doc(proveedorId)
        .collection('micas')
        .doc(micaId)
        .delete();

    print(" Mica eliminada con éxito: $micaId");
  } catch (e) {
    print(" Error al eliminar mica: $e");
    throw Exception('No se pudo eliminar la mica: $e');
  }
}


  // Método para actualizar datos de un cliente
  Future<void> updateCliente(String clienteId, Map<String, dynamic> clienteData) async {
    await clienteCollection.doc(clienteId).update(clienteData);
  }

  // Método para eliminar un cliente por su ID
Future<void> deleteCliente(String clienteId) async {
  try {
    await clienteCollection.doc(clienteId).delete();
    print("Cliente eliminado correctamente");
  } catch (e) {
    throw Exception('Error al eliminar cliente: $e');
  }
}


    // Método para actualizar datos de una mica específica de un proveedor
  Future<void> updateMica(String proveedorId, String micaId, Map<String, dynamic> micaData) async {
  print("Intentando actualizar mica:");
  print("Proveedor ID: $proveedorId");
  print("Mica ID: $micaId");

  DocumentReference micaRef = FirebaseFirestore.instance
      .collection('proveedores')
      .doc(proveedorId)
      .collection('micas')
      .doc(micaId);

  await micaRef.update(micaData).catchError((error) {
    print("Error al actualizar mica: $error");
  });

  print("Mica actualizada correctamente");
}

// Obtener los modelos de lentes de una marca específica de armazón
Future<List<Map<String, dynamic>>> getModelosPorArmazon(String marcaArmazon) async {
  try {
    // Buscar los armazones que coincidan con la marca seleccionada
    QuerySnapshot armazonesSnapshot = await armazonCollection.where('marca', isEqualTo: marcaArmazon).get();

    if (armazonesSnapshot.docs.isEmpty) {
      print("No se encontraron armazones con esta marca.");
      return [];
    }

    // Tomar el primer armazón encontrado (asumiendo que las marcas son únicas)
    String armazonId = armazonesSnapshot.docs.first.id;

    // Obtener los modelos (lentes) de la subcolección "lentes" dentro del armazón
    QuerySnapshot lentesSnapshot = await armazonCollection.doc(armazonId).collection('lentes').get();

    return lentesSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Agregar el ID del documento
      return data;
    }).toList();
  } catch (e) {
    print("Error al obtener modelos de lentes: $e");
    return [];
  }
}

// Obtener las micas de un proveedor específico
Future<List<Map<String, dynamic>>> getMicasPorProveedor(String nombreProveedor) async {
  try {
    // Buscar el proveedor por nombre y obtener su ID
    QuerySnapshot proveedoresSnapshot = await proveedorCollection
        .where('nombre', isEqualTo: nombreProveedor)
        .get();

    if (proveedoresSnapshot.docs.isEmpty) {
      print("⚠️ No se encontró proveedor con el nombre: $nombreProveedor");
      return [];
    }

    String proveedorId = proveedoresSnapshot.docs.first.id;

    // Obtener las micas de la subcolección "micas" dentro del proveedor
    QuerySnapshot micasSnapshot =
        await proveedorCollection.doc(proveedorId).collection('micas').get();

    if (micasSnapshot.docs.isEmpty) {
      print("⚠️ No se encontraron micas para el proveedor: $nombreProveedor");
      return [];
    }

    return micasSnapshot.docs.map((doc) {
      return {
        'id': doc.id, // ID de la mica
        'proveedorId': proveedorId, // ID del proveedor padre
        ...doc.data() as Map<String, dynamic>, // Todos los campos de la mica
      };
    }).toList();
  } catch (e) {
    print("❌ Error al obtener micas: $e");
    return [];
  }
}



// Obtener los tratamientos de una mica específica
Future<List<Map<String, dynamic>>> getTratamientosPorMica(String micaId) async {
  try {
    QuerySnapshot querySnapshot =
        await proveedorCollection.doc(micaId).collection('tratamientos').get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Agregar el ID del tratamiento
      return data;
    }).toList();
  } catch (e) {
    print("Error al obtener tratamientos: $e");
    return [];
  }
}

// Obtener los materiales de un tratamiento específico
Future<List<Map<String, dynamic>>> getMaterialesPorTratamiento(String tratamientoId) async {
  try {
    QuerySnapshot querySnapshot =
        await proveedorCollection.doc(tratamientoId).collection('materiales').get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Agregar el ID del material
      return data;
    }).toList();
  } catch (e) {
    print("Error al obtener materiales: $e");
    return [];
  }
}


Future<List<Map<String, dynamic>>> getArmazonesPorUsuario(String? userId) async {
    if (userId == null) return [];
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('armazones')
          .where('idUser', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error al obtener armazones: $e");
      return [];
    }
  }

 Future<List<Map<String, dynamic>>> getProveedoresPorUsuario(String? userId) async {
    if (userId == null) return [];
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('proveedores')
          .where('idUser', isEqualTo: userId) 
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error al obtener proveedores: $e");
      return [];
    }
  }


// Método para agregar un gasto
Future<void> addGasto(Map<String, dynamic> gastoData) async {
  User? user = _auth.currentUser;
  if (user == null) throw Exception('Usuario no autenticado');

  gastoData['idUser'] = user.uid;
  gastoData['email'] = user.email;
  
  await gastosCollection.add(gastoData);
}

// Método para agregar una predicción
Future<void> addPrediccion(Map<String, dynamic> prediccionData) async {
  User? user = _auth.currentUser;
  if (user == null) throw Exception('Usuario no autenticado');

  prediccionData['idUser'] = user.uid;
  prediccionData['email'] = user.email;
  
  await prediccionesCollection.add(prediccionData);
}

// Método para obtener gastos (opcionalmente filtrados por usuario y rango de fechas)
Future<List<Map<String, dynamic>>> getGastos({String? idUser, Timestamp? desde, Timestamp? hasta}) async {
  Query query = gastosCollection;

  if (idUser != null && idUser.isNotEmpty) {
    query = query.where('idUser', isEqualTo: idUser);
  }

  if (desde != null && hasta != null) {
    query = query.where('fecha', isGreaterThanOrEqualTo: desde)
                 .where('fecha', isLessThanOrEqualTo: hasta);
  }

  QuerySnapshot querySnapshot = await query.get();
  return querySnapshot.docs.map((doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }).toList();
}

// Método para obtener predicciones (opcionalmente filtradas por usuario y año)
Future<List<Map<String, dynamic>>> getPredicciones({String? idUser, int? anio}) async {
  Query query = prediccionesCollection;

  if (idUser != null && idUser.isNotEmpty) {
    query = query.where('idUser', isEqualTo: idUser);
  }

  if (anio != null) {
    query = query.where('anio', isEqualTo: anio);
  }

  QuerySnapshot querySnapshot = await query.get();
  return querySnapshot.docs.map((doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }).toList();
}


// Modificar la función para recibir y usar el userId
Future<DocumentSnapshot?> getPrediccionByYearAndMonth(
  int anio, 
  int mes, 
  String userId // <- Nuevo parámetro
) async {
  try {
    final query = await FirebaseFirestore.instance
        .collection('predicciones')
        .where('idUser', isEqualTo: userId) // <- Filtro por usuario
        .where('anio', isEqualTo: anio)
        .where('mes', isEqualTo: mes)
        .limit(1)
        .get();

    return query.docs.isNotEmpty ? query.docs.first : null;
  } catch (e) {
    print('Error buscando predicción: $e');
    return null;
  }
}

Future<void> updatePrediccion(String docId, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance
      .collection('predicciones')
      .doc(docId)
      .update(data);
}


Future<List<Map<String, dynamic>>> getGastosPorFecha(String userId, DateTime desde, DateTime hasta) async {
  try {
    QuerySnapshot query = await gastosCollection
        .where('idUser', isEqualTo: userId)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(hasta))
        .orderBy('fecha', descending: true)
        .get();

    return query.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  } catch (e) {
    print('Error al obtener gastos: $e');
    return [];
  }
}

// Métodos para Caja Chica
Future<void> addCajaChica(Map<String, dynamic> cajaChicaData) async {
  User? user = _auth.currentUser;
  if (user == null) throw Exception('Usuario no autenticado');

  cajaChicaData['idUser'] = user.uid;
  cajaChicaData['timestamp'] = FieldValue.serverTimestamp();
  
  await cajaChicaCollection.add(cajaChicaData);
}

Future<List<Map<String, dynamic>>> getCajaChicaPorFecha(String userId, DateTime desde, DateTime hasta) async {
  try {
    QuerySnapshot query = await cajaChicaCollection
        .where('idUser', isEqualTo: userId)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(hasta))
        .orderBy('fecha', descending: true)
        .get();

    return query.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  } catch (e) {
    print('Error al obtener caja chica: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getPrediccionesPorUsuario(String userId) async {
  try {
    QuerySnapshot query = await prediccionesCollection
        .where('idUser', isEqualTo: userId)
        .orderBy('anio', descending: true)
        .orderBy('mes', descending: true)
        .get();

    return query.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  } catch (e) {
    print('Error al obtener predicciones: $e');
    return [];
  }
}
 
}