import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_pages/pages/dem_page.dart';

class DetalleRecetaPage extends StatelessWidget {
  final Map<String, dynamic> receta;
  final String recetaId;

  const DetalleRecetaPage({Key? key, required this.receta, required this.recetaId}) : super(key: key);

  Future<String?> getDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.displayName;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            color: Colors.grey.shade900,
            onSelected: (opcion) {
              switch (opcion) {
                case 'delete':
                  _mostrarConfirmacion(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    width: 90,
                    child: Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  value: 'delete')
            ],
            offset: Offset(0, 45),
          ),
        ],
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.black,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 180,
              color: Colors.amber,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(receta['foto']),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: Color(0xAA333333),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        receta['nombre'],
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      FutureBuilder<String?>(
                        future: getDisplayName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white));
                          } else {
                            return Text(
                              'Autor: ${snapshot.data ?? 'Desconocido'}',
                              style: TextStyle(color: Colors.white),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Categoría: ${receta['categoria']}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              // height: double.infinity,
              padding: EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instrucciones:',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: 620,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        '${receta['instrucciones'] ?? 'No disponible'}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarConfirmacion(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmación',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Desea eliminar esta receta?',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('ACEPTAR'),
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null && user.email == receta['autor']) {
                  await _eliminarReceta();
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => DemPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0.0);
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
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No tienes permiso para eliminar esta receta')),
                  );
                }
              },
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
  }

  Future<void> _eliminarReceta() async {
    try {
      await FirebaseFirestore.instance.collection('recetas').doc(recetaId).delete();
      print('Receta eliminada con éxito');
    } catch (e) {
      print('Error al eliminar la receta: $e');
    }
  }
}
