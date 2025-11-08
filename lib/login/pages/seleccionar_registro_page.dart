import 'package:flutter/material.dart';

class SeleccionarRegistroPage extends StatelessWidget {
  const SeleccionarRegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Tipo de Registro'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF264653),
              Color(0xFFA3C8D6),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Cómo deseas registrarte?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Tarjeta Administrador
                _RoleCard(
                  icon: Icons.admin_panel_settings,
                  title: 'Administrador',
                  color: const Color(0xFFE74C3C),
                  description: 'Acceso completo al sistema',
                  onTap: () {
                    Navigator.pushNamed(context, '/verificacion_codigo',
                        arguments: 'Administrador');
                  },
                ),
                const SizedBox(height: 20),

                // Tarjeta Empleado
                _RoleCard(
                  icon: Icons.business_center,
                  title: 'Empleado',
                  color: const Color(0xFF3498DB),
                  description: 'Gestión de actividades',
                  onTap: () {
                    Navigator.pushNamed(context, '/verificacion_codigo',
                        arguments: 'empleado');
                  },
                ),
                const SizedBox(height: 20),

                // Tarjeta Residente
                _RoleCard(
                  icon: Icons.home,
                  title: 'Residente',
                  color: const Color(0xFF2ECC71),
                  description: 'Acceso a servicios del edificio',
                  onTap: () {
                    Navigator.pushNamed(context, '/register/residente');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
