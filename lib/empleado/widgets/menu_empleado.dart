import 'package:flutter/material.dart';

class MenuEmpleado {
  // TU PALETA DE COLORES
  static final Color _azulProfundo = Color(0xFF264653);
  static final Color _beigeSuave = Color(0xFFEDE6E0);
  static final Color _grisClaro = Color(0xFFF5F5F5);
  static final Color _marronOscuro = Color(0xFF2F241F);
  static final Color _duraznoSuave = Color(0xFFE3A78C);
  static final Color _celesteClaro = Color(0xFFA3C8D6);
  static final Color _verdeOliva = Color(0xFF7A8C6E);

  static List<Map<String, dynamic>> getMenuItems() {
    return [
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard,
        'route': '/empleado/dashboard',
      },
      {
        'title': 'Mis Mantenimientos',
        'icon': Icons.handyman,
        'route': '/empleado/mantenimientos',
      },
      {
        'title': 'Mis Pagos',
        'icon': Icons.payment,
        'route': '/empleado/pagos',
      },
      {
        'title': 'Mi Perfil',
        'icon': Icons.person,
        'route': '/empleado/perfil',
      },
    ];
  }

  static Widget buildDrawer(
      BuildContext context, Function(String) onItemSelected) {
    return Drawer(
      backgroundColor: _grisClaro,
      child: Column(
        children: [
          // Header del Drawer - MEJORADO CON PALETA
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_azulProfundo, _azulProfundo.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar mejorado
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _beigeSuave,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.engineering,
                      size: 35,
                      color: _azulProfundo,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Textos mejorados
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Panel Empleado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sistema Edificio Inteligente',
                        style: TextStyle(
                          color: _beigeSuave,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de opciones del menú - MEJORADA
          Expanded(
            child: Container(
              color: _grisClaro,
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 16),
                children: getMenuItems().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildMenuItem(
                    context,
                    icon: item['icon'],
                    title: item['title'],
                    index: index,
                    onTap: () {
                      Navigator.pop(context); // Cerrar el drawer
                      onItemSelected(item['route']);
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          // Botón de Cerrar Sesión - MEJORADO
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _grisClaro,
              border: Border(
                top: BorderSide(
                  color: _marronOscuro.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 18),
              label: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _duraznoSuave,
                foregroundColor: _marronOscuro,
                elevation: 2,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required VoidCallback onTap,
  }) {
    final colors = [_azulProfundo, _verdeOliva, _duraznoSuave, _celesteClaro];
    final color = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.1),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ícono mejorado
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                // Texto mejorado
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _marronOscuro,
                    ),
                  ),
                ),
                // Flecha mejorada
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _marronOscuro.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de advertencia
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _duraznoSuave.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 30,
                    color: _duraznoSuave,
                  ),
                ),
                SizedBox(height: 16),
                // Título
                Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _marronOscuro,
                  ),
                ),
                SizedBox(height: 8),
                // Mensaje
                Text(
                  '¿Estás seguro de que quieres cerrar sesión?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _marronOscuro.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 24),
                // Botones
                Row(
                  children: [
                    // Botón Cancelar
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _marronOscuro,
                          side:
                              BorderSide(color: _marronOscuro.withOpacity(0.3)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Botón Cerrar Sesión
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _performLogout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _duraznoSuave,
                          foregroundColor: _marronOscuro,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _performLogout(BuildContext context) {
    // Aquí va la lógica de logout:
    // 1. Limpiar token de autenticación
    // 2. Limpiar datos de usuario
    // 3. Navegar a la pantalla de login

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sesión cerrada exitosamente',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: _verdeOliva,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Método para Bottom Navigation Bar - MEJORADO
  static Widget buildBottomNavigationBar(
      BuildContext context, int currentIndex, Function(int) onTap) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: _azulProfundo,
          unselectedItemColor: _marronOscuro.withOpacity(0.5),
          selectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: currentIndex == 0
                      ? _azulProfundo.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.dashboard, size: 22),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: currentIndex == 1
                      ? _verdeOliva.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.handyman, size: 22),
              ),
              label: 'Mantenimientos',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: currentIndex == 2
                      ? _duraznoSuave.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.payment, size: 22),
              ),
              label: 'Mis Pagos',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: currentIndex == 3
                      ? _celesteClaro.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.person, size: 22),
              ),
              label: 'Mi Perfil',
            ),
          ],
        ),
      ),
    );
  }

  // Método para obtener el índice de la ruta actual
  static int getCurrentIndex(String currentRoute) {
    switch (currentRoute) {
      case '/empleado/dashboard':
        return 0;
      case '/empleado/mantenimientos':
        return 1;
      case '/empleado/pagos':
        return 2;
      case '/empleado/perfil':
        return 3;
      default:
        return 0;
    }
  }
}
