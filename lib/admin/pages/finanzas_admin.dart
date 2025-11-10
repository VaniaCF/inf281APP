import 'package:flutter/material.dart';

class FinanzasAdmin extends StatelessWidget {
  const FinanzasAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Finanzas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Módulo de Finanzas',
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