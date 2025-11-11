import 'dart:convert';
import 'package:http/http.dart' as http;


class AdminService {
  static const String baseUrl = 'http://192.168.1.12:5000';
  
  // Verificar si la respuesta es HTML (redirección al login)
  static bool _isHtmlResponse(http.Response response) {
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    return contentType.contains('text/html') || 
           response.body.trim().toLowerCase().startsWith('<!doctype html');
  }

  // Obtener datos del dashboard con manejo de sesión
  static Future<Map<String, dynamic>> obtenerDatosDashboard() async {
    try {
      print('🔗 Conectando a: $baseUrl/api/dashboard');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📊 Response status: ${response.statusCode}');
      print('📊 Content-Type: ${response.headers['content-type']}');

      // Verificar si es HTML (redirección al login)
      if (_isHtmlResponse(response)) {
        print('❌ Redirección al login detectada');
        throw Exception('Sesión expirada o no autenticado');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Datos recibidos correctamente');
        return data;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado - Sesión expirada');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('❌ Error de conexión: $e');
      throw Exception('No se pudo conectar al servidor. Verifica que Flask esté ejecutándose en $baseUrl');
    } on FormatException catch (e) {
      print('❌ Error de formato: $e');
      throw Exception('El servidor respondió con formato incorrecto. Posible redirección al login.');
    } catch (e) {
      print('❌ Error inesperado: $e');
      throw Exception('Error al cargar datos: $e');
    }
  }
}