import 'package:flutter/material.dart';

class ReservasAdmin extends StatelessWidget {
  const ReservasAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Reservas'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDateSelector(),
            const SizedBox(height: 20),
            const Text(
              'Reservas del Día',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) => _buildReservationItem(index),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewReservationDialog(context),
        backgroundColor: const Color(0xFF264653),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF264653)),
            const SizedBox(width: 16),
            const Text(
              'Hoy,',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationItem(int index) {
    final areas = ['Salón Social', 'Piscina', 'Gimnasio', 'Cancha Deportiva'];
    final hours = ['09:00 - 11:00', '14:00 - 16:00', '18:00 - 20:00', '10:00 - 12:00'];
    final statuses = ['Confirmada', 'Pendiente', 'Cancelada', 'Confirmada'];
    final statusColors = [Colors.green, Colors.orange, Colors.red, Colors.green];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event, color: Color(0xFF264653)),
        title: Text('${areas[index]} - ${hours[index]}'),
        subtitle: Text('Usuario ${index + 1}'),
        trailing: Chip(
          label: Text(
            statuses[index],
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: statusColors[index],
        ),
        onTap: () {},
      ),
    );
  }

  void _showNewReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: 'Área',
                border: OutlineInputBorder(),
              ),
              items: ['Salón Social', 'Piscina', 'Gimnasio', 'Cancha Deportiva']
                  .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                  .toList(),
              onChanged: (value) {},
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
                const SnackBar(content: Text('Reserva creada')),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}