import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
       appBar: AppBar (
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Botón de eliminar cuenta en AppBar
          TextButton.icon(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text(
              "Eliminar Cuenta",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => _showDeleteAccountDialog(context),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculamos el tamaño de las cards basado en el ancho de pantalla
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          
          // Tamaño de las cards (adaptable pero con límites)
          final cardWidth = (screenWidth * 0.4).clamp(150.0, 220.0);
          final cardHeight = (screenHeight * 0.3).clamp(160.0, 220.0);
          
          // Espacio entre cards (5% del ancho pero mínimo 20px)
          final spaceBetween = (screenWidth * 0.05).clamp(20.0, 60.0);
          
          // Tamaño de iconos (relativo al tamaño de la card)
          final iconSize = cardWidth * 0.25;
          
          // Tamaño de texto (adaptable)
          final textSize = cardWidth * 0.06;

          return Center(
            child: user != null
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAdminCard(
                              context: context,
                              width: cardWidth,
                              height: cardHeight,
                              iconSize: iconSize,
                              textSize: textSize,
                              user: user,
                            ),
                            SizedBox(width: spaceBetween),
                            _buildUserCard(
                              context: context,
                              width: cardWidth,
                              height: cardHeight,
                              iconSize: iconSize,
                              textSize: textSize,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Text(
                    "No hay usuario autenticado",
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
          );
        },
      ),
      floatingActionButton: _buildLogoutButton(context),
    );
  }

  Widget _buildAdminCard({
    required BuildContext context,
    required double width,
    required double height,
    required double iconSize,
    required double textSize,
    required User user,
  }) {
    return SizedBox(
      width: width*1.2,
      height: height*1.2,
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _mostrarDialogoVerificacion(context, user),
          child: Padding(
            padding: EdgeInsets.all(width * 0.1), // Padding relativo
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: iconSize,
                  color: Colors.white,
                ),
                SizedBox(height: height * 0.08), // Espacio relativo
                Text(
                  "Administrador",
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

  Widget _buildUserCard({
    required BuildContext context,
    required double width,
    required double height,
    required double iconSize,
    required double textSize,
  }) {
    return SizedBox(
      width: width*1.2,
      height: height*1.2,
      child: Card(
        color: const Color(0xFFD4AF37),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, '/vendedor'),
          child: Padding(
            padding: EdgeInsets.all(width * 0.1), // Padding relativo
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: iconSize,
                  color: Colors.white,
                ),
                SizedBox(height: height * 0.08), // Espacio relativo
                Text(
                  "Usuario",
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

  Widget _buildLogoutButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      },
      label: Text(
        "Salir",
        style: TextStyle(
          color: Colors.black,
          fontSize: 16, // Tamaño fijo para el texto del botón
        ),
      ),
      icon: const Icon(Icons.logout, color: Colors.red),
      backgroundColor: Colors.transparent,
      elevation: 0,
      highlightElevation: 0,
    );
  }

  void _mostrarDialogoVerificacion(BuildContext context, User user) {
    final TextEditingController passwordController = TextEditingController();
    final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
    final ValueNotifier<bool> isPasswordVisible = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Contraseña de administrador",
          style: TextStyle(
            fontSize: 20, // Tamaño fijo para el título
          ),
        ),
        content: SizedBox(
          width: 300, // Ancho fijo para el diálogo
          child: ValueListenableBuilder<bool>(
            valueListenable: isPasswordVisible,
            builder: (context, isVisible, child) {
              return ValueListenableBuilder<String?>(
                valueListenable: errorNotifier,
                builder: (context, error, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isVisible,
                        decoration: InputDecoration(
                          hintText: "Ingrese su contraseña",
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFD4AF37)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isVisible ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFFD4AF37),
                            ),
                            onPressed: () {
                              isPasswordVisible.value = !isVisible;
                            },
                          ),
                          errorText: error,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar", 
              style: TextStyle(
                color: Colors.black,
                fontSize: 16, // Tamaño fijo para el texto del botón
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _verificarPassword(context, user, passwordController.text.trim(), errorNotifier);
            },
            child: const Text(
              "Verificar", 
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 16, // Tamaño fijo para el texto del botón
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _verificarPassword(BuildContext context, User user, String password, ValueNotifier<String?> errorNotifier) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      Navigator.pop(context);
      Navigator.pushNamed(context, '/admin');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        errorNotifier.value = 'Contraseña incorrecta.';
      } else {
        errorNotifier.value = 'Contraseña Incorrecta';
      }
    }
  }



  // Diálogo para eliminar cuenta (con tu estilo actual)
  Future<void> _showDeleteAccountDialog(BuildContext context) async {
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isPasswordVisible = ValueNotifier<bool>(false);
  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay usuario autenticado')),
    );
    return;
  }

  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        "Eliminar Cuenta",
        style: TextStyle(fontSize: 20),
      ),
      content: SingleChildScrollView( // ¡Añade esto!
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Importante
            children: [
              const Text(
                "Esta acción es irreversible. Todos tus datos se perderán permanentemente.",
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: isPasswordVisible,
                builder: (context, isVisible, _) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: errorNotifier,
                    builder: (context, error, _) {
                      return TextFormField(
                        controller: passwordController,
                        obscureText: !isVisible,
                        decoration: InputDecoration(
                          hintText: "Ingresa tu contraseña para confirmar",
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFD4AF37)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isVisible ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFFD4AF37),
                            ),
                            onPressed: () => isPasswordVisible.value = !isVisible,
                          ),
                          errorText: error,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () async {
            try {
              AuthCredential credential = EmailAuthProvider.credential(
                email: user.email!,
                password: passwordController.text.trim(),
              );
              await user.reauthenticateWithCredential(credential);
              Navigator.pop(context, true);
            } on FirebaseAuthException  {
              errorNotifier.value = 'Contraseña incorrecta';
            }
          },
          child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    try {
      await user.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta eliminada exitosamente')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', 
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar cuenta: ${e.message}')),
      );
    }
  }
}
}