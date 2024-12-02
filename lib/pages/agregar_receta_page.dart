import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_pages/pages/dem_page.dart';
import 'package:test_pages/services/fs_service.dart';
import 'package:test_pages/utils/mensaje_util.dart';

class AgregarRecetaPage extends StatefulWidget {
  const AgregarRecetaPage({super.key});

  @override
  State<AgregarRecetaPage> createState() => _AgregarRecetaPageState();
}

class _AgregarRecetaPageState extends State<AgregarRecetaPage> {
  final formKey = GlobalKey<FormState>();

  TextEditingController nombreCtrl = TextEditingController();
  TextEditingController instruccionCtrl = TextEditingController();
  TextEditingController autorCtrl = TextEditingController();
  TextEditingController fotoCtrl = TextEditingController();

  String? categoriaSeleccionada;

  final Map<String, String> categoriasConImagen = {
    'categoria1': 'assets/images/categories/bebida.jpg',
    'categoria2': 'assets/images/categories/entrada.jpg',
    'categoria3': 'assets/images/categories/guarnicion.jpg',
    'categoria4': 'assets/images/categories/postre.jpg',
    'categoria5': 'assets/images/categories/principal.jpg',
  };

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      autorCtrl.text = user.displayName ?? user.email ?? '';
    }
  }

  Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categorias').get();
    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'nombre': doc['nombre'],
              'foto': doc['foto'],
            })
        .toList();
  }

  Future<String?> obtenerNombreCategoria(String categoriaId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('categorias').doc(categoriaId).get();
      if (doc.exists) {
        return doc['nombre'];
      } else {
        print('No se encontró la categoría con ID: $categoriaId');
        return null;
      }
    } catch (e) {
      print('Error al obtener el nombre de la categoría: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Agregar Receta'),
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splatter.JPG'),
            fit: BoxFit.fitHeight,
            invertColors: true,
          ),
        ),
        child: Container(
          width: double.infinity,
          // padding: EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            color: Color.fromARGB(158, 240, 240, 240),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese un nombre de receta';
                      }
                      return null;
                    },
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: obtenerCategorias(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('...');
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No se encontraron categorías.');
                      }
                      var categorias = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                        ),
                        value: categoriaSeleccionada,
                        onChanged: (value) {
                          setState(() {
                            categoriaSeleccionada = value;
                            if (value != null) {
                              fotoCtrl.text = categoriasConImagen[value] ?? '';
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Seleccione una categoría';
                          }
                          return null;
                        },
                        items: categorias.map<DropdownMenuItem<String>>((categoria) {
                          return DropdownMenuItem<String>(
                            value: categoria['id'],
                            child: Text(categoria['nombre']),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  TextFormField(
                    controller: fotoCtrl,
                    decoration: InputDecoration(
                      labelText: 'Foto',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    enabled: false,
                    style: TextStyle(color: Colors.black),
                  ),
                  TextFormField(
                    controller: autorCtrl,
                    decoration: InputDecoration(
                      labelText: 'Autor',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    enabled: false,
                    style: TextStyle(color: Colors.black),
                  ),
                  TextFormField(
                    controller: instruccionCtrl,
                    decoration: InputDecoration(
                      labelText: 'Instrucciones',
                    ),
                    textAlignVertical: TextAlignVertical.top,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese las instrucciones';
                      }
                      return null;
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text('Agregar'),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          User? user = FirebaseAuth.instance.currentUser;
                          String emailAutor = user?.email ?? '';
                          String? nombreCategoria = await obtenerNombreCategoria(categoriaSeleccionada.toString());
                          FsService().agregarReceta(
                            emailAutor,
                            nombreCategoria.toString(),
                            fotoCtrl.text,
                            instruccionCtrl.text,
                            nombreCtrl.text,
                          );
                          print('Receta agregada exitosamente!');
                          MensajeUtil.mostrarSnackbar(context, 'Receta agregada con éxito :D');
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
                          print('Por favor, complete todos los campos.');
                          MensajeUtil.mostrarSnackbar(context, 'Ingrese los datos faltantes.');
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
