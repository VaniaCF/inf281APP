import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importar las páginas desde el mismo directorio
import 'comunicados_admin.dart';
import 'finanzas_admin.dart';
import 'pagos_admin.dart';
import 'reservas_admin.dart';
import 'tickets_admin.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: _buildDashboardContent(context), // Pasar context aquí
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.announcement,
            title: 'Comunicados',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComunicadosAdmin()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.attach_money,
            title: 'Finanzas',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FinanzasAdmin()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.payment,
            title: 'Pagos',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PagosAdmin()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.calendar_today,
            title: 'Reservas',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReservasAdmin()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.support_agent,
            title: 'Tickets',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TicketsAdmin()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.analytics,
            title: 'Reportes',
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Configuración',
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.help,
            title: 'Ayuda',
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: const Color(0xFF264653),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF264653).withOpacity(0.9),
            const Color(0xFF2A9D8F),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 40,
              color: Color(0xFF264653),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Administrador',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'admin@edificio.com',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF264653),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF264653),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF264653),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDashboardContent(BuildContext context) { // Recibir context como parámetro
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de bienvenida
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF264653).withOpacity(0.9),
                    const Color(0xFF2A9D8F),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Panel de administración del edificio',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Accesos rápidos
          const Text(
            'Accesos Rápidos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF264653),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildQuickAccessCard(
                  'Comunicados',
                  Icons.announcement,
                  const Color(0xFF264653),
                  () {
                    Navigator.push(
                      context, // ✅ Context disponible aquí
                      MaterialPageRoute(builder: (context) => const ComunicadosAdmin()),
                    );
                  },
                ),
                _buildQuickAccessCard(
                  'Finanzas',
                  Icons.attach_money,
                  const Color(0xFF2A9D8F),
                  () {
                    Navigator.push(
                      context, // ✅ Context disponible aquí
                      MaterialPageRoute(builder: (context) => const FinanzasAdmin()),
                    );
                  },
                ),
                _buildQuickAccessCard(
                  'Pagos',
                  Icons.payment,
                  const Color(0xFFE9C46A),
                  () {
                    Navigator.push(
                      context, // ✅ Context disponible aquí
                      MaterialPageRoute(builder: (context) => const PagosAdmin()),
                    );
                  },
                ),
                _buildQuickAccessCard(
                  'Reservas',
                  Icons.calendar_today,
                  const Color(0xFFF4A261),
                  () {
                    Navigator.push(
                      context, // ✅ Context disponible aquí
                      MaterialPageRoute(builder: (context) => const ReservasAdmin()),
                    );
                  },
                ),
                _buildQuickAccessCard(
                  'Tickets',
                  Icons.support_agent,
                  const Color(0xFFE76F51),
                  () {
                    Navigator.push(
                      context, // ✅ Context disponible aquí
                      MaterialPageRoute(builder: (context) => const TicketsAdmin()),
                    );
                  },
                ),
                _buildQuickAccessCard(
                  'Reportes',
                  Icons.analytics,
                  const Color(0xFF6A4C93),
                  () {
                    _showComingSoon(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('12', 'Comunicados'),
        _buildStatItem('8', 'Pagos Pend.'),
        _buildStatItem('5', 'Reservas Hoy'),
        _buildStatItem('3', 'Tickets Act.'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente...'),
        backgroundColor: Color(0xFF264653),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_data');
    
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}