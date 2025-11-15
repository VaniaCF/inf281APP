// services/perfil_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PerfilEmpleado {
  final int idEmpleado;
  final String puesto;
  final double salario;
  final String fechaContratacion;
  final String? tipoContrato;
  final String? banco;
  final String? numeroCuenta;
  final String? turno;
  final String nombre;
  final String? apPaterno;
  final String? apMaterno;
  final String correo;
  final String? telefono;
  final String? ci;

  PerfilEmpleado({
    required this.idEmpleado,
    required this.puesto,
    required this.salario,
    required this.fechaContratacion,
    this.tipoContrato,
    this.banco,
    this.numeroCuenta,
    this.turno,
    required this.nombre,
    this.apPaterno,
    this.apMaterno,
    required this.correo,
    this.telefono,
    this.ci,
  });

  factory PerfilEmpleado.fromJson(Map<String, dynamic> json) {
    return PerfilEmpleado(
      idEmpleado: json['id_empleado'] ?? 0,
      puesto: json['puesto'] ?? '',
      salario: (json['salario'] ?? 0).toDouble(),
      fechaContratacion: json['fecha_contratacion'] ?? '',
      tipoContrato: json['tipo_contrato'],
      banco: json['banco'],
      numeroCuenta: json['numero_cuenta'],
      turno: json['turno'],
      nombre: json['nombre'] ?? '',
      apPaterno: json['ap_paterno'],
      apMaterno: json['ap_materno'],
      correo: json['correo'] ?? '',
      telefono: json['telefono'],
      ci: json['ci'],
    );
  }

  String get nombreCompleto {
    return '$nombre ${apPaterno ?? ''} ${apMaterno ?? ''}'.trim();
  }
}

class EstadisticasEmpleado {
  final int ticketsCompletados;
  final int mantenimientosRealizados;
  final int ticketsPendientes;

  EstadisticasEmpleado({
    required this.ticketsCompletados,
    required this.mantenimientosRealizados,
    required this.ticketsPendientes,
  });

  factory EstadisticasEmpleado.fromJson(Map<String, dynamic> json) {
    return EstadisticasEmpleado(
      ticketsCompletados: json['tickets_completados'] ?? 0,
      mantenimientosRealizados: json['mantenimientos_realizados'] ?? 0,
      ticketsPendientes: json['tickets_pendientes'] ?? 0,
    );
  }
}

class PerfilResponse {
  final PerfilEmpleado empleado;
  final EstadisticasEmpleado estadisticas;

  PerfilResponse({
    required this.empleado,
    required this.estadisticas,
  });

  factory PerfilResponse.fromJson(Map<String, dynamic> json) {
    return PerfilResponse(
      empleado: PerfilEmpleado.fromJson(json['empleado']),
      estadisticas: EstadisticasEmpleado.fromJson(json['estadisticas']),
    );
  }
}

class PerfilService {
  final String baseUrl;
  final String token;

  PerfilService({required this.baseUrl, required this.token});

  Future<PerfilResponse> getPerfil() async {
    try {
      final url = Uri.parse('$baseUrl/api/movil/empleado/perfil');

      print('🔄 [PERFIL SERVICE] Solicitando perfil...');
      print('📍 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      print('📡 [PERFIL SERVICE] Respuesta recibida:');
      print('   Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          print('✅ [PERFIL SERVICE] Perfil cargado exitosamente');
          return PerfilResponse.fromJson(data['data']);
        } else {
          final errorMsg =
              data['error'] ?? data['message'] ?? 'Error desconocido';
          print('❌ [PERFIL SERVICE] Error del servidor: $errorMsg');
          throw Exception('Error del servidor: $errorMsg');
        }
      } else if (response.statusCode == 401) {
        print('❌ [PERFIL SERVICE] Token inválido o expirado');
        throw Exception('Token inválido o expirado');
      } else if (response.statusCode == 404) {
        print('❌ [PERFIL SERVICE] Ruta no encontrada (404)');
        throw Exception('Servicio no disponible');
      } else {
        print('❌ [PERFIL SERVICE] Error HTTP: ${response.statusCode}');
        throw Exception('Error de conexión: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PERFIL SERVICE] Excepción: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> actualizarPerfil(
      Map<String, dynamic> datos) async {
    try {
      final url = Uri.parse('$baseUrl/api/movil/empleado/perfil/actualizar');

      print('🔄 [PERFIL SERVICE] Actualizando perfil...');

      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(datos),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          print('✅ [PERFIL SERVICE] Perfil actualizado exitosamente');
          return data;
        } else {
          throw Exception(data['error'] ?? 'Error al actualizar perfil');
        }
      } else {
        throw Exception('Error de conexión: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PERFIL SERVICE] Excepción al actualizar: $e');
      rethrow;
    }
  }
}
