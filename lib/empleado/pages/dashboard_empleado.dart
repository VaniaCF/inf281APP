// lib/empleado/pages/dashboard_empleado.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/dashboard_service.dart';
import '../widgets/menu_empleado.dart';

class DashboardEmpleado extends StatefulWidget {
  const DashboardEmpleado({Key? key}) : super(key: key);

  @override
  _DashboardEmpleadoState createState() => _DashboardEmpleadoState();
}

class _DashboardEmpleadoState extends State<DashboardEmpleado> {
  late DashboardService _dashboardService;
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;
  String _errorMessage = '';

  // TU PALETA DE COLORES
  final Color _azulProfundo = Color(0xFF264653);
  final Color _beigeSuave = Color(0xFFEDE6E0);
  final Color _grisClaro = Color(0xFFF5F5F5);
  final Color _marronOscuro = Color(0xFF2F241F);
  final Color _duraznoSuave = Color(0xFFE3A78C);
  final Color _celesteClaro = Color(0xFFA3C8D6);
  final Color _verdeOliva = Color(0xFF7A8C6E);

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadDashboardData();
  }

  void _initializeService() {
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0LCJjb3JyZW8iOiJ2YW5pYWNhcnJhc2NvNjgwNTY1MzBAZ21haWwuY29tIiwiaWRfcm9sIjoyLCJleHAiOjE3NjMzMDI2MDN9.jNv2lhTCz2IDRQD9rWcfbwSwOp7cY_cNEsRAlD6D8Ac';
    final baseUrl = 'http://192.168.0.153:5000';

    _dashboardService = DashboardService(
      baseUrl: baseUrl,
      token: token,
    );
  }

  Future<void> _loadDashboardData() async {
    try {
      print('🔄 Cargando dashboard...');
      final data = await _dashboardService.getDashboardData();
      print('✅ Datos recibidos: $data');

      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_errorMessage'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildMetricCard(
      String title, dynamic value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: 12),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _marronOscuro,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: _marronOscuro.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // GRÁFICO DE TORTA PARA CONSUMOS
  Widget _buildConsumosChart() {
    final actual = _dashboardData['actual'] ?? {};
    final agua = (actual['agua'] ?? 0).toDouble();
    final luz = (actual['luz'] ?? 0).toDouble();
    final gas = (actual['gas'] ?? 0).toDouble();

    final total = agua + luz + gas;
    if (total == 0) {
      return _buildEmptyChart();
    }

    List<PieChartSectionData> sections = [
      _buildChartSection('Agua', agua, _celesteClaro, total),
      _buildChartSection('Luz', luz, _duraznoSuave, total),
      _buildChartSection('Gas', gas, _verdeOliva, total),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución de Consumos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _azulProfundo,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                // Gráfico
                Container(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Leyenda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Agua', agua, _celesteClaro),
                      _buildLegendItem('Luz', luz, _duraznoSuave),
                      _buildLegendItem('Gas', gas, _verdeOliva),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart,
                  size: 40, color: _marronOscuro.withOpacity(0.3)),
              SizedBox(height: 8),
              Text(
                'No hay datos de consumo',
                style: TextStyle(
                  color: _marronOscuro.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _buildChartSection(
      String title, double value, Color color, double total) {
    final percentage = (value / total) * 100;
    return PieChartSectionData(
      color: color,
      value: value,
      title: '${percentage.toStringAsFixed(0)}%',
      radius: 40,
      titleStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegendItem(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _marronOscuro,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _azulProfundo,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ESTADO DE MANTENIMIENTOS (REEMPLAZA TICKETS)
  Widget _buildMantenimientosStatus() {
    final metricas = _dashboardData['metricas'] ?? {};
    final activos = metricas['mantenimientos_activos'] ?? 0;
    final completados = metricas['mantenimientos_completados'] ?? 0;
    final total = activos + completados;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de Mantenimientos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _azulProfundo,
              ),
            ),
            SizedBox(height: 16),
            _buildMantenimientoRow('Activos', activos, _duraznoSuave, total),
            _buildMantenimientoRow(
                'Completados', completados, _verdeOliva, total),
          ],
        ),
      ),
    );
  }

  Widget _buildMantenimientoRow(
      String label, int value, Color color, int total) {
    final percentage = total > 0 ? (value / total) * 100 : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _marronOscuro,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _azulProfundo,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '(${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(
              color: _marronOscuro.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Dashboard Empleado',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: _azulProfundo,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          color: _grisClaro,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_azulProfundo),
                ),
                SizedBox(height: 20),
                Text(
                  'Cargando dashboard...',
                  style: TextStyle(
                    color: _marronOscuro,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Dashboard Empleado',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: _azulProfundo,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          color: _grisClaro,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: _duraznoSuave),
                SizedBox(height: 20),
                Text(
                  'Error al cargar el dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _marronOscuro,
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _marronOscuro.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadDashboardData,
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label:
                      Text('Reintentar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _azulProfundo,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final metricas = _dashboardData['metricas'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Empleado',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _azulProfundo,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: MenuEmpleado.buildDrawer(context, _navigateTo),
      backgroundColor: _grisClaro,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        backgroundColor: _grisClaro,
        color: _azulProfundo,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header informativo
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [_beigeSuave, _beigeSuave.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.engineering, color: _azulProfundo),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Panel de Control - Empleado',
                            style: TextStyle(
                              color: _azulProfundo,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Métricas principales
              Text(
                'Mis Métricas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _azulProfundo,
                ),
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 0.9,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMetricCard(
                    'Mantenimientos\nActivos',
                    metricas['mantenimientos_activos'] ?? 0,
                    Icons.handyman,
                    _azulProfundo,
                  ),
                  _buildMetricCard(
                    'Mantenimientos\nCompletados',
                    metricas['mantenimientos_completados'] ?? 0,
                    Icons.check_circle,
                    _verdeOliva,
                  ),
                  _buildMetricCard(
                    'Último\nPago',
                    '\$${(metricas['ultimo_pago'] ?? 0).toStringAsFixed(2)}',
                    Icons.payment,
                    _duraznoSuave,
                  ),
                  _buildMetricCard(
                    'Días\nTrabajados',
                    '${metricas['dias_trabajados'] ?? 0}/${metricas['dias_laborales'] ?? 22}',
                    Icons.calendar_today,
                    _celesteClaro,
                  ),
                ],
              ),

              SizedBox(height: 28),

              // Gráfico de torta para consumos
              _buildConsumosChart(),

              SizedBox(height: 28),

              // Estado de mantenimientos
              _buildMantenimientosStatus(),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
