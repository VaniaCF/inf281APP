import 'package:flutter/material.dart';

class ReservasResidente extends StatelessWidget {
  const ReservasResidente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas Residente'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'PÁGINA DE RESERVAS RESIDENTE',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
