import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardData {
  final int totalUsuarios;
  final int ticketsPendientes;
  final int ticketsUrgentes;
  final int totalTickets;
  final double ingresosMensuales;
  final double variacionIngresos;
  final int nuevosUsuariosMes;
  final int reservasActivas;
  final int reservasHoy;

  DashboardData({
    required this.totalUsuarios,
    required this.ticketsPendientes,
    required this.ticketsUrgentes,
    required this.totalTickets,
    required this.ingresosMensuales,
    required this.variacionIngresos,
    required this.nuevosUsuariosMes,
    required this.reservasActivas,
    required this.reservasHoy,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalUsuarios: json['total_usuarios'] ?? 0,
      ticketsPendientes: json['tickets_pendientes'] ?? 0,
      ticketsUrgentes: json['tickets_urgentes'] ?? 0,
      totalTickets: json['total_tickets'] ?? 0,
      ingresosMensuales: (json['ingresos_mensuales'] ?? 0).toDouble(),
      variacionIngresos: (json['variacion_ingresos'] ?? 0).toDouble(),
      nuevosUsuariosMes: json['nuevos_usuarios_mes'] ?? 0,
      reservasActivas: json['reservas_activas'] ?? 0,
      reservasHoy: json['reservas_hoy'] ?? 0,
    );
  }
}

class DashboardService {
      final String baseUrl = 'http://192.168.1.12:5000'; 

  Future<DashboardData> obtenerDatosDashboard() async {
    try {
      print('🔄 Solicitando datos del dashboard...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/api/dashboard'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final Map<String, dynamic> data = responseData['data'];
          print('✅ Datos del dashboard cargados exitosamente');
          return DashboardData.fromJson(data);
        } else {
          throw Exception('Error del servidor: ${responseData['error']}');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Acceso no autorizado. Verifica tus permisos de administrador.');
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerDatosDashboard: $e');
      throw Exception('No se pudieron cargar los datos del dashboard. Verifica que el servidor Flask esté ejecutándose.');
    }
  }

  Future<bool> probarConexion() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}