// services/pagos_service.dart - VERSIÓN SIMPLIFICADA
import 'dart:convert';
import 'package:http/http.dart' as http;

class Pago {
  final int id;
  final String periodoInicio;
  final String periodoFin;
  final String fechaPago;
  final double monto;
  final String estado;
  final String? metodo;
  final String? nroTransaccion;

  Pago({
    required this.id,
    required this.periodoInicio,
    required this.periodoFin,
    required this.fechaPago,
    required this.monto,
    required this.estado,
    this.metodo,
    this.nroTransaccion,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'] ?? 0,
      periodoInicio: json['periodo_inicio'] ?? '',
      periodoFin: json['periodo_fin'] ?? '',
      fechaPago: json['fecha_pago'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      estado: json['estado'] ?? 'pendiente',
      metodo: json['metodo'],
      nroTransaccion: json['nro_transaccion'],
    );
  }
}

class PagosResponse {
  final List<Pago> pagos;
  final double salarioActual;

  PagosResponse({
    required this.pagos,
    required this.salarioActual,
  });

  factory PagosResponse.fromJson(Map<String, dynamic> json) {
    final pagosData = json['pagos'] as List? ?? [];
    return PagosResponse(
      pagos: pagosData.map((pago) => Pago.fromJson(pago)).toList(),
      salarioActual: (json['salario_actual'] ?? 0).toDouble(),
    );
  }
}

class PagosService {
  final String baseUrl;
  final String token;

  PagosService({required this.baseUrl, required this.token});

  Future<PagosResponse> getPagos() async {
    try {
      final url = Uri.parse('$baseUrl/api/movil/empleado/pagos');

      print('🔄 [PAGOS SERVICE] Solicitando pagos...');
      print('📍 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      print('📡 [PAGOS SERVICE] Respuesta recibida:');
      print('   Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          print('✅ [PAGOS SERVICE] Pagos cargados exitosamente');
          return PagosResponse.fromJson(data['data']);
        } else {
          final errorMsg =
              data['error'] ?? data['message'] ?? 'Error desconocido';
          print('❌ [PAGOS SERVICE] Error del servidor: $errorMsg');
          throw Exception('Error del servidor: $errorMsg');
        }
      } else if (response.statusCode == 401) {
        print('❌ [PAGOS SERVICE] Token inválido o expirado');
        throw Exception('Token inválido o expirado');
      } else if (response.statusCode == 404) {
        print('❌ [PAGOS SERVICE] Ruta no encontrada (404)');
        throw Exception('Servicio no disponible');
      } else {
        print('❌ [PAGOS SERVICE] Error HTTP: ${response.statusCode}');
        throw Exception('Error de conexión: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PAGOS SERVICE] Excepción: $e');
      rethrow;
    }
  }
}
