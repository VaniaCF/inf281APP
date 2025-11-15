// lib/empleado/pages/perfil_empleado.dart
import 'package:flutter/material.dart';
import '../services/perfiil_service.dart';
import '../widgets/menu_empleado.dart';

class PerfilEmpleadoPage extends StatefulWidget {
  const PerfilEmpleadoPage({Key? key}) : super(key: key);

  @override
  _PerfilEmpleadoPageState createState() => _PerfilEmpleadoPageState();
}

class _PerfilEmpleadoPageState extends State<PerfilEmpleadoPage> {
  late PerfilService _perfilService;
  PerfilEmpleado? _empleado;
  EstadisticasEmpleado? _estadisticas;
  bool _isLoading = true;
  String _errorMessage = '';

  // PALETA DE COLORES
  final Color _azulProfundo = Color(0xFF264653);
  final Color _beigeSuave = Color(0xFFEDE6E0);
  final Color _grisClaro = Color(0xFFF5F5F5);
  final Color _marronOscuro = Color(0xFF2F241F);
  final Color _duraznoSuave = Color(0xFFE3A78C);
  final Color _celesteClaro = Color(0xFFA3C8D6);
  final Color _verdeOliva = Color(0xFF7A8C6E);
  final Color _rojoSuave = Color(0xFFE57373);
  final Color _verdeSuave = Color(0xFF81C784);

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadPerfil();
  }

  void _initializeService() {
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0LCJjb3JyZW8iOiJ2YW5pYWNhcnJhc2NvNjgwNTY1MzBAZ21haWwuY29tIiwiaWRfcm9sIjoyLCJleHAiOjE3NjMzMDI2MDN9.jNv2lhTCz2IDRQD9rWcfbwSwOp7cY_cNEsRAlD6D8Ac';
    final baseUrl = 'http://192.168.0.153:5000';

    print('🔧 [PERFIL] Inicializando servicio...');
    print('📍 Base URL: $baseUrl');

    _perfilService = PerfilService(
      baseUrl: baseUrl,
      token: token,
    );
  }

  Future<void> _loadPerfil() async {
    try {
      print('🔄 [PERFIL] Cargando perfil...');
      final perfilResponse = await _perfilService.getPerfil();
      print('✅ [PERFIL] Perfil cargado exitosamente');

      setState(() {
        _empleado = perfilResponse.empleado;
        _estadisticas = perfilResponse.estadisticas;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      print('❌ [PERFIL] Error: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: ${e.toString()}'),
            backgroundColor: _rojoSuave,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_azulProfundo, Color(0xFF1a3340)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: _azulProfundo,
            ),
          ),
          SizedBox(height: 16),
          Text(
            _empleado?.nombreCompleto ?? 'Cargando...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            _empleado?.puesto ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _empleado?.correo ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaItem(
      String titulo, String valor, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        SizedBox(height: 8),
        Text(
          valor,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _marronOscuro,
          ),
        ),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 10,
            color: _marronOscuro.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoPersonal() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: _azulProfundo),
                SizedBox(width: 8),
                Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _azulProfundo,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoItem(
                'Cédula', _empleado?.ci ?? 'No especificado', Icons.badge),
            _buildInfoItem('Teléfono', _empleado?.telefono ?? 'No especificado',
                Icons.phone),
            _buildInfoItem('Fecha Contratación',
                _empleado?.fechaContratacion ?? '', Icons.calendar_today),
            _buildInfoItem(
                'Tipo Contrato',
                _empleado?.tipoContrato ?? 'No especificado',
                Icons.description),
            _buildInfoItem(
                'Turno', _empleado?.turno ?? 'No especificado', Icons.schedule),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoFinanciera() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: _azulProfundo),
                SizedBox(width: 8),
                Text(
                  'Información Financiera',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _azulProfundo,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoItem(
                'Salario',
                'S/ ${_empleado?.salario.toStringAsFixed(2) ?? "0.00"}',
                Icons.attach_money),
            _buildInfoItem('Banco', _empleado?.banco ?? 'No especificado',
                Icons.account_balance),
            _buildInfoItem(
                'N° Cuenta',
                _empleado?.numeroCuenta ?? 'No especificado',
                Icons.credit_card),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String titulo, String valor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _marronOscuro.withOpacity(0.6)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: _marronOscuro.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 14,
                    color: _marronOscuro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: _marronOscuro.withOpacity(0.3),
          ),
          SizedBox(height: 20),
          Text(
            'No se pudo cargar el perfil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _marronOscuro,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Error: $_errorMessage',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _marronOscuro.withOpacity(0.6),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
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
            onPressed: _loadPerfil,
          ),
        ],
      ),
      drawer: MenuEmpleado.buildDrawer(context, _navigateTo),
      backgroundColor: _grisClaro,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_azulProfundo),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando perfil...',
                    style: TextStyle(
                      color: _marronOscuro,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty || _empleado == null
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadPerfil,
                  backgroundColor: _grisClaro,
                  color: _azulProfundo,
                  child: ListView(
                    children: [
                      _buildHeader(),
                      _buildInfoPersonal(),
                      _buildInfoFinanciera(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
