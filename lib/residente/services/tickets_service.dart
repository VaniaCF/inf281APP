// lib/residente/services/tickets_service.dart - VERSIÓN CORREGIDA
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Ticket {
  final int idTicket;
  final String descripcion;
  final String prioridad;
  final String estado;
  final String? fechaEmision;
  final String? fechaFinalizacion;
  final String piso;
  final String nroDepartamento;
  final String empleadoNombre;
  final String areaNombre;

  Ticket({
    required this.idTicket,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
    this.fechaEmision,
    this.fechaFinalizacion,
    required this.piso,
    required this.nroDepartamento,
    required this.empleadoNombre,
    required this.areaNombre,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      idTicket: json['id_ticket'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      prioridad: json['prioridad'] ?? 'media',
      estado: json['estado'] ?? 'abierto',
      fechaEmision: json['fecha_emision'],
      fechaFinalizacion: json['fecha_finalizacion'],
      piso: json['piso'] ?? '',
      nroDepartamento: json['nro_departamento'] ?? '',
      empleadoNombre: json['empleado_nombre'] ?? 'No asignado',
      areaNombre: json['area_nombre'] ?? 'General',
    );
  }

  String get estadoTexto {
    switch (estado) {
      case 'abierto':
        return 'Abierto';
      case 'en_progreso':
        return 'En Progreso';
      case 'cerrado':
        return 'Cerrado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  String get prioridadTexto {
    switch (prioridad) {
      case 'baja':
        return 'Baja';
      case 'media':
        return 'Media';
      case 'alta':
        return 'Alta';
      case 'urgente':
        return 'Urgente';
      default:
        return prioridad;
    }
  }

  String get iconoPrioridad {
    switch (prioridad) {
      case 'baja':
        return '📗';
      case 'media':
        return '📘';
      case 'alta':
        return '📙';
      case 'urgente':
        return '📕';
      default:
        return '📋';
    }
  }

  String get iconoEstado {
    switch (estado) {
      case 'abierto':
        return '🟡';
      case 'en_progreso':
        return '🔵';
      case 'cerrado':
        return '🟢';
      case 'cancelado':
        return '🔴';
      default:
        return '⚪';
    }
  }
}

class TicketDetalle {
  final int idTicket;
  final String descripcion;
  final String prioridad;
  final String estado;
  final String? fechaEmision;
  final String? fechaFinalizacion;
  final String piso;
  final String nroDepartamento;
  final String? empleadoAsignado;
  final String areaNombre;
  final String? areaDescripcion;
  final List<Comentario> comentarios;

  TicketDetalle({
    required this.idTicket,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
    this.fechaEmision,
    this.fechaFinalizacion,
    required this.piso,
    required this.nroDepartamento,
    this.empleadoAsignado,
    required this.areaNombre,
    this.areaDescripcion,
    required this.comentarios,
  });

  factory TicketDetalle.fromJson(Map<String, dynamic> json) {
    var comentariosList = json['comentarios'] as List? ?? [];
    List<Comentario> comentarios = comentariosList
        .map((comentario) => Comentario.fromJson(comentario))
        .toList();

    return TicketDetalle(
      idTicket: json['id_ticket'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      prioridad: json['prioridad'] ?? 'media',
      estado: json['estado'] ?? 'abierto',
      fechaEmision: json['fecha_emision'],
      fechaFinalizacion: json['fecha_finalizacion'],
      piso: json['piso'] ?? '',
      nroDepartamento: json['nro_departamento'] ?? '',
      empleadoAsignado: json['empleado_asignado'],
      areaNombre: json['area_nombre'] ?? 'General',
      areaDescripcion: json['area_descripcion'],
      comentarios: comentarios,
    );
  }
}

class Comentario {
  final String mensaje;
  final String fecha;
  final String autor;
  final bool esInterno;

  Comentario({
    required this.mensaje,
    required this.fecha,
    required this.autor,
    required this.esInterno,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      mensaje: json['mensaje'] ?? '',
      fecha: json['fecha'] ?? '',
      autor: json['autor'] ?? '',
      esInterno: json['es_interno'] ?? false,
    );
  }
}

class Area {
  final int idArea;
  final String nombre;
  final String descripcion;

  Area({
    required this.idArea,
    required this.nombre,
    required this.descripcion,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      idArea: json['id_area'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }
}

class EstadisticasTickets {
  final int total;
  final int abiertos;
  final int enProgreso;
  final int cerrados;
  final int urgentes;

  EstadisticasTickets({
    required this.total,
    required this.abiertos,
    required this.enProgreso,
    required this.cerrados,
    required this.urgentes,
  });

  factory EstadisticasTickets.fromJson(Map<String, dynamic> json) {
    return EstadisticasTickets(
      total: json['total'] ?? 0,
      abiertos: json['abiertos'] ?? 0,
      enProgreso: json['en_progreso'] ?? 0,
      cerrados: json['cerrados'] ?? 0,
      urgentes: json['urgentes'] ?? 0,
    );
  }
}

class TicketsService {
  // 🔥 CORREGIDO: Usa la misma URL base que tu reserva_service
  static const String baseUrl = 'http://192.168.0.153:5000/api/movil';
  static const String baseUrlApp = 'http://192.168.0.153:5000';

  // ===== MÉTODOS DE DIAGNÓSTICO (COPIADOS DE RESERVA_SERVICE) =====

  static Future<void> diagnosticarConexionTickets() async {
    print('🎫 INICIANDO DIAGNÓSTICO TICKETS SERVICE...');

    // 1. Verificar token
    await _diagnosticarToken();

    // 2. Probar conexión básica
    await _probarConexionBasica();

    // 3. Probar endpoint de debug
    await _probarDebugEndpoint();

    // 4. Probar obtención de tickets
    await _probarObtencionTickets();
  }

  static Future<void> _diagnosticarToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    print('🔐 [TICKETS DIAG] Token diagnóstico:');
    print('   • Presente: ${token != null ? "SÍ" : "NO"}');
    if (token != null) {
      print('   • Longitud: ${token.length} caracteres');
      print('   • Inicio: ${token.substring(0, min(30, token.length))}...');
    }

    final keys = prefs
        .getKeys()
        .where((key) => key.contains('token') || key.contains('auth'))
        .toList();
    print('   • Keys relevantes: $keys');
  }

  static Future<void> _probarConexionBasica() async {
    try {
      final testUrl = '$baseUrl/debug';
      print('🔍 [TICKETS DIAG] Probando: $testUrl');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(testUrl),
        headers: headers,
      );

      print('📊 [TICKETS DIAG] Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ [TICKETS DIAG] Debug endpoint funciona');
        final data = json.decode(response.body);
        print('📦 [TICKETS DIAG] Respuesta: ${data['message']}');
      } else {
        print('❌ [TICKETS DIAG] Debug endpoint falló');
        print('📦 [TICKETS DIAG] Body: ${response.body}');
      }
    } catch (e) {
      print('❌ [TICKETS DIAG] Error en conexión básica: $e');
    }
  }

  static Future<void> _probarDebugEndpoint() async {
    try {
      final testUrl = '$baseUrl/test_conexion';
      print('🔍 [TICKETS DIAG] Probando test_conexion: $testUrl');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(testUrl),
        headers: headers,
      );

      print('📊 [TICKETS DIAG] Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [TICKETS DIAG] Test conexión: ${data['message']}');
        print('👤 [TICKETS DIAG] User ID: ${data['user_id']}');
      }
    } catch (e) {
      print('❌ [TICKETS DIAG] Error test conexión: $e');
    }
  }

  static Future<void> _probarObtencionTickets() async {
    try {
      print('🔍 [TICKETS DIAG] Probando obtención de tickets...');

      final resultado = await obtenerTickets(pagina: 1, porPagina: 5);

      if (resultado['success'] == true) {
        final tickets = resultado['tickets'] as List<Ticket>;
        final estadisticas = resultado['estadisticas'] as EstadisticasTickets;

        print('✅ [TICKETS DIAG] Tickets obtenidos: ${tickets.length}');
        print('📊 [TICKETS DIAG] Estadísticas:');
        print('   • Total: ${estadisticas.total}');
        print('   • Abiertos: ${estadisticas.abiertos}');
        print('   • En progreso: ${estadisticas.enProgreso}');
        print('   • Cerrados: ${estadisticas.cerrados}');
      } else {
        print('❌ [TICKETS DIAG] Error: ${resultado['message']}');
      }
    } catch (e) {
      print('❌ [TICKETS DIAG] Error obteniendo tickets: $e');
    }
  }

  // ===== MÉTODOS PRINCIPALES CORREGIDOS =====

  static Future<Map<String, dynamic>> obtenerTickets({
    int pagina = 1,
    int porPagina = 10,
    String? estado,
    String? prioridad,
  }) async {
    try {
      print('🎫 [TICKETS SERVICE] Obteniendo tickets...');

      final uri = Uri.parse('$baseUrl/tickets').replace(queryParameters: {
        'pagina': pagina.toString(),
        'por_pagina': porPagina.toString(),
        if (estado != null && estado.isNotEmpty) 'estado': estado,
        if (prioridad != null && prioridad.isNotEmpty) 'prioridad': prioridad,
      });

      print('🔍 [TICKETS SERVICE] URL: ${uri.toString()}');

      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      print('📊 [TICKETS SERVICE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [TICKETS SERVICE] Respuesta exitosa');

        if (data['success'] == true) {
          final ticketsList = data['tickets'] as List;
          final tickets =
              ticketsList.map((ticket) => Ticket.fromJson(ticket)).toList();
          final estadisticas =
              EstadisticasTickets.fromJson(data['estadisticas']);
          final paginacion = data['paginacion'];

          return {
            'success': true,
            'tickets': tickets,
            'estadisticas': estadisticas,
            'paginacion': paginacion,
          };
        } else {
          print('❌ [TICKETS SERVICE] Error en respuesta: ${data['message']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Error desconocido',
          };
        }
      } else {
        print('❌ [TICKETS SERVICE] Error HTTP: ${response.statusCode}');
        print('📦 [TICKETS SERVICE] Body: ${response.body}');
        return {
          'success': false,
          'message': 'Error de conexión: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ [TICKETS SERVICE] Error: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> crearTicket({
    required String descripcion,
    required String prioridad,
    int? idArea,
  }) async {
    try {
      print('🎫 [TICKETS SERVICE] Creando ticket...');

      final url = '$baseUrl/tickets';
      final headers = await _getHeaders();

      final body = {
        'descripcion': descripcion,
        'prioridad': prioridad,
        if (idArea != null) 'id_area': idArea,
      };

      print('🔍 [TICKETS SERVICE] URL: $url');
      print('📦 [TICKETS SERVICE] Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('📊 [TICKETS SERVICE] Status: ${response.statusCode}');
      print('📦 [TICKETS SERVICE] Respuesta: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'ticket_id': data['ticket_id'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al crear el ticket',
        };
      }
    } catch (e) {
      print('❌ [TICKETS SERVICE] Error creando ticket: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> obtenerDetalleTicket(int ticketId) async {
    try {
      print('🎫 [TICKETS SERVICE] Obteniendo detalle ticket: $ticketId');

      final url = '$baseUrl/tickets/$ticketId';
      final headers = await _getHeaders();

      print('🔍 [TICKETS SERVICE] URL: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('📊 [TICKETS SERVICE] Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final ticketDetalle = TicketDetalle.fromJson(data['ticket']);
        return {
          'success': true,
          'ticket': ticketDetalle,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener detalles',
        };
      }
    } catch (e) {
      print('❌ [TICKETS SERVICE] Error obteniendo detalle: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> agregarComentario({
    required int ticketId,
    required String comentario,
  }) async {
    try {
      final url = '$baseUrl/tickets/$ticketId/comentarios';
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({'comentario': comentario}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al agregar comentario',
        };
      }
    } catch (e) {
      print('❌ Error agregando comentario: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> cancelarTicket(int ticketId) async {
    try {
      final url = '$baseUrl/tickets/$ticketId/cancelar';
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al cancelar el ticket',
        };
      }
    } catch (e) {
      print('❌ Error cancelando ticket: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> obtenerAreas() async {
    try {
      final url = '$baseUrl/areas';
      final headers = await _getHeaders();

      final response = await http.get(Uri.parse(url), headers: headers);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final areasList = data['areas'] as List;
        final areas = areasList.map((area) => Area.fromJson(area)).toList();

        return {
          'success': true,
          'areas': areas,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener áreas',
        };
      }
    } catch (e) {
      print('❌ Error obteniendo áreas: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final url = '$baseUrl/estadisticas';
      final headers = await _getHeaders();

      final response = await http.get(Uri.parse(url), headers: headers);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final estadisticas = EstadisticasTickets.fromJson(data['estadisticas']);

        return {
          'success': true,
          'estadisticas': estadisticas,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener estadísticas',
        };
      }
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // ===== MÉTODOS DE HEADERS (COPIADOS DE RESERVA_SERVICE) =====

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('auth_token') ?? '';

    print('🔐 [TICKETS HEADERS] Obteniendo headers...');
    print(
        '🔐 [TICKETS HEADERS] Token: ${token.isNotEmpty ? "PRESENTE" : "AUSENTE"}');

    if (token.isEmpty) {
      print('❌ [TICKETS HEADERS] ERROR: No hay token en auth_token');
      throw Exception('No hay token de autenticación disponible');
    }

    if (!token.startsWith('eyJ')) {
      print('❌ [TICKETS HEADERS] ERROR: Token no tiene formato JWT válido');
      throw Exception('Token con formato inválido');
    }

    print('✅ [TICKETS HEADERS] Token válido encontrado');
    print('🔐 [TICKETS HEADERS] Longitud: ${token.length}');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  static int min(int a, int b) => a < b ? a : b;
}
