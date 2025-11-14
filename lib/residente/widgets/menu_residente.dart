// lib/residente/widgets/menu_residente.dart
import 'package:flutter/material.dart';

class MenuResidente extends StatelessWidget {
  final VoidCallback onItemSelected;

  const MenuResidente({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF264653),
      child: Column(
        children: [
          // Header del drawer
          _buildHeader(context),

          // Lista de opciones con Expanded para scroll
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    _navigateTo(context, '/residente/dashboard');
                  },
                ),

                _buildMenuItem(
                  icon: Icons.confirmation_number,
                  title: 'Mis Tickets',
                  onTap: () {
                    _navigateTo(context, '/residente/tickets');
                  },
                ),

                _buildMenuItem(
                  icon: Icons.calendar_today,
                  title: 'Mis Reservas',
                  onTap: () {
                    _navigateTo(context, '/residente/reservas');
                  },
                ),

                _buildMenuItem(
                  icon: Icons.policy,
                  title: 'Políticas',
                  onTap: () {
                    _navigateTo(context, '/residente/politicas');
                  },
                ),

                _buildMenuItem(
                  icon: Icons.person,
                  title: 'Mi Perfil',
                  onTap: () {
                    _navigateTo(context, '/residente/perfil');
                  },
                ),

                // Divider antes de Cerrar Sesión
                const Divider(color: Colors.white54, height: 1),

                // Cerrar Sesión
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NUEVO MÉTODO: Navegación unificada
  void _navigateTo(BuildContext context, String routeName) {
    print('🎯 Navegando a: $routeName');

    // 1. Cerrar el drawer primero
    Navigator.pop(context);

    // 2. Pequeño delay para asegurar que el drawer se cierre
    Future.delayed(Duration(milliseconds: 100), () {
      // 3. Navegar a la ruta
      Navigator.pushNamed(context, routeName).then((_) {
        print('✅ Navegación completada a: $routeName');
      }).catchError((error) {
        print('❌ Error en navegación: $error');
      });
    });

    // 4. Ejecutar callback
    onItemSelected();
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color(0xFF2A9D8F),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Color(0xFF264653),
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Residente',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SincroHome',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      // 🔥 AGREGAR FEEDBACK TÁCTIL
      mouseCursor: SystemMouseCursors.click,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // Cerrar drawer primero
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: true, // 🔥 PERMITIR TOCAR FUERA
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar dialog
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
