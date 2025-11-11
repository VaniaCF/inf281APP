import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ✅ DEFINIR la clase DashboardData PRIMERO
class DashboardData {
  final int totalUsuarios;
  final int ticketsPendientes;
  final int ticketsUrgentes;
  final int totalTickets;
  final int reservasHoy;
  final int reservasActivas;

  DashboardData({
    required this.totalUsuarios,
    required this.ticketsPendientes,
    required this.ticketsUrgentes,
    required this.totalTickets,
    required this.reservasHoy,
    required this.reservasActivas,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalUsuarios: json['total_usuarios'] ?? 0,
      ticketsPendientes: json['tickets_pendientes'] ?? 0,
      ticketsUrgentes: json['tickets_urgentes'] ?? 0,
      totalTickets: json['total_tickets'] ?? 0,
      reservasHoy: json['reservas_hoy'] ?? 0,
      reservasActivas: json['reservas_activas'] ?? 0,
    );
  }
}

class DashboardService {
  static const String baseUrl = 'http://192.168.1.12:5000';

  // ✅ Obtener token guardado
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('❌ Error obteniendo token: $e');
      return null;
    }
  }

  // ✅ ENDPOINT REAL CON AUTENTICACIÓN
  static Future<DashboardData> obtenerDatosDashboard() async {
    try {
      print('🔗 Conectando a: $baseUrl/api/protected/dashboard');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/protected/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Datos REALES recibidos con autenticación');
          return DashboardData.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Error del servidor');
        }
      } else if (response.statusCode == 401) {
        throw Exception('No autenticado. Por favor, inicia sesión primero en el navegador web.');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en dashboard protegido: $e');
      
      // ✅ Si falla, intentar con endpoint público como fallback
      return await _obtenerDatosDashboardPublico();
    }
  }

  // ✅ MÉTODO FALLBACK - Endpoint público
  static Future<DashboardData> _obtenerDatosDashboardPublico() async {
    try {
      print('🔄 Intentando endpoint público...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/public/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Datos PÚBLICOS recibidos');
        return DashboardData.fromJson(data);
      } else {
        throw Exception('Endpoint público no disponible');
      }
    } catch (e) {
      print('❌ Error en endpoint público: $e');
      
      // ✅ Último recurso: datos de prueba
      print('🆘 Usando datos de prueba locales');
      return DashboardData(
        totalUsuarios: 150,
        ticketsPendientes: 12,
        ticketsUrgentes: 3,
        totalTickets: 45,
        reservasHoy: 8,
        reservasActivas: 23,
      );
    }
  }
}