import 'dart:convert';
import 'package:http/http.dart' as http;

class UserLogin {
  final String correo;
  final String password;
  final String captcha;

  UserLogin({
    required this.correo,
    required this.password,
    required this.captcha,
  });

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'password': password,
      'captcha': captcha,
    };
  }
}

class LoginService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

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

  // Login real con tu API Flask
  static Future<Map<String, dynamic>> login(UserLogin userLogin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: headers,
        body: json.encode(userLogin.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Login exitoso',
          'user': data['user'],
        };
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Credenciales incorrectas',
        };
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
