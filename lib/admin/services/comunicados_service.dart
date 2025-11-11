import 'dart:convert';
import 'package:http/http.dart' as http;

class ComunicadosService {
  static const String baseUrl = 'http://192.168.1.12:5000';

  // ✅ TEMPORAL: Usar endpoint público para testing
  Future<List<dynamic>> obtenerComunicados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/public/comunicados'), // ✅ Cambiar a público
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['comunicados'] ?? [];
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar comunicados: $e');
    }
  }
}