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
}
