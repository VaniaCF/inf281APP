import 'dart:convert';
import 'package:http/http.dart' as http;

// ✅ MOVER LA CLASE COMUNICADO AL PRINCIPIO
class Comunicado {
  final int idComunicado;
  final String titulo;
  final String contenido;
  final String fechaPublicacion;

  Comunicado({
    required this.idComunicado,
    required this.titulo,
    required this.contenido,
    required this.fechaPublicacion,
  });

  factory Comunicado.fromJson(Map<String, dynamic> json) {
    return Comunicado(
      idComunicado: json['id_comunicado'] ?? 0,
      titulo: json['titulo'] ?? 'Sin título',
      contenido: json['contenido'] ?? 'Sin contenido',
      fechaPublicacion: json['fecha_publicacion'] ?? 'Fecha no disponible',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'contenido': contenido,
    };
  }
}

// ✅ AHORA SÍ DEFINIR EL SERVICE
class ComunicadosService {
  final String baseUrl = 'http://192.168.1.12:5000'; 
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Agregar token de autenticación si es necesario
  void _setAuthToken(String? token) {
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<List<Comunicado>> obtenerComunicados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/api/comunicados'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Comunicado.fromJson(json)).toList();
        } else {
          throw Exception('Error del servidor: ${responseData['error']}');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Acceso no autorizado. Verifica tus permisos.');
      } else {
        throw Exception('Error al cargar comunicados: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerComunicados: $e');
      throw Exception('No se pudieron cargar los comunicados: $e');
    }
  }

  Future<Comunicado> crearComunicado({
    required String titulo,
    required String contenido,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/api/comunicados'),
        headers: headers,
        body: json.encode({
          'titulo': titulo,
          'contenido': contenido,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          return Comunicado(
            idComunicado: responseData['id_comunicado'] ?? 0,
            titulo: titulo,
            contenido: contenido,
            fechaPublicacion: DateTime.now().toString(),
          );
        } else {
          throw Exception('Error del servidor: ${responseData['error']}');
        }
      } else if (response.statusCode == 400) {
        throw Exception('Datos inválidos: título y contenido son requeridos');
      } else if (response.statusCode == 403) {
        throw Exception('Acceso no autorizado. Verifica tus permisos.');
      } else {
        throw Exception('Error al crear comunicado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en crearComunicado: $e');
      throw Exception('No se pudo crear el comunicado: $e');
    }
  }

  Future<void> eliminarComunicado(int idComunicado) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      print('Comunicado $idComunicado eliminado (simulado)');
    } catch (e) {
      print('Error en eliminarComunicado: $e');
      throw Exception('No se pudo eliminar el comunicado: $e');
    }
  }

  Future<Comunicado> actualizarComunicado({
    required int idComunicado,
    required String titulo,
    required String contenido,
  }) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      return Comunicado(
        idComunicado: idComunicado,
        titulo: titulo,
        contenido: contenido,
        fechaPublicacion: DateTime.now().toString(),
      );
    } catch (e) {
      print('Error en actualizarComunicado: $e');
      throw Exception('No se pudo actualizar el comunicado: $e');
    }
  }

  // Método para probar la conexión
  Future<bool> probarConexion() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error probando conexión: $e');
      return false;
    }
  }
}