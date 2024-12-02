import 'package:cloud_firestore/cloud_firestore.dart';

class FsService {
  //obtener los productos
  Stream<QuerySnapshot> recetas() {
    return FirebaseFirestore.instance.collection('recetas').snapshots();
  }

  //agregar un producto
  Future<void> agregarReceta(String autor, String categoria, String foto, String instrucciones, String nombre) {
    return FirebaseFirestore.instance.collection('recetas').doc().set({
      'nombre': nombre,
      'categoria': categoria,
      'autor': autor,
      'foto': foto,
      'instrucciones': instrucciones,
    });
  }

  //borrar un producto
  Future<void> borrarProducto(String id) {
    return FirebaseFirestore.instance.collection('recetas').doc(id).delete();
  }
}
