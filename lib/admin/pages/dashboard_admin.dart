import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import 'comunicados_admin.dart';
import 'usuarios_admin.dart';
import 'tickets_admin.dart';
import 'reservas_admin.dart';
import 'finanzas_admin.dart';
import 'pagos_admin.dart';
import 'consumos_admin.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final DashboardService _dashboardService = DashboardService();
  DashboardData? _dashboardData;
  bool _cargando = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _cargarDashboardData();
  }

  Future<void> _cargarDashboardData() async {
    try {
      setState(() {
        _cargando = true;
        _error = '';
      });

      final data = await _dashboardService.obtenerDatosDashboard();
      setState(() {
        _dashboardData = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar dashboard: $e';
        _cargando = false;
      });
      print('Error cargando dashboard: $e');
    }
  }

  Widget _buildMetricCard(String title, dynamic value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(String title, IconData icon, Color color, Widget page) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Administrador'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDashboardData,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDashboardData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarDashboardData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Estadísticas principales
                        const Text(
                          'Estadísticas Principales',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildMetricCard(
                              'Total Usuarios',
                              _dashboardData?.totalUsuarios ?? 0,
                              Colors.blue,
                              Icons.people,
                            ),
                            _buildMetricCard(
                              'Tickets Pendientes',
                              _dashboardData?.ticketsPendientes ?? 0,
                              Colors.orange,
                              Icons.support_agent,
                            ),
                            _buildMetricCard(
                              'Tickets Urgentes',
                              _dashboardData?.ticketsUrgentes ?? 0,
                              Colors.red,
                              Icons.warning,
                            ),
                            _buildMetricCard(
                              'Total Tickets',
                              _dashboardData?.totalTickets ?? 0,
                              Colors.purple,
                              Icons.list_alt,
                            ),
                            _buildMetricCard(
                              'Reservas Hoy',
                              _dashboardData?.reservasHoy ?? 0,
                              Colors.green,
                              Icons.calendar_today,
                            ),
                            _buildMetricCard(
                              'Reservas Activas',
                              _dashboardData?.reservasActivas ?? 0,
                              Colors.teal,
                              Icons.event_available,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Navegación rápida
                        const Text(
                          'Módulos del Sistema',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _buildNavigationCard(
                              'Usuarios',
                              Icons.people,
                              Colors.blue,
                              UsuariosAdmin(),
                            ),
                            _buildNavigationCard(
                              'Comunicados',
                              Icons.announcement,
                              Colors.orange,
                              ComunicadosAdmin(),
                            ),
                            _buildNavigationCard(
                              'Tickets',
                              Icons.support_agent,
                              Colors.red,
                              TicketsAdmin(),
                            ),
                            _buildNavigationCard(
                              'Reservas',
                              Icons.calendar_today,
                              Colors.green,
                              ReservasAdmin(),
                            ),
                            _buildNavigationCard(
                              'Finanzas',
                              Icons.attach_money,
                              Colors.teal,
                              FinanzasAdmin(),
                            ),
                            _buildNavigationCard(
                              'Pagos',
                              Icons.payment,
                              Colors.purple,
                              PagosAdmin(),
                            ),
                            _buildNavigationCard(
                              'Consumos',
                              Icons.water_drop,
                              Colors.cyan,
                              ConsumosAdmin(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}