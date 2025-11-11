// admin/pages/dashboard_admin.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../login/services/login_service.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    print('🔗 Conectando a: http://192.168.1.12:5000/admin/api/dashboard');
    
    final response = await http.get(
      Uri.parse('http://192.168.1.12:5000/admin/api/dashboard'),
      headers: LoginService.getAuthHeaders(),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📊 Response headers: ${response.headers}');
    print('📊 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        setState(() {
          _dashboardData = data['data'] ?? {};
          _isLoading = false;
        });
        print('✅ Datos REALES del dashboard cargados correctamente');
      } else {
        throw Exception(data['error'] ?? 'Error desconocido del servidor');
      }
    } else if (response.statusCode == 500) {
      // ✅ OBTENER MÁS DETALLES DEL ERROR 500
      final errorData = json.decode(response.body);
      throw Exception('Error interno del servidor: ${errorData['error'] ?? 'Desconocido'}');
    } else if (response.statusCode == 401) {
      throw Exception('No autenticado. Por favor, inicia sesión nuevamente.');
    } else if (response.statusCode == 403) {
      throw Exception('Acceso no autorizado. No tienes permisos de administrador.');
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error cargando dashboard: $e');
    setState(() {
      _isLoading = false;
      _errorMessage = e.toString();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  // Método para probar diferentes URLs (temporal para debug)
  Future<void> _testAllUrls() async {
    final urls = [
      'http://192.168.1.12:5000/admin/api/dashboard',    // ✅ Esta debería funcionar
      'http://192.168.1.12:5000/api/protected/dashboard', // Endpoint directo en app.py
      'http://192.168.1.12:5000/api/dashboard',           // ❌ Sin prefijo (404)
    ];

    for (final url in urls) {
      try {
        print('🔍 Probando URL: $url');
        final response = await http.get(
          Uri.parse(url),
          headers: LoginService.getAuthHeaders(),
        );
        print('📊 $url → Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          print('🎯 URL CORRECTA ENCONTRADA: $url');
          break;
        }
      } catch (e) {
        print('❌ $url → Error: $e');
      }
    }
  }

  Widget _buildStatCard(String title, dynamic value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value?.toString() ?? '0',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Administrador'),
        backgroundColor: const Color(0xFF264653),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.bug_report), // ✅ Botón para debug
            onPressed: _testAllUrls,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Reintentar'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _testAllUrls, // ✅ Botón para debug
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Probar URLs'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        'Estadísticas del Sistema',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF264653),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Resumen general de la plataforma',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grid de estadísticas
                      Expanded(
                        child: GridView(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          children: [
                            _buildStatCard(
                              'Total Usuarios',
                              _dashboardData['total_usuarios'],
                              const Color(0xFF264653),
                              Icons.people,
                            ),
                            _buildStatCard(
                              'Tickets Pendientes',
                              _dashboardData['tickets_pendientes'],
                              Colors.orange,
                              Icons.support_agent,
                            ),
                            _buildStatCard(
                              'Tickets Urgentes',
                              _dashboardData['tickets_urgentes'],
                              Colors.red,
                              Icons.warning,
                            ),
                            _buildStatCard(
                              'Total Tickets',
                              _dashboardData['total_tickets'],
                              Colors.blue,
                              Icons.list_alt,
                            ),
                            _buildStatCard(
                              'Reservas Activas',
                              _dashboardData['reservas_activas'],
                              Colors.green,
                              Icons.calendar_today,
                            ),
                            _buildStatCard(
                              'Reservas Hoy',
                              _dashboardData['reservas_hoy'],
                              Colors.purple,
                              Icons.event_available,
                            ),
                          ],
                        ),
                      ),

                      // Información adicional
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información del Sistema',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Última actualización: ${DateTime.now().toString()}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              if (_dashboardData['ingresos_mensuales'] != null)
                                Text(
                                  'Ingresos mensuales: \$${_dashboardData['ingresos_mensuales']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              if (_dashboardData['nuevos_usuarios_mes'] != null)
                                Text(
                                  'Nuevos usuarios este mes: ${_dashboardData['nuevos_usuarios_mes']}',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _logout() async {
    try {
      // Cerrar sesión en el servidor
      final response = await http.post(
        Uri.parse('http://192.168.1.12:5000/api/auth/logout'),
        headers: LoginService.getAuthHeaders(),
      );

      // Limpiar datos locales sin importar la respuesta del servidor
      await LoginService.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('user_data');

      // Navegar al login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('❌ Error en logout: $e');
      // Limpiar datos locales incluso si hay error
      await LoginService.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('user_data');
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}