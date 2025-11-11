// lib/residente/pages/dashboard_residente.dart
import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../dashboard_model.dart';
import '../widgets/menu_residente.dart'; // Importar el menú

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
    print('🔄 DashboardResidentePage INIT - Cargando datos...');
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    print('🔍 Llamando a DashboardService.getDashboardData()...');

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await DashboardService.getDashboardData();

    if (!mounted) return;

    print('🔍 Resultado del dashboard: $result');

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _dashboardData = DashboardData.fromJson(result['data'] ?? {});
        print('✅ Datos del dashboard cargados exitosamente');
      } else {
        _errorMessage = result['message'] ?? 'Error al cargar el dashboard';
        print('❌ Error cargando dashboard: $_errorMessage');
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
        onItemSelected: () {
          // Puedes agregar lógica adicional aquí si necesitas
        },
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          // Header
          _buildHeader(data),
          const SizedBox(height: 24),

          // Métricas principales
          _buildMetricsGrid(data),
          const SizedBox(height: 24),

          // Actividad reciente
          _buildRecentActivity(data),
          // ❌ ELIMINADO: Acciones rápidas - ahora están en el menú
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
              fontSize: 24,
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
          const SizedBox(height: 4),
          Text(
            data.usuarioCorreo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
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
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
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
          subtitle: '${data.solicitudesPrioridadAlta} de prioridad alta',
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
          subtitle: 'No hay mantenimientos programados',
          detail: 'Todo en orden',
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF264653),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
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
            blurRadius: 8,
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF264653),
              ),
            ),
            const SizedBox(height: 16),
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
        Icon(Icons.info_outline, color: Colors.grey, size: 40),
        SizedBox(height: 8),
        Text(
          'No hay actividades recientes',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActivityItem(ActividadReciente actividad) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF264653).withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              actividad.flutterIcon,
              color: const Color(0xFF264653),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actividad.descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF264653),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  actividad.fecha,
                  style: const TextStyle(
                    fontSize: 12,
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

  // ❌ ELIMINADO: _buildQuickActions() y _buildActionButton()
  // Ya no se necesitan porque las acciones están en el menú
}
