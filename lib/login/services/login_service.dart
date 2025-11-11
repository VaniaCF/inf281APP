import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ← AÑADIR ESTO

// En login_service.dart - Actualiza la clase UserLogin
class UserLogin {
  final String correo;
  final String password;
  final String captcha;
  final String captchaId;

  UserLogin({
    required this.correo,
    required this.password,
    required this.captcha,
    required this.captchaId,
  });

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'password': password,
      'captcha': captcha,
      'captcha_id': captchaId,
    };
  }
}

class LoginService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Login real con tu API Flask - CÓDIGO CORREGIDO
  static Future<Map<String, dynamic>> login(UserLogin userLogin) async {
    try {
      print('🔍 Enviando login request...');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: headers,
        body: json.encode(userLogin.toJson()),
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      // Verificar si la respuesta es JSON válido
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('✅ Login response decoded: $data');

          // GUARDAR EL TOKEN EN SHARED_PREFERENCES
          if (data['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', data['token']);
            print('✅ Token guardado: ${data['token']}');
          }

          return {
            'success': true,
            'message': data['message'] ?? 'Login exitoso',
            'user': data['user'],
            'token': data['token'],
          };
        } catch (e) {
          print('❌ Error decoding JSON: $e');
          return {
            'success': false,
            'message': 'Error procesando respuesta del servidor: $e',
          };
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Connection error: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Método para obtener el token guardado (útil para otras partes de la app)
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Método para cerrar sesión (limpiar token)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Test de conexión
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/test'));
      return {
        'success': response.statusCode == 200,
        'message': response.statusCode == 200
            ? 'Conexión exitosa'
            : 'Error de conexión',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCaptcha() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/captcha'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'captcha': data['captcha'] ?? '',
          'captcha_id': data['captcha_id'] ?? '', // ← ESTO ES IMPORTANTE
        };
      } else {
        return {
          'success': false,
          'captcha': '',
          'message': 'Error al obtener CAPTCHA',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'captcha': '',
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Validar CAPTCHA con el backend
  static Future<Map<String, dynamic>> validateCaptcha(
      String userInput, String captchaId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/validate_captcha'),
        headers: headers,
        body: json.encode({
          'user_input': userInput,
          'captcha_id': captchaId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'valid': data['valid'] ?? false,
          'message': data['message'] ?? 'CAPTCHA validado',
        };
      } else {
        return {
          'success': false,
          'valid': false,
          'message': 'Error al validar CAPTCHA',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'valid': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Solicitar código de invitación - CONEXIÓN REAL
  static Future<Map<String, dynamic>> solicitarCodigoInvitacion(
      String correo, String rol) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/solicitar_codigo'),
        headers: headers,
        body: json.encode({
          'correo': correo,
          'rol': rol,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Código enviado exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al enviar código',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Validar código de invitación - CONEXIÓN REAL
  static Future<Map<String, dynamic>> validarCodigoInvitacion(
      String codigo, String rol) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/validar_codigo'),
        headers: headers,
        body: json.encode({
          'codigo': codigo,
          'rol': rol,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'valido': data['valido'] ?? false,
          'message': data['message'] ?? data['valido'] == true
              ? 'Código válido'
              : 'Código inválido',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'valido': false,
          'message': errorData['message'] ?? 'Error al validar código',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'valido': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Registrar nuevo residente - CONEXIÓN REAL
  static Future<Map<String, dynamic>> registrarResidente(
      Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register/residente'),
        headers: headers,
        body: json.encode(datos),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Registro exitoso',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Registrar nuevo empleado - CONEXIÓN REAL
  static Future<Map<String, dynamic>> registrarEmpleado(
      Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register/empleado'),
        headers: headers,
        body: json.encode(datos),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Registro exitoso',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Registrar nuevo administrador - CONEXIÓN REAL
  static Future<Map<String, dynamic>> registrarAdmin(
      Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register/admin'),
        headers: headers,
        body: json.encode(datos),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Registro exitoso',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // En tu LoginService, agrega:
  static Future<Map<String, dynamic>> testAuth() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/test'),
        headers: headers,
      );
      print('🔍 Test Auth Response: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      print('❌ Test Auth Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
