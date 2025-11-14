// lib/residente/services/dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardService {
  static const String baseUrl = 'http://192.168.0.153:5000';

  // 🔥 NUEVO: Método para obtener headers con JWT
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('auth_token') ?? ''; // ← CAMBIO IMPORTANTE

    print('🔐 [DASHBOARD] Obteniendo headers...');
    print(
        '🔐 [DASHBOARD] auth_token: ${token.isNotEmpty ? "PRESENTE" : "AUSENTE"}');

    if (token.isEmpty) {
      print('❌ [DASHBOARD] ERROR: No hay token en auth_token');
      throw Exception('No hay token de autenticación disponible');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      print('🔍 [DASHBOARD] Obteniendo datos del dashboard...');

      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/residentes/dashboard'),
        headers: headers,
      );

      print('🔍 [DASHBOARD] Status Code: ${response.statusCode}');
      print('🔍 [DASHBOARD] Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          print('✅ [DASHBOARD] Datos recibidos exitosamente');
          print(
              '   👤 Residente: ${responseData['data']?['residente']?['nombre_completo']}');
          print('   📊 Estadísticas: ${responseData['data']?['estadisticas']}');

          return {
            'success': true,
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message':
                responseData['message'] ?? 'Error en la respuesta del servidor',
          };
        }
      } else if (response.statusCode == 401 || response.statusCode == 422) {
        // Error de autenticación
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error de autenticación',
          'auth_error': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ [DASHBOARD] Error: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // 🔥 NUEVO: Método para probar la conexión del dashboard
  static Future<Map<String, dynamic>> testDashboardConnection() async {
    try {
      final headers = await _getHeaders();

      print('🧪 [DASHBOARD TEST] Probando conexión...');

      final response = await http.get(
        Uri.parse('$baseUrl/api/residentes/dashboard'),
        headers: headers,
      );

      print('🧪 [DASHBOARD TEST] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return {
          'success': true,
          'message': '✅ Dashboard conectado correctamente',
          'data': result
        };
      } else {
        return {
          'success': false,
          'message': '❌ Error en dashboard: ${response.statusCode}',
          'status_code': response.statusCode
        };
      }
    } catch (e) {
      return {'success': false, 'message': '❌ Error de conexión: $e'};
    }
  }
}
