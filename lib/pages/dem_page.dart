import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:test_pages/pages/agregar_receta_page.dart';
import 'package:test_pages/pages/tab_cuenta.dart';
import 'package:test_pages/pages/tab_misrecetas.dart';
import 'package:test_pages/pages/tab_recetas.dart';

class DemPage extends StatefulWidget {
  const DemPage({super.key});

  @override
  State<DemPage> createState() => _DemPageState();
}

class _DemPageState extends State<DemPage> {
  int paginaSeleccionada = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> paginas = [TabMisrecetas(), TabRecetas(), TabCuenta()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey,
        indicatorColor: Colors.white,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(MdiIcons.chefHat),
            icon: Icon(MdiIcons.chefHat),
            label: 'Mis recetas',
          ),
          NavigationDestination(
            selectedIcon: Icon(MdiIcons.book),
            icon: Icon(MdiIcons.book),
            label: 'Descubrir',
          ),
          NavigationDestination(
            icon: Icon(MdiIcons.account),
            label: 'Mi cuenta',
          ),
        ],
        selectedIndex: paginaSeleccionada,
        onDestinationSelected: (pagina) {
          if (paginaSeleccionada == 0 && pagina == 2) {
            _pageController.jumpToPage(2);
          } else if (paginaSeleccionada == 2 && pagina == 0) {
            _pageController.jumpToPage(0);
          } else {
            _pageController.animateToPage(
              pagina,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          setState(() {
            paginaSeleccionada = pagina;
          });
        },
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            paginaSeleccionada = index;
          });
        },
        children: paginas,
      ),
      floatingActionButton: paginaSeleccionada == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => AgregarRecetaPage(),
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
              child: Icon(MdiIcons.plus, color: Colors.black),
              backgroundColor: Colors.white,
              shape: CircleBorder(),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
