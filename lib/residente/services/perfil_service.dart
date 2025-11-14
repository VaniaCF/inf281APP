// lib/services/residente/perfil_service.dart - VERSIÓN CORREGIDA
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PerfilService {
  // 🔥 CORREGIDO: Usa la misma URL base que tu tickets_service
  static const String _baseUrl = 'http://192.168.0.153:5000/api/movil';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    print('🔐 [PERFIL HEADERS] Obteniendo headers...');
    print(
        '🔐 [PERFIL HEADERS] Token: ${token.isNotEmpty ? "PRESENTE" : "AUSENTE"}');

    if (token.isEmpty) {
      print('❌ [PERFIL HEADERS] ERROR: No hay token en auth_token');
      throw Exception('No hay token de autenticación disponible');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // Obtener datos del perfil - CON DEBUG COMPLETO
  static Future<Map<String, dynamic>> obtenerPerfil() async {
    try {
      print('🔄 [PERFIL SERVICE] Iniciando obtención de perfil...');

      final headers = await _getHeaders();
      final url = '$_baseUrl/residente/perfil';

      print('🔍 [PERFIL SERVICE] URL: $url');
      print(
          '🔐 [PERFIL SERVICE] Headers: ${headers['Authorization']?.substring(0, 30)}...');

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print('📡 [PERFIL SERVICE] Response status: ${response.statusCode}');
      print('📡 [PERFIL SERVICE] Response headers: ${response.headers}');
      print('📡 [PERFIL SERVICE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [PERFIL SERVICE] Datos recibidos correctamente');
        print('   - Success: ${data['success']}');
        print('   - Message: ${data['message']}');

        return {
          'success': data['success'] ?? false,
          'data': data,
          'message': data['message'] ?? 'Datos cargados correctamente',
        };
      } else if (response.statusCode == 401) {
        print('❌ [PERFIL SERVICE] Error 401 - Token inválido o faltante');
        return {
          'success': false,
          'message':
              'Token de acceso inválido. Por favor inicia sesión nuevamente.',
        };
      } else {
        final errorData = json.decode(response.body);
        print(
            '❌ [PERFIL SERVICE] Error ${response.statusCode}: ${errorData['message']}');
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al cargar el perfil',
        };
      }
    } on http.ClientException catch (e) {
      print('❌ [PERFIL SERVICE] Error de conexión: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Verifica tu internet.',
      };
    } on Exception catch (e) {
      print('❌ [PERFIL SERVICE] Error general: $e');
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // Obtener resumen del dashboard
  static Future<Map<String, dynamic>> obtenerResumenDashboard() async {
    try {
      print('🔄 [PERFIL SERVICE] Obteniendo resumen dashboard...');

      final headers = await _getHeaders();
      final url = '$_baseUrl/residente/dashboard/resumen';

      print('🔍 [PERFIL SERVICE] URL: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print('📡 [PERFIL SERVICE] Dashboard response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'data': data['resumen'] ?? {},
          'message': data['message'] ?? 'Resumen cargado correctamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al cargar el resumen',
        };
      }
    } catch (e) {
      print('❌ [PERFIL SERVICE] Dashboard error: $e');
      return {
        'success': false,
        'message': 'Error al cargar el resumen: $e',
      };
    }
  }

  // Actualizar perfil
  static Future<Map<String, dynamic>> actualizarPerfil(
      Map<String, dynamic> datos) async {
    try {
      print('🔄 [PERFIL SERVICE] Actualizando perfil...');

      final headers = await _getHeaders();
      final url = '$_baseUrl/residente/perfil/actualizar';

      print('🔍 [PERFIL SERVICE] URL: $url');
      print('📦 [PERFIL SERVICE] Datos: $datos');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(datos),
          )
          .timeout(const Duration(seconds: 10));

      print('📡 [PERFIL SERVICE] Update response: ${response.statusCode}');
      print('📡 [PERFIL SERVICE] Update body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Perfil actualizado correctamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al actualizar el perfil',
        };
      }
    } catch (e) {
      print('❌ [PERFIL SERVICE] Update error: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Cambiar contraseña
  static Future<Map<String, dynamic>> cambiarPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      print('🔄 [PERFIL SERVICE] Cambiando contraseña...');

      final headers = await _getHeaders();
      final url = '$_baseUrl/residente/password/cambiar';

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode({
              'current_password': currentPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Contraseña cambiada correctamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al cambiar la contraseña',
        };
      }
    } catch (e) {
      print('❌ [PERFIL SERVICE] Password error: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Cerrar otras sesiones
  static Future<Map<String, dynamic>> cerrarOtrasSesiones() async {
    try {
      print('🔄 [PERFIL SERVICE] Cerrando otras sesiones...');

      final headers = await _getHeaders();
      final url = '$_baseUrl/residente/sesiones/cerrar-otras';

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Otras sesiones cerradas correctamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al cerrar otras sesiones',
        };
      }
    } catch (e) {
      print('❌ [PERFIL SERVICE] Cerrar sesiones error: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Actualizar preferencias
  static Future<Map<String, dynamic>> actualizarPreferencias(
      Map<String, bool> preferencias) async {
    try {
      print('🔄 [PERFIL SERVICE] Actualizando preferencias...');

      final headers = await _getHeaders();
      final url = '$_baseUrl/residente/preferencias/actualizar';

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode({'preferencias': preferencias}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Preferencias actualizadas',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al actualizar preferencias',
        };
      }
    } catch (e) {
      print('❌ [PERFIL SERVICE] Preferencias error: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
