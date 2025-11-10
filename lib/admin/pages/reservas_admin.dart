import 'package:flutter/material.dart';

class ReservasAdmin extends StatelessWidget {
  const ReservasAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Reservas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Módulo de Reservas',
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