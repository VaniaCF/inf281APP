import 'package:flutter/material.dart';

class FinanzasAdmin extends StatelessWidget {
  const FinanzasAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Financiera'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard(
              title: 'Balance General',
              amount: '\$45,230.00',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Ingresos del Mes',
              amount: '\$12,450.00',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Gastos del Mes',
              amount: '\$8,230.00',
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildActionItem('Reportes Financieros', Icons.analytics),
                  _buildActionItem('Estado de Cuentas', Icons.account_balance),
                  _buildActionItem('Presupuesto', Icons.pie_chart),
                  _buildActionItem('Impuestos', Icons.receipt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.attach_money, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF264653)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}