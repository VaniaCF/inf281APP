// lib/residente/services/dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard_model.dart'; // Asegúrate de importar el modelo

class DashboardService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // Obtener el token de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No hay token de autenticación',
        };
      }

      print('🔍 Obteniendo datos del dashboard API...');

      final response = await http.get(
        Uri.parse('$baseUrl/api/residentes/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Dashboard Status Code: ${response.statusCode}');
      print('🔍 Dashboard Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // Debug adicional para ver la estructura
          print('✅ Estructura de data recibida:');
          print('   - residente: ${responseData['data']?['residente']}');
          print('   - estadisticas: ${responseData['data']?['estadisticas']}');
          print(
              '   - notificaciones: ${responseData['data']?['notificaciones_recientes']}');

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
      } else {
        return {
          'success': false,
          'message': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error en DashboardService: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
