import 'package:flutter/material.dart';

class TicketsResidente extends StatelessWidget {
  const TicketsResidente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets Residente'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'PÁGINA DE TICKETS RESIDENTE',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
