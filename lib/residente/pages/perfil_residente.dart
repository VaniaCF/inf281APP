import 'package:flutter/material.dart';

class PerfilResidente extends StatelessWidget {
  const PerfilResidente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Residente'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'PÁGINA DE PERFIL RESIDENTE',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
