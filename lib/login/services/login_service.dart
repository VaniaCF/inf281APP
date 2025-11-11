// services/login_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const String baseUrl = 'http://192.168.1.12:5000';
  static String? _sessionCookie; // ✅ Almacenar cookie de sesión

  // ✅ Método para obtener/establecer la cookie
  static String? get sessionCookie => _sessionCookie;
  
  static void setSessionCookie(String cookie) {
    _sessionCookie = cookie;
    _saveCookieToPrefs(cookie);
  }

  // ✅ Guardar cookie en SharedPreferences
  static Future<void> _saveCookieToPrefs(String cookie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_cookie', cookie);
      print('💾 Cookie guardada: ${cookie.substring(0, 50)}...');
    } catch (e) {
      print('❌ Error guardando cookie: $e');
    }
  }

  // ✅ Cargar cookie desde SharedPreferences
  static Future<void> _loadCookieFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCookie = prefs.getString('session_cookie');
      if (savedCookie != null) {
        _sessionCookie = savedCookie;
        print('📥 Cookie cargada desde prefs');
      }
    } catch (e) {
      print('❌ Error cargando cookie: $e');
    }
  }

  // ✅ Headers con cookie para requests autenticados
  static Map<String, String> getAuthHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_sessionCookie != null) {
      headers['Cookie'] = _sessionCookie!;
      print('🔐 Enviando cookie en headers');
    }
    
    return headers;
  }

  static Future<void> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/public/dashboard'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('✅ Conexión exitosa con el servidor');
        final data = json.decode(response.body);
        print('📊 Datos públicos: ${data['message']}');
      } else {
        print('⚠️  Servidor respondió con: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> login(UserLogin userLogin) async {
    try {
      print('🔐 Intentando login para: ${userLogin.correo}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userLogin.toJson()),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response headers: ${response.headers}');

      // ✅ EXTRAER COOKIE DE LA RESPUESTA
      _extractCookieFromResponse(response);

      final responseBody = json.decode(response.body);
      print('📊 Response body: $responseBody');

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          print('✅ Login exitoso');
          return {
            'success': true,
            'message': responseBody['message'],
            'user': responseBody['user'],
          };
        } else {
          print('❌ Login fallido: ${responseBody['message']}');
          return {
            'success': false,
            'message': responseBody['message'],
          };
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error en login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // ✅ EXTRAER COOKIE DE LA RESPUESTA
  static void _extractCookieFromResponse(http.Response response) {
    final cookieHeader = response.headers['set-cookie'];
    if (cookieHeader != null) {
      print('🍪 Cookie recibida: $cookieHeader');
      
      // Extraer la primera cookie (puedes ajustar según tu backend)
      final cookies = cookieHeader.split(';');
      if (cookies.isNotEmpty) {
        setSessionCookie(cookies[0].trim());
      }
    } else {
      print('⚠️  No se recibió cookie en la respuesta');
    }
  }

  // ✅ MÉTODO PARA CERRAR SESIÓN
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_cookie');
      _sessionCookie = null;
      print('✅ Sesión cerrada - cookie eliminada');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
    }
  }

  // ✅ INICIALIZAR COOKIE AL INICIAR LA APP
  static Future<void> initialize() async {
    await _loadCookieFromPrefs();
    if (_sessionCookie != null) {
      print('🔑 Cookie de sesión inicializada');
    }
  }
}

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