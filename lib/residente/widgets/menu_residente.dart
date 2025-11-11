// lib/residente/widgets/menu_residente.dart
import 'package:flutter/material.dart';

class MenuResidente extends StatelessWidget {
  final VoidCallback onItemSelected;

  const MenuResidente({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF264653),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del drawer
          _buildHeader(context),

          // Items del menú
          _buildMenuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              Navigator.pushNamedAndRemoveUntil(
                  context, '/residente/dashboard', (route) => false);
              onItemSelected();
            },
          ),

          _buildMenuItem(
            icon: Icons.confirmation_number,
            title: 'Mis Tickets',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/residente/tickets');
              onItemSelected();
            },
          ),

          _buildMenuItem(
            icon: Icons.calendar_today,
            title: 'Mis Reservas',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/residente/reservas');
              onItemSelected();
            },
          ),

          _buildMenuItem(
            icon: Icons.receipt_long,
            title: 'Facturación',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/residente/facturacion');
              onItemSelected();
            },
          ),

          _buildMenuItem(
            icon: Icons.policy,
            title: 'Políticas',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/residente/politicas');
              onItemSelected();
            },
          ),

          _buildMenuItem(
            icon: Icons.person,
            title: 'Mi Perfil',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/residente/perfil');
              onItemSelected();
            },
          ),

          // Divider antes de Cerrar Sesión
          const Divider(color: Colors.white54, height: 1),

          // Cerrar Sesión
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
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
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
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
