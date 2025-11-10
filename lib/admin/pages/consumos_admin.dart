import 'package:flutter/material.dart';

class ConsumosAdmin extends StatelessWidget {
  const ConsumosAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Consumos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Módulo de Consumos',
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