import 'package:flutter/material.dart';

class ComunicadosAdmin extends StatelessWidget {
  const ComunicadosAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Comunicados'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildActionCard(
              icon: Icons.add,
              title: 'Nuevo Comunicado',
              subtitle: 'Crear un nuevo anuncio',
              onTap: () => _showNewComunicadoDialog(context),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.list,
              title: 'Ver Comunicados',
              subtitle: 'Gestionar comunicados existentes',
              onTap: () => _showComunicadosList(context),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.schedule,
              title: 'Programados',
              subtitle: 'Comunicados programados',
              onTap: () => _showScheduledComunicados(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF264653)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showNewComunicadoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Comunicado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comunicado creado')),
              );
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  void _showComunicadosList(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lista de comunicados')),
    );
  }

  void _showScheduledComunicados(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comunicados programados')),
    );
  }
}