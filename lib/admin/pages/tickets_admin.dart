import 'package:flutter/material.dart';

class TicketsAdmin extends StatelessWidget {
  const TicketsAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Tickets'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.support_agent, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Módulo de Tickets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'En desarrollo',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}