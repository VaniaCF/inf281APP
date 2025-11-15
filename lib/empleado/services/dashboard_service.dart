import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardService {
  final String baseUrl;
  final String token;

  DashboardService({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  // ✅ CORREGIDO: Usa el endpoint EXACTO de tu empleadomovil.py
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      print('🔐 Token usado: ${token.substring(0, 20)}...');
      print('🌐 URL completa: $baseUrl/api/movil/empleado/dashboard-data');

      final response = await http.get(
        Uri.parse('$baseUrl/api/movil/empleado/dashboard-data'),
        headers: _headers,
      );

      print('📊 Status Code: ${response.statusCode}');
      print('📋 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(
              data['error'] ?? 'Error al obtener datos del dashboard');
        }
      } else {
        throw Exception(
            'Error del servidor: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error completo: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ CORREGIDO: Endpoint para mantenimientos
  Future<List<dynamic>> getMantenimientos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/movil/empleado/mantenimientos'), // ✅ EXACTO
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['error'] ?? 'Error al obtener mantenimientos');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ CORREGIDO: Endpoint para pagos
  Future<Map<String, dynamic>> getPagos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/movil/empleado/pagos'), // ✅ EXACTO
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['error'] ?? 'Error al obtener pagos');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ CORREGIDO: Endpoint para perfil
  Future<Map<String, dynamic>> getPerfil() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/movil/empleado/perfil'), // ✅ EXACTO
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['error'] ?? 'Error al obtener perfil');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Métodos adicionales que puedes necesitar (si los tienes en tu backend)
  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/movil/empleado/estadisticas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['error'] ?? 'Error al obtener estadísticas');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
