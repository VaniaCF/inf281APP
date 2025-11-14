// lib/residente/pages/dashboard_residente.dart
import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../dashboard_model.dart';
import '../widgets/menu_residente.dart';
import '../services/reservas_service.dart';

class DashboardResidentePage extends StatefulWidget {
  const DashboardResidentePage({super.key});

  @override
  State<DashboardResidentePage> createState() => _DashboardResidentePageState();
}

class _DashboardResidentePageState extends State<DashboardResidentePage> {
  DashboardData? _dashboardData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _iniciarDiagnosticoAutomatico();
  }

  Future<void> _iniciarDiagnosticoAutomatico() async {
    try {
      print('🚀 INICIANDO DIAGNÓSTICO AUTOMÁTICO JWT...');

      // Esperar un poco para que la UI se cargue primero
      await Future.delayed(Duration(seconds: 3));

      // Ejecutar diagnóstico completo
      await ReservaService.probarConfiguracionJWT();
      await ReservaService.probarTokenManual();
      await ReservaService.pruebaDiagnosticoCompleto();
      await ReservaService.probarDebugTokenDetallado();
      await ReservaService.probarDebugTokenFormato();

      print('✅ DIAGNÓSTICO JWT COMPLETADO');
    } catch (e) {
      print('❌ Error en diagnóstico automático: $e');
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await DashboardService.getDashboardData();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _dashboardData = DashboardData.fromJson(result['data'] ?? {});
      } else {
        _errorMessage = result['message'] ?? 'Error al cargar el dashboard';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Dashboard Residente'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: MenuResidente(
        onItemSelected: () {},
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage.isNotEmpty
              ? _buildError()
              : _buildDashboard(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF264653)),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando dashboard...',
            style: TextStyle(
              color: Color(0xFF264653),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _errorMessage,
              style: const TextStyle(
                color: Color(0xFF264653),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF264653),
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final data = _dashboardData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(data),
          const SizedBox(height: 20),

          // Métricas principales - CORREGIDO PARA EVITAR OVERFLOW
          _buildMetricsGrid(data),
          const SizedBox(height: 20),

          // Actividad reciente
          _buildRecentActivity(data),
        ],
      ),
    );
  }

  Widget _buildHeader(DashboardData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF264653),
            Color(0xFF2A9D8F),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido de vuelta,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.usuarioNombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22, // Reducido para evitar overflow
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Piso ${data.residenteData.piso} - Dpto ${data.residenteData.departamento}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(DashboardData data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10, // Reducido
      mainAxisSpacing: 10, // Reducido
      childAspectRatio: 1.0, // Cambiado de 1.1 a 1.0 para más espacio
      children: [
        _buildMetricCard(
          icon: Icons.attach_money,
          title: 'Estado de Pagos',
          value: data.estadoPagos.estado,
          subtitle: '\$${data.estadoPagos.montoPendiente.toStringAsFixed(2)}',
          detail: 'Vence: ${data.estadoPagos.fechaVencimiento}',
          color: const Color(0xFF7A8C6E),
        ),
        _buildMetricCard(
          icon: Icons.confirmation_number,
          title: 'Solicitudes Activas',
          value: data.solicitudesActivas.toString(),
          subtitle: '${data.solicitudesPrioridadAlta} urgentes',
          detail: 'Tickets pendientes',
          color: const Color(0xFFE76F51),
        ),
        _buildMetricCard(
          icon: Icons.home,
          title: 'Mi Departamento',
          value: 'Piso ${data.residenteData.piso}',
          subtitle: 'Dpto: ${data.residenteData.departamento}',
          detail: 'Ingreso: ${data.residenteData.fechaIngreso}',
          color: const Color(0xFF2A9D8F),
        ),
        _buildMetricCard(
          icon: Icons.build,
          title: 'Mantenimiento',
          value: 'Sin anuncios',
          subtitle: 'Todo en orden',
          detail: 'Sin programaciones',
          color: const Color(0xFF264653),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required String detail,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reducido padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8), // Reducido
            Text(
              title,
              style: const TextStyle(
                fontSize: 11, // Reducido
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2), // Reducido
            Text(
              value,
              style: const TextStyle(
                fontSize: 16, // Reducido
                fontWeight: FontWeight.bold,
                color: Color(0xFF264653),
              ),
            ),
            const SizedBox(height: 2), // Reducido
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10, // Reducido
                color: Colors.grey,
              ),
              maxLines: 1, // Evitar múltiples líneas
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 9, // Reducido
                color: Colors.grey,
              ),
              maxLines: 1, // Evitar múltiples líneas
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(DashboardData data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividad Reciente',
              style: TextStyle(
                fontSize: 16, // Reducido
                fontWeight: FontWeight.bold,
                color: Color(0xFF264653),
              ),
            ),
            const SizedBox(height: 12),
            if (data.actividadesRecientes.isEmpty)
              _buildEmptyActivity()
            else
              ...data.actividadesRecientes.map(_buildActivityItem).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return const Column(
      children: [
        Icon(Icons.info_outline, color: Colors.grey, size: 32), // Reducido
        SizedBox(height: 8),
        Text(
          'No hay actividades recientes',
          style: TextStyle(color: Colors.grey, fontSize: 12), // Reducido
        ),
      ],
    );
  }

  Widget _buildActivityItem(ActividadReciente actividad) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Reducido
      child: Row(
        children: [
          Container(
            width: 32, // Reducido
            height: 32, // Reducido
            decoration: BoxDecoration(
              color: const Color(0xFF264653).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              actividad.flutterIcon,
              color: const Color(0xFF264653),
              size: 16, // Reducido
            ),
          ),
          const SizedBox(width: 10), // Reducido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actividad.descripcion,
                  style: const TextStyle(
                    fontSize: 12, // Reducido
                    color: Color(0xFF264653),
                  ),
                  maxLines: 2, // Permitir 2 líneas máximo
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  actividad.fecha,
                  style: const TextStyle(
                    fontSize: 10, // Reducido
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
