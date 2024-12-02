import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:test_pages/pages/login_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to  ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Dem',
                  style: GoogleFonts.allura(textStyle: TextStyle(color: Colors.black54), fontSize: 50),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(MdiIcons.circle, size: 10, color: Colors.transparent),
                Icon(MdiIcons.circle, size: 10, color: Colors.transparent),
                Icon(MdiIcons.circle, size: 10, color: Colors.lightBlue),
                Icon(MdiIcons.circle, size: 10, color: Colors.green),
                Icon(MdiIcons.circle, size: 10, color: Colors.orange),
                Icon(MdiIcons.circle, size: 10, color: Colors.pink),
                Icon(MdiIcons.circle, size: 10, color: Colors.purple),
                Icon(MdiIcons.circle, size: 10, color: Colors.transparent),
                Icon(MdiIcons.circle, size: 10, color: Colors.transparent),
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 30),
              color: Colors.white,
              child: Stack(
                children: [
                  Positioned(
                    child: Image(
                      image: AssetImage('assets/images/mancha.png'),
                      fit: BoxFit.cover,
                      color: Colors.black,
                    ),
                    top: -20,
                    left: 40,
                    width: 300,
                  ),
                  Positioned(
                    child: Image(
                      image: AssetImage('assets/images/logo.png'),
                      width: 300,
                      height: 300,
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Text(
                'Inspirate, cocina y disfruta',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Text(
                '¡Comienza tu experiencia culinaria!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: ElevatedButton(
                onPressed: () {
                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  );
                  Navigator.push(context, route).then((valor) {
                    setState(() {});
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                ),
                child: Icon(Icons.arrow_forward, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
