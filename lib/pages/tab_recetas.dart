import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:test_pages/pages/detalle_receta_page.dart';

class TabRecetas extends StatefulWidget {
  const TabRecetas({super.key});

  @override
  State<TabRecetas> createState() => _TabRecetasState();
}

class _TabRecetasState extends State<TabRecetas> {
  final Map<String, String> categoriaColor = {
    'categoria1': '00BFFF', // Light Blue
    'categoria2': '32CD32', // Lime Green
    'categoria3': 'FFA500', // Orange
    'categoria4': 'FF69B4', // Hot Pink
    'categoria5': '800080', // Purple
  };

  Color _getColorFromHex(String hexColor) {
    if (hexColor.isEmpty) return Colors.white;
    hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  Future<String?> obtenerCategoriaPorNombre(String nombreCategoria) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categorias').where('nombre', isEqualTo: nombreCategoria).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }

  // Future<List<Map<String, dynamic>>> fetchData() async {
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('recetas').get();
  //   return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  // }

  Future<List<Map<String, dynamic>>> fetchData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('recetas').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        title: Text(
          'Descubre nuevas recetas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay recetas', style: TextStyle(color: Colors.white)));
            }
            var data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                String categoria = data[index]['categoria'];
                return FutureBuilder<String?>(
                  future: obtenerCategoriaPorNombre(categoria),
                  builder: (context, categorySnapshot) {
                    if (categorySnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text(
                          data[index]['nombre'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(categoria, style: TextStyle(color: Colors.white)),
                      );
                    } else if (categorySnapshot.hasError) {
                      return ListTile(
                        leading: Icon(Icons.error, color: Colors.red),
                        title: Text(
                          data[index]['nombre'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(categoria, style: TextStyle(color: Colors.white)),
                      );
                    }
                    String? categoriaId = categorySnapshot.data;
                    String? hexColor = categoriaColor[categoriaId];
                    Color iconColor = _getColorFromHex(hexColor ?? '');
                    return ListTile(
                      leading: Icon(
                        MdiIcons.bookmark,
                        size: 40,
                        color: iconColor,
                      ),
                      title: Text(
                        data[index]['nombre'],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(categoria, style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => DetalleRecetaPage(
                              receta: data[index],
                              recetaId: data[index]['id'],
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
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
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
