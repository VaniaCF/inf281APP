// login/services/login_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_login.dart';

class LoginService {
  static const String baseUrl =
      'http://192.168.0.153:5000'; /////////////////////////////////
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // ========== MÉTODOS PRINCIPALES CON FALLBACK LOCAL ==========

  // Login con fallback a modo demo si falla la conexión
// login/services/login_service.dart - ACTUALIZA EL MÉTODO login
  static Future<Map<String, dynamic>> login(UserLogin userLogin) async {
    try {
      print('🔍 Intentando login con backend...');

      // OBTENER CAPTCHA REAL DEL BACKEND para esta solicitud
      final captchaResult = await getCaptcha();
      if (captchaResult['success'] != true) {
        throw Exception('No se pudo obtener CAPTCHA del servidor');
      }

      final String realCaptcha = captchaResult['captcha']!;
      final String realCaptchaId = captchaResult['captcha_id']!;

      print('🔄 Usando CAPTCHA real: $realCaptcha, ID: $realCaptchaId');

      final Map<String, dynamic> loginData = {
        'correo': userLogin.correo,
        'password': userLogin.password,
        'captcha': realCaptcha,
        'captcha_id': realCaptchaId,
      };

      print('📤 Enviando datos de login real...');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: headers,
            body: json.encode(loginData),
          )
          .timeout(const Duration(seconds: 15));

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          print('✅ Login exitoso con backend REAL');

          // ✅ CORREGIDO: Guardar token con key 'auth_token' (consistente)
          if (data['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                'auth_token', data['token']); // ← KEY CORREGIDA
            print('✅ Token real guardado como auth_token');
          }

          return {
            'success': true,
            'message': data['message'] ?? 'Login exitoso',
            'user': data['user'],
            'token': data['token'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Error en el login',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Error HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error de conexión con backend REAL: $e');
      return {
        'success': false,
        'message': 'No se pudo conectar al servidor: $e',
      };
    }
  }

  // Modo demo para cuando no hay conexión
  static Map<String, dynamic> _loginDemo(UserLogin userLogin) {
    // Validación básica local
    if (userLogin.correo.isEmpty || userLogin.password.isEmpty) {
      return {
        'success': false,
        'message': 'Por favor completa todos los campos',
      };
    }

    // Simular validación de credenciales (en una app real esto sería con base de datos)
    final email = userLogin.correo.toLowerCase();

    // Credenciales demo
    if (email == 'admin@demo.com' && userLogin.password == 'admin123') {
      return {
        'success': true,
        'message': 'Login exitoso (modo demo)',
        'user': {
          'id_usuario': 1,
          'nombre': 'Administrador',
          'ap_paterno': 'Demo',
          'correo': 'admin@demo.com',
          'id_rol': 1,
        },
        'token': 'demo_token_admin_${DateTime.now().millisecondsSinceEpoch}',
      };
    } else if (email == 'empleado@demo.com' &&
        userLogin.password == 'empleado123') {
      return {
        'success': true,
        'message': 'Login exitoso (modo demo)',
        'user': {
          'id_usuario': 2,
          'nombre': 'Empleado',
          'ap_paterno': 'Demo',
          'correo': 'empleado@demo.com',
          'id_rol': 2,
        },
        'token': 'demo_token_empleado_${DateTime.now().millisecondsSinceEpoch}',
      };
    } else if (email == 'residente@demo.com' &&
        userLogin.password == 'residente123') {
      return {
        'success': true,
        'message': 'Login exitoso (modo demo)',
        'user': {
          'id_usuario': 3,
          'nombre': 'Residente',
          'ap_paterno': 'Demo',
          'correo': 'residente@demo.com',
          'id_rol': 3,
        },
        'token':
            'demo_token_residente_${DateTime.now().millisecondsSinceEpoch}',
      };
    } else {
      // Usuario genérico para cualquier email/password
      return {
        'success': true,
        'message': 'Login exitoso (modo demo)',
        'user': {
          'id_usuario': 3,
          'nombre': 'Usuario',
          'ap_paterno': 'Demo',
          'correo': userLogin.correo,
          'id_rol': 3,
        },
        'token': 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
      };
    }
  }

  // ========== CAPTCHA LOCAL ==========

  // Generar CAPTCHA local (no necesita backend)
  static Future<Map<String, dynamic>> getCaptcha() async {
    try {
      // Primero intentar con el backend
      print('🌐 Intentando obtener CAPTCHA del backend...');

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/auth/captcha'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ CAPTCHA obtenido del backend');
        return {
          'success': true,
          'captcha': data['captcha'] ?? '',
          'captcha_id': data['captcha_id'] ?? '',
        };
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a CAPTCHA local
      print('🔄 Usando CAPTCHA local: $e');
      return _generateLocalCaptcha();
    }
  }

  // Generar CAPTCHA local
  static Map<String, dynamic> _generateLocalCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final captcha = String.fromCharCodes(
      Iterable.generate(
          6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    return {
      'success': true,
      'captcha': captcha,
      'captcha_id': 'local_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Validar CAPTCHA localmente
  static bool validateCaptchaLocally(String userInput, String expected) {
    return userInput.trim().toUpperCase() == expected.trim().toUpperCase();
  }

  // ========== GESTIÓN DE TOKENS ==========
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // ← KEY CORREGIDA
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ========== MÉTODOS DE PRUEBA ==========

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🔍 Probando conexión con el servidor...');

      final response = await http
          .get(
            Uri.parse('$baseUrl'),
          )
          .timeout(const Duration(seconds: 5));

      return {
        'success': response.statusCode == 200,
        'message': response.statusCode == 200
            ? '✅ Conexión exitosa con el servidor'
            : '❌ Error de conexión: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '❌ No se pudo conectar al servidor: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> testAuth() async {
    try {
      print('🔍 Probando endpoint de autenticación...');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/test'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      print('🔍 Test Auth Response: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      print('❌ Test Auth Error: $e');
      return {
        'success': false,
        'message': '❌ Error probando autenticación: $e'
      };
    }
  }

  // ========== MÉTODOS DE REGISTRO CON FALLBACK ==========

  static Future<Map<String, dynamic>> registrarResidente(
      Map<String, dynamic> datos) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/register/residente'),
            headers: headers,
            body: json.encode(datos),
          )
          .timeout(const Duration(seconds: 10));

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
        'message':
            'Error de conexión: $e\n\nPuedes usar el modo demo con:\nEmail: residente@demo.com\nPassword: residente123',
      };
    }
  }

  // Métodos similares para empleado y admin...
  static Future<Map<String, dynamic>> registrarEmpleado(
      Map<String, dynamic> datos) async {
    return _registrarDemo('empleado', datos);
  }

  static Future<Map<String, dynamic>> registrarAdmin(
      Map<String, dynamic> datos) async {
    return _registrarDemo('admin', datos);
  }

  static Future<Map<String, dynamic>> _registrarDemo(
      String tipo, Map<String, dynamic> datos) async {
    // Simular registro exitoso en modo demo
    await Future.delayed(const Duration(seconds: 2));

    return {
      'success': true,
      'message':
          'Registro de $tipo exitoso (modo demo)\n\nAhora puedes iniciar sesión con:\nEmail: ${datos['correo']}\nPassword: ${datos['password']}',
    };
  }

  // ========== MÉTODOS DE INVITACIÓN ==========

  static Future<Map<String, dynamic>> solicitarCodigoInvitacion(
      String correo, String rol) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/solicitar_codigo'),
            headers: headers,
            body: json.encode({'correo': correo, 'rol': rol}),
          )
          .timeout(const Duration(seconds: 10));

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
        'message':
            'Error de conexión: $e\n\nEn modo demo, usa cualquier código.',
      };
    }
  }

  static Future<Map<String, dynamic>> validarCodigoInvitacion(
      String codigo, String rol) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/validar_codigo'),
            headers: headers,
            body: json.encode({'codigo': codigo, 'rol': rol}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'valido': data['valido'] ?? false,
          'message': data['message'] ??
              (data['valido'] == true ? 'Código válido' : 'Código inválido'),
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
      // En modo demo, aceptar cualquier código que tenga al menos 4 caracteres
      final isValidDemo = codigo.length >= 4;
      return {
        'success': true,
        'valido': isValidDemo,
        'message': isValidDemo
            ? '✅ Código válido (modo demo)'
            : '❌ Código debe tener al menos 4 caracteres',
      };
    }
  }
}
