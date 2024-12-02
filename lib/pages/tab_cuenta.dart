import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_pages/pages/login_page.dart';
import 'package:test_pages/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TabCuenta extends StatefulWidget {
  const TabCuenta({super.key});

  @override
  State<TabCuenta> createState() => _TabCuentaState();
}

class _TabCuentaState extends State<TabCuenta> {
  String nombreCuenta = '';

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      nombreCuenta = user.displayName ?? user.email ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Center(
          child: Text(
            'Mi cuenta',
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(40),
        color: Colors.black,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('')),
            Container(
              margin: EdgeInsets.all(20),
              alignment: Alignment.center,
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlue.shade100,
                border: Border.all(
                  color: Colors.black26,
                  width: 4,
                ),
              ),
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.contain,
                ),
                clipBehavior: Clip.hardEdge,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text(
                nombreCuenta,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              child: FutureBuilder(
                future: AuthService().currentUser(),
                builder: (context, AsyncSnapshot<User?> snapshot) {
                  if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Cargando usuario...', style: TextStyle(color: Colors.white));
                  }
                  return Text(
                    snapshot.data!.email!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ),
            Expanded(child: Text('')),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  final cerrarSesion = await showDialog<bool>(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Cerrar sesión',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          '¿Deseas cerrar sesión $nombreCuenta?',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            child: Text('CANCELAR'),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          ElevatedButton(
                            child: Text('ACEPTAR'),
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  if (cerrarSesion == true) {
                    await FirebaseAuth.instance.signOut();
                    await GoogleSignIn().signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
