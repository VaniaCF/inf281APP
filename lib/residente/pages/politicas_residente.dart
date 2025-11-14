// lib/residente/pages/politica_residente.dart
import 'package:flutter/material.dart';

class PoliticaResidentePage extends StatelessWidget {
  const PoliticaResidentePage({super.key});

  @override
  Widget build(BuildContext context) {
    final politicasData = _getPoliticasData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas del Edificio'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            _buildHeader(politicasData['titulo']!),
            const SizedBox(height: 24),

            // Lista de políticas
            ...politicasData['politicas']!.map(_buildPoliticaCard).toList(),

            // Nota importante
            _buildNotaImportante(politicasData['nota_importante']!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String titulo) {
    return Column(
      children: [
        Icon(
          Icons.assignment,
          size: 64,
          color: const Color(0xFF264653),
        ),
        const SizedBox(height: 16),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF264653),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Conozca las normas y políticas establecidas para la convivencia armónica en nuestro edificio',
          style: TextStyle(
            color: Color(0xFF2F241F),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPoliticaCard(Map<String, dynamic> politica) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFA3C8D6),
                    Color(0xFF7A8C6E),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getFlutterIcon(politica['icono']),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    politica['titulo'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF264653),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    politica['descripcion'],
                    style: const TextStyle(
                      color: Color(0xFF2F241F),
                      fontSize: 14,
                      height: 1.5,
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

  Widget _buildNotaImportante(String nota) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7A8C6E),
            Color(0xFF687a5d),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Nota Importante',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              nota,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFlutterIcon(String icono) {
    switch (icono) {
      case 'fa-calendar-check':
        return Icons.calendar_today;
      case 'fa-swimming-pool':
        return Icons.pool;
      case 'fa-dumbbell':
        return Icons.fitness_center;
      case 'fa-key':
        return Icons.vpn_key;
      case 'fa-clock':
        return Icons.access_time;
      case 'fa-ban':
        return Icons.block;
      case 'fa-exclamation-triangle':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Map<String, dynamic> _getPoliticasData() {
    return {
      'titulo': 'Políticas y Reglas del Edificio SincroHome',
      'politicas': [
        {
          'titulo': 'Reserva de Áreas Comunes',
          'descripcion':
              'Toda reserva de áreas comunes requiere un adelanto del 50% del costo total.',
          'icono': 'fa-calendar-check',
        },
        {
          'titulo': 'Cancelación de Reservas - Salón de Eventos y Piscina',
          'descripcion':
              'La cancelación debe realizarse con una semana de anticipación para el salón de eventos y piscina.',
          'icono': 'fa-swimming-pool',
        },
        {
          'titulo': 'Cancelación de Reservas - Gimnasio SincroHome',
          'descripcion':
              'Para el gimnasio, la cancelación debe hacerse con 24 horas de anticipación.',
          'icono': 'fa-dumbbell',
        },
        {
          'titulo': 'Acceso Exclusivo',
          'descripcion':
              'Las reservas del parque y áreas comunes son exclusivas para residentes del edificio.',
          'icono': 'fa-key',
        },
        {
          'titulo': 'Horario de Confirmación',
          'descripcion':
              'Las reservas serán confirmadas durante el horario administrativo de 7:30 AM a 6:00 PM.',
          'icono': 'fa-clock',
        },
        {
          'titulo': 'Política de No Devolución',
          'descripcion':
              'No se aceptan devoluciones por incumplimiento de las políticas establecidas.',
          'icono': 'fa-ban',
        },
        {
          'titulo': 'Responsabilidad por Daños',
          'descripcion':
              'El residente será responsable por cualquier daño ocasionado en las áreas comunes durante su uso.',
          'icono': 'fa-exclamation-triangle',
        },
      ],
      'nota_importante':
          'Agradecemos su comprensión y colaboración para mantener un ambiente agradable y seguro para todos los residentes del Edificio SincroHome.',
    };
  }
}
