import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Para Android Studio
  // static const String baseUrl = 'http://localhost:5000/api'; // Para web
  
  static String? token; // Variable para almacenar el token

  // Headers comunes
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  // ========== MÉTODOS DE AUTENTICACIÓN ==========
  
  // Método para login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      
      final data = json.decode(response.body);
      
      // Guardar token si el login es exitoso
      if (response.statusCode == 200 && data['token'] != null) {
        token = data['token'];
        data['success'] = true;
      } else {
        data['success'] = false;
      }
      
      return data;
    } catch (e) {
      return {'error': e.toString(), 'success': false};
    }
  }
  
  // Método para cerrar sesión
  static void logout() {
    token = null;
  }
  
  // Método para verificar si el usuario está autenticado
  static bool isAuthenticated() {
    return token != null;
  }
  
  // ========== MÉTODOS DEL DASHBOARD ==========
  
  // Método para obtener datos del dashboard
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'total_usuarios': 0,
        'total_comunicados': 0,
        'total_pagos': 0,
        'total_reservas': 0,
      };
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }
  
  // ========== MÉTODOS DE USUARIOS ==========
  
  // Método para obtener usuarios
  static Future<List<dynamic>> getUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching usuarios: $e');
    }
  }
  
  // Método para crear usuario
  static Future<Map<String, dynamic>> crearUsuario(Map<String, dynamic> usuarioData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: headers,
        body: json.encode(usuarioData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'error': e.toString(), 'success': false};
    }
  }
  
  // Método para actualizar usuario
  static Future<Map<String, dynamic>> actualizarUsuario(int id, Map<String, dynamic> usuarioData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: headers,
        body: json.encode(usuarioData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'error': e.toString(), 'success': false};
    }
  }
  
  // Método para eliminar usuario
  static Future<bool> eliminarUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // ========== MÉTODOS DE COMUNICADOS ==========
  
  // Método para obtener comunicados
  static Future<List<dynamic>> getComunicados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comunicados'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching comunicados: $e');
    }
  }
  
  // Método para crear comunicados
  static Future<Map<String, dynamic>> crearComunicado(Map<String, dynamic> comunicadoData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comunicados'),
        headers: headers,
        body: json.encode(comunicadoData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'error': e.toString(), 'success': false};
    }
  }
  
  // Método para actualizar comunicado
  static Future<Map<String, dynamic>> actualizarComunicado(int id, Map<String, dynamic> comunicadoData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/comunicados/$id'),
        headers: headers,
        body: json.encode(comunicadoData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'error': e.toString(), 'success': false};
    }
  }
  
  // Método para eliminar comunicado
  static Future<bool> eliminarComunicado(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/comunicados/$id'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // ========== MÉTODOS DE PAGOS ==========
  
  // Método para obtener pagos
  static Future<List<dynamic>> getPagos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pagos'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching pagos: $e');
    }
  }
  
  // ========== MÉTODOS DE RESERVAS ==========
  
  // Método para obtener reservas
  static Future<List<dynamic>> getReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching reservas: $e');
    }
  }
  
  // ========== MÉTODOS DE VERIFICACIÓN ==========
  
  // Método para verificar conexión con el servidor
  // Método para verificar conexión con el servidor
static Future<bool> verificarConexion() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
      headers: headers,
    ).timeout(const Duration(seconds: 5)); // ✅ Corrección aquí
    
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
}