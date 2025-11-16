import 'package:flutter/material.dart';

class PagosAdmin extends StatelessWidget {
  const PagosAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pagos'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              labelColor: Color(0xFF264653),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Pendientes'),
                Tab(text: 'Aprobados'),
                Tab(text: 'Rechazados'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPendingPayments(),
                  _buildApprovedPayments(),
                  _buildRejectedPayments(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPaymentDialog(context),
        backgroundColor: const Color(0xFF264653),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPendingPayments() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => _buildPaymentItem(
        'Usuario ${index + 1}',
        '\$${(index + 1) * 150}.00',
        'Pendiente',
        Colors.orange,
      ),
    );
  }

  Widget _buildApprovedPayments() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => _buildPaymentItem(
        'Usuario ${index + 1}',
        '\$${(index + 1) * 200}.00',
        'Aprobado',
        Colors.green,
      ),
    );
  }

  Widget _buildRejectedPayments() {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) => _buildPaymentItem(
        'Usuario ${index + 1}',
        '\$${(index + 1) * 100}.00',
        'Rechazado',
        Colors.red,
      ),
    );
  }

  Widget _buildPaymentItem(String user, String amount, String status, Color color) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(Icons.payment, color: Color(0xFF264653)),
        title: Text(user),
        subtitle: Text(amount),
        trailing: Chip(
          label: Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: color,
        ),
        onTap: () {},
      ),
    );
  }

  void _showNewPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Pago'),
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
            TextField(
              decoration: const InputDecoration(
                labelText: 'Monto',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
                const SnackBar(content: Text('Pago registrado')),
              );
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}