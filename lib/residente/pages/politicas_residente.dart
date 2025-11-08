import 'package:flutter/material.dart';

class PoliticasResidente extends StatelessWidget {
  const PoliticasResidente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas Residente'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'PÁGINA DE POLÍTICAS RESIDENTE',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
