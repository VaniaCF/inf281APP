// lib/residente/services/reservas_service.dart - VERSIÓN COMPLETA CORREGIDA
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ReservaService {
  static const String baseUrl = 'http://192.168.0.153:5000/residentemovil';
  static const String baseUrlApp = 'http://192.168.0.153:5000';
  static final ImagePicker _imagePicker = ImagePicker();

  // ===== MÉTODOS DE LIMPIEZA Y DIAGNÓSTICO MEJORADOS =====

  static Future<void> limpiarTokensDuplicados() async {
    final prefs = await SharedPreferences.getInstance();

    print('🧹 LIMPIANDO TOKENS DUPLICADOS...');

    final authToken = prefs.getString('auth_token');
    final oldToken = prefs.getString('token');

    print('   • auth_token: ${authToken != null ? "PRESENTE" : "AUSENTE"}');
    print('   • token: ${oldToken != null ? "PRESENTE" : "AUSENTE"}');

    if (authToken != null && oldToken != null) {
      await prefs.remove('token');
      print('✅ Token antiguo "token" eliminado, manteniendo "auth_token"');
    } else if (oldToken != null && authToken == null) {
      await prefs.setString('auth_token', oldToken);
      await prefs.remove('token');
      print('✅ Token migrado de "token" a "auth_token"');
    }

    final finalAuthToken = prefs.getString('auth_token');
    final finalOldToken = prefs.getString('token');

    print('🎯 ESTADO FINAL:');
    print(
        '   • auth_token: ${finalAuthToken != null ? "PRESENTE" : "AUSENTE"}');
    print('   • token: ${finalOldToken != null ? "PRESENTE" : "AUSENTE"}');
  }

  // ===== MÉTODOS DE DIAGNÓSTICO JWT MEJORADOS =====

  static Future<Map<String, dynamic>> debugToken(String token) async {
    try {
      final url = '$baseUrlApp/api/auth/debug_token';
      print('🔍 [TOKEN DEBUG] Enviando token para diagnóstico...');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token}),
      );

      print('🔍 [TOKEN DEBUG] Status: ${response.statusCode}');
      print('🔍 [TOKEN DEBUG] Respuesta: ${response.body}');

      return json.decode(response.body);
    } catch (error) {
      print('❌ [TOKEN DEBUG] Error: $error');
      return {'success': false, 'message': 'Error: $error'};
    }
  }

  // 🔥 NUEVO MÉTODO: Probar token manualmente
  static Future<void> probarTokenManual() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('❌ No hay token disponible');
        return;
      }

      print('🔍 [TOKEN MANUAL] Probando token con endpoint manual...');

      final response = await http.post(
        Uri.parse('http://192.168.0.153:5000/api/auth/verify_token_manual'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token}),
      );

      print('🔍 [TOKEN MANUAL] Status: ${response.statusCode}');
      print('🔍 [TOKEN MANUAL] Respuesta: ${response.body}');
    } catch (error) {
      print('❌ [TOKEN MANUAL] Error: $error');
    }
  }

  static Future<void> pruebaResidentemovilCompleta() async {
    print('\n🎯 INICIANDO PRUEBA RESIDENTEMOVIL COMPLETA\n');

    // 1. Probar debug JWT en residentemovil
    print('1. 🔐 Probando debug JWT en residentemovil...');
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.153:5000/residentemovil/api/debug_jwt'),
        headers: await _getHeaders(),
      );
      print('   📥 Status: ${response.statusCode}');
      print('   📥 Respuesta: ${response.body}');
    } catch (e) {
      print('   ❌ Error: $e');
    }

    // 2. Probar áreas disponibles
    print('2. 🏢 Probando áreas disponibles...');
    try {
      final areas = await obtenerAreasDisponibles();
      print('   ✅ Áreas obtenidas: ${areas.length}');
    } catch (e) {
      print('   ❌ Error áreas: $e');
    }

    // 3. Probar reservas
    print('3. 📋 Probando mis reservas...');
    try {
      final reservas = await obtenerMisReservas();
      print('   ✅ Reservas obtenidas: ${reservas.length}');
    } catch (e) {
      print('   ❌ Error reservas: $e');
    }

    print('\n🎯 PRUEBA COMPLETADA\n');
  }

  static Future<Map<String, dynamic>> testGenerateToken() async {
    try {
      final url = '$baseUrlApp/api/auth/test_generate';
      print('🔧 [TEST GENERATE] Solicitando token de prueba...');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': 3}),
      );

      print('🔧 [TEST GENERATE] Status: ${response.statusCode}');
      print('🔧 [TEST GENERATE] Respuesta: ${response.body}');

      return json.decode(response.body);
    } catch (error) {
      print('❌ [TEST GENERATE] Error: $error');
      return {'success': false, 'message': 'Error: $error'};
    }
  }

  // 🔥 NUEVO MÉTODO: Probar diagnóstico JWT
  static Future<Map<String, dynamic>> probarDiagnosticoJWT() async {
    try {
      final url = '$baseUrlApp/api/auth/diagnostico_jwt';
      final headers = await _getHeaders();

      print('🔐 [DIAGNÓSTICO JWT] Probando endpoint...');
      print(
          '🔐 [DIAGNÓSTICO JWT] Headers: ${headers.containsKey('Authorization')}');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔐 [DIAGNÓSTICO JWT] Status: ${response.statusCode}');
      print('🔐 [DIAGNÓSTICO JWT] Respuesta: ${response.body}');

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        print('✅ [DIAGNÓSTICO JWT] JWT FUNCIONANDO CORRECTAMENTE');
        return {'success': true, 'data': result};
      } else {
        print('❌ [DIAGNÓSTICO JWT] JWT FALLANDO: ${result['message']}');
        return {'success': false, 'message': result['message']};
      }
    } catch (error) {
      print('❌ [DIAGNÓSTICO JWT] Error: $error');
      return {'success': false, 'message': 'Error: $error'};
    }
  }

  // 🔥 NUEVO MÉTODO: Prueba JWT completa
  static Future<void> pruebaJWTCompleta() async {
    print('\n🎯 INICIANDO PRUEBA JWT COMPLETA\n');

    // 1. Limpiar tokens
    print('1. 🧹 Limpiando tokens duplicados...');
    await limpiarTokensDuplicados();

    // 2. Diagnosticar token actual
    print('2. 🔍 Diagnosticando token actual...');
    await diagnosticarToken();

    // 3. Probar diagnóstico JWT en app principal
    print('3. 🔐 Probando JWT en app principal...');
    final diagnostico = await probarDiagnosticoJWT();
    print(
        '   ✅ Resultado: ${diagnostico['success'] == true ? "ÉXITO" : "FALLÓ"}');
    if (diagnostico['success'] == true) {
      print('   🔐 User ID: ${diagnostico['data']['user_id']}');
    }

    // 4. Probar blueprint residentemovil
    print('4. 🔐 Probando JWT en residentemovil...');
    final testBlueprint = await testConexion();
    print(
        '   ✅ Resultado: ${testBlueprint['success'] == true ? "ÉXITO" : "FALLÓ"}');

    // 5. Probar áreas disponibles
    print('5. 🏢 Probando áreas disponibles...');
    try {
      final areas = await obtenerAreasDisponibles();
      print('   ✅ Áreas obtenidas: ${areas.length}');
    } catch (e) {
      print('   ❌ Error áreas: $e');
    }

    print('\n🎯 PRUEBA JWT COMPLETADA\n');
  }

  // 🔥 NUEVO MÉTODO: Prueba completa de diagnóstico
  static Future<void> pruebaDiagnosticoCompleto() async {
    print('\n🔧 INICIANDO DIAGNÓSTICO COMPLETO\n');

    // 1. Limpiar tokens
    await limpiarTokensDuplicados();

    // 2. Diagnosticar token local
    await diagnosticarToken();

    // 3. Probar token manualmente
    print('3. 🔍 Probando token manualmente...');
    await probarTokenManual();

    // 4. Probar residentemovil
    print('4. 🔐 Probando residentemovil...');
    await pruebaResidentemovilCompleta();

    print('\n🔧 DIAGNÓSTICO COMPLETADO\n');
  }

  static Future<Map<String, dynamic>> verificarTokenConServidor() async {
    try {
      final url = '$baseUrlApp/api/auth/verify';
      final headers = await _getHeaders();

      print('🔍 [TOKEN VERIFY] Verificando token con servidor...');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔍 [TOKEN VERIFY] Status: ${response.statusCode}');
      print('🔍 [TOKEN VERIFY] Respuesta: ${response.body}');

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        print('✅ [TOKEN VERIFY] Token VÁLIDO en servidor');
        return {'valid': true, 'user': result['user']};
      } else {
        print(
            '❌ [TOKEN VERIFY] Token INVÁLIDO en servidor: ${result['message']}');
        return {'valid': false, 'message': result['message']};
      }
    } catch (error) {
      print('❌ [TOKEN VERIFY] Error verificando token: $error');
      return {'valid': false, 'message': 'Error de conexión: $error'};
    }
  }

  static Future<void> debugCompleto() async {
    print('\n🐛 INICIANDO DEBUG COMPLETO\n');
    await limpiarTokensDuplicados();
    await diagnosticarToken();
    await verificarTokenConServidor();
    print('\n🐛 DEBUG COMPLETADO\n');
  }

  // ===== MÉTODOS PARA IMAGENES =====
  static Future<XFile?> seleccionarImagen() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image;
    } catch (error) {
      throw Exception('Error al seleccionar imagen: $error');
    }
  }

  static Future<XFile?> tomarFoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image;
    } catch (error) {
      throw Exception('Error al tomar foto: $error');
    }
  }

  // ===== MÉTODOS DE DIAGNÓSTICO =====
  static Future<void> diagnosticarToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    print('\n🔍 DIAGNÓSTICO DE TOKEN:');
    print('   • Token presente: ${token != null ? "SÍ" : "NO"}');
    if (token != null) {
      print('   • Longitud: ${token.length} caracteres');
      print(
          '   • Primeros 20 chars: ${token.substring(0, min(20, token.length))}...');
    }

    final keys = prefs.getKeys();
    print('   • Keys en SharedPreferences: $keys');

    for (var key in keys) {
      if (key.contains('token') ||
          key.contains('auth') ||
          key.contains('user')) {
        final value = prefs.get(key);
        print('   • $key: ${value != null ? "PRESENTE" : "AUSENTE"}');
        if (value != null && value is String) {
          print(
              '     Valor: ${value.length > 50 ? value.substring(0, 50) + "..." : value}');
        }
      }
    }

    print('🔍 DIAGNÓSTICO COMPLETADO\n');
  }

  static Future<void> guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('token');
    await prefs.setString('auth_token', token);
    print('💾 Token guardado: ${token.length} caracteres');

    final tokenGuardado = prefs.getString('auth_token');
    print(
        '🔍 Verificación - Token después de guardar: ${tokenGuardado != null ? "PRESENTE" : "AUSENTE"}');
  }

  // ===== HEADERS CON JWT MEJORADOS =====
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('auth_token') ?? '';

    print('🔐 [JWT HEADERS] Iniciando obtención de headers...');
    print(
        '🔐 [JWT HEADERS] auth_token: ${token.isNotEmpty ? "PRESENTE" : "AUSENTE"}');

    if (token.isEmpty) {
      print('❌ [JWT HEADERS] ERROR: No hay token en auth_token');
      print('🔍 [JWT HEADERS] Todas las keys: ${prefs.getKeys()}');

      final oldToken = prefs.getString('token');
      if (oldToken != null) {
        print('🔄 [JWT HEADERS] Token encontrado en key antigua, migrando...');
        await prefs.setString('auth_token', oldToken);
        await prefs.remove('token');
        token = oldToken;
        print('✅ [JWT HEADERS] Token migrado exitosamente');
      } else {
        throw Exception(
            'No hay token de autenticación disponible. Por favor, inicia sesión nuevamente.');
      }
    }

    if (!token.startsWith('eyJ')) {
      print('❌ [JWT HEADERS] ERROR: Token no tiene formato JWT válido');
      print('🔍 [JWT HEADERS] Token: $token');
      throw Exception('Token con formato inválido');
    }

    print('✅ [JWT HEADERS] Token válido encontrado');
    print('🔐 [JWT HEADERS] Longitud: ${token.length}');
    print(
        '🔐 [JWT HEADERS] Inicio: ${token.substring(0, min(50, token.length))}...');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // ===== MÉTODOS PRINCIPALES CORREGIDOS =====

  static Future<Map<String, dynamic>> procesarReservaConBoucher({
    required String area,
    required String nombreArea,
    required String fecha,
    required double monto,
    required int horas,
    required XFile boucher,
  }) async {
    try {
      final url = '$baseUrl/api/procesar_reserva';
      print('🔄 [FLUTTER] Enviando reserva con boucher a: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      final headers = await _getHeaders();
      if (headers.containsKey('Authorization')) {
        request.headers['Authorization'] = headers['Authorization']!;
      }
      request.headers['Accept'] = 'application/json';

      request.fields.addAll({
        'area': area,
        'nombre_area': nombreArea,
        'fecha': fecha,
        'monto': monto.toString(),
        'metodo_pago': 'qr',
        'horas': horas.toString(),
      });

      print('📦 [FLUTTER] Campos: ${request.fields}');

      final File boucherFile = File(boucher.path);
      request.files.add(await http.MultipartFile.fromPath(
          'boucher', boucherFile.path,
          filename: 'boucher_${DateTime.now().millisecondsSinceEpoch}.jpg'));

      print('📤 [FLUTTER] Enviando request multipart...');

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var result = json.decode(responseData);

      print('✅ [FLUTTER] Status: ${response.statusCode}');
      print('✅ [FLUTTER] Respuesta: $result');

      return result;
    } catch (error) {
      print('❌ [FLUTTER] Error procesando reserva: $error');
      throw Exception('Error al procesar reserva: $error');
    }
  }

  static Future<Map<String, dynamic>> procesarReservaFacturacion({
    required String area,
    required String nombreArea,
    required String fecha,
    required double monto,
    required int horas,
    required String ci,
    required String nombre,
    required String departamento,
    required String metodoPago,
    required String comprobante,
  }) async {
    try {
      final url = '$baseUrl/api/procesar_reserva';
      final headers = await _getHeaders();

      print('🔄 [FLUTTER] Enviando reserva con facturación a: $url');
      print(
          '🔐 [FLUTTER] Headers con JWT: ${headers.containsKey('Authorization')}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          'area': area,
          'nombre_area': nombreArea,
          'fecha': fecha,
          'monto': monto,
          'horas': horas,
          'ci': ci,
          'nombre': nombre,
          'departamento': departamento,
          'metodo_pago': metodoPago,
          'comprobante': comprobante,
        }),
      );

      print('📥 [FLUTTER] Status: ${response.statusCode}');
      print('📥 [FLUTTER] Respuesta: ${response.body}');

      return json.decode(response.body);
    } catch (error) {
      print('❌ [FLUTTER] Error procesando facturación: $error');
      throw Exception('Error al procesar facturación: $error');
    }
  }

  static Future<List<dynamic>> obtenerMisReservas() async {
    try {
      final url = '$baseUrl/api/mis_reservas';
      final headers = await _getHeaders();

      print('🔄 [FLUTTER] Obteniendo reservas de: $url');
      print(
          '🔐 [FLUTTER] Headers con JWT: ${headers.containsKey('Authorization')}');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📥 [FLUTTER] Status: ${response.statusCode}');
      print('📥 [FLUTTER] Respuesta: ${response.body}');

      final result = json.decode(response.body);

      if (response.statusCode == 401 || response.statusCode == 422) {
        print('❌ [FLUTTER] Error de autenticación: ${result['message']}');
        throw Exception('Token inválido o expirado: ${result['message']}');
      }

      if (result['success'] == true) {
        return result['reservas'] ?? [];
      } else {
        throw Exception(result['message'] ?? 'Error desconocido');
      }
    } catch (error) {
      print('❌ [FLUTTER] Error obteniendo reservas: $error');
      rethrow;
    }
  }

  static Future<List<dynamic>> obtenerAreasDisponibles() async {
    try {
      final url = '$baseUrl/api/areas_disponibles';
      final headers = await _getHeaders();

      print('🔄 [FLUTTER] Obteniendo áreas de: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📥 [FLUTTER] Status: ${response.statusCode}');
      print('📥 [FLUTTER] Respuesta: ${response.body}');

      final result = json.decode(response.body);

      if (response.statusCode == 401 || response.statusCode == 422) {
        print('❌ [FLUTTER] Error de autenticación: ${result['message']}');
        throw Exception('Token inválido o expirado: ${result['message']}');
      }

      if (result['success'] == true) {
        return result['areas'] ?? [];
      } else {
        throw Exception(result['message'] ?? 'Error obteniendo áreas');
      }
    } catch (error) {
      print('❌ [FLUTTER] Error obteniendo áreas: $error');
      return _getAreasPorDefecto();
    }
  }

  static Future<Map<String, dynamic>> generarFactura(String pagoId) async {
    try {
      final url = '$baseUrl/api/generar_factura/$pagoId';
      final headers = await _getHeaders();

      print('🔄 [FLUTTER] Generando factura para: $pagoId');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return json.decode(response.body);
    } catch (error) {
      print('❌ [FLUTTER] Error generando factura: $error');
      throw Exception('Error al generar factura: $error');
    }
  }

  static Future<Map<String, dynamic>> obtenerHorariosAreas() async {
    try {
      final url = '$baseUrl/api/horarios_areas';
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return json.decode(response.body);
    } catch (error) {
      print('❌ [FLUTTER] Error obteniendo horarios: $error');
      return {'success': true, 'horarios': getHorariosAreas()};
    }
  }

  // ===== MÉTODOS DE PRUEBA Y DIAGNÓSTICO MEJORADOS =====

  static Future<Map<String, dynamic>> testConexion() async {
    try {
      final url = '$baseUrl/api/test_conexion';
      final headers = await _getHeaders();

      print('🔐 [JWT TEST] Probando conexión a: $url');
      print(
          '🔐 [JWT TEST] Token presente: ${headers.containsKey('Authorization')}');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔐 [JWT TEST] Status: ${response.statusCode}');
      print('🔐 [JWT TEST] Respuesta: ${response.body}');

      final result = json.decode(response.body);

      if (response.statusCode == 401 || response.statusCode == 422) {
        return {
          'success': false,
          'message': 'Error de autenticación: ${result['message']}',
          'error': 'AUTH_ERROR'
        };
      }

      return result;
    } catch (error) {
      print('❌ [JWT TEST] Error: $error');
      return {
        'success': false,
        'message': 'Error de conexión: $error',
        'error': error.toString()
      };
    }
  }
// Agrega esto al final de tu ReservaService en reservas_service.dart

// Agrega esto al final de tu ReservaService en reservas_service.dart

// 🔧 MÉTODO PARA PROBAR CONFIGURACIÓN JWT
  static Future<void> probarConfiguracionJWT() async {
    try {
      print('🔧 [CONFIG TEST] Probando configuración JWT...');

      final response = await http.get(
        Uri.parse('http://192.168.0.153:5000/api/auth/debug_jwt_config'),
      );

      print('🔧 [CONFIG TEST] Status: ${response.statusCode}');
      print('🔧 [CONFIG TEST] Respuesta: ${response.body}');

      final result = json.decode(response.body);
      if (result['success'] == true) {
        print('✅ [CONFIG TEST] Configuración JWT obtenida:');
        print('   - Secret Key: ${result['jwt_config']['JWT_SECRET_KEY']}');
        print('   - Algorithm: ${result['jwt_config']['JWT_ALGORITHM']}');
        print('   - Blueprints: ${result['total_blueprints']}');

        // Mostrar blueprints registrados
        if (result['blueprints_registered'] != null) {
          print('   📋 Blueprints encontrados:');
          for (var bp in result['blueprints_registered']) {
            print('      • ${bp['name']} -> ${bp['url_prefix']}');
          }
        }
      } else {
        print('❌ [CONFIG TEST] Error: ${result['message']}');
      }
    } catch (error) {
      print('❌ [CONFIG TEST] Error: $error');
    }
  }

  static Future<void> probarDebugTokenDetallado() async {
    try {
      final url =
          'http://192.168.0.153:5000/residentemovil/api/debug_token_detallado';
      final headers = await _getHeaders();

      print('🔍 [DEBUG DETALLADO] Probando...');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔍 [DEBUG DETALLADO] Status: ${response.statusCode}');
      print('🔍 [DEBUG DETALLADO] Respuesta: ${response.body}');

      final result = json.decode(response.body);
      if (result['success'] == true) {
        print('✅ TOKEN VÁLIDO EN RESIDENTEMOVIL');
        print('   📋 User ID locations:');
        print('      - sub: ${result['user_id_locations']['sub']}');
        print('      - identity: ${result['user_id_locations']['identity']}');
        print('      - user_id: ${result['user_id_locations']['user_id']}');
        print('   🔑 Todas las keys: ${result['all_keys']}');
      } else {
        print('❌ ERROR: ${result['message']}');
      }
    } catch (error) {
      print('❌ [DEBUG DETALLADO] Error: $error');
    }
  }

  static Future<Map<String, dynamic>> testPublico() async {
    try {
      final url = '$baseUrl/api/public/test';
      print('🌐 [PUBLIC TEST] Probando endpoint público: $url');

      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);

      print('🌐 [PUBLIC TEST] Resultado: $result');
      return result;
    } catch (error) {
      print('❌ [PUBLIC TEST] Error: $error');
      return {'success': false, 'message': 'Error de conexión: $error'};
    }
  }

  static Future<void> probarDebugTokenFormato() async {
    try {
      final url =
          'http://192.168.0.153:5000/residentemovil/api/debug_token_formato';
      final headers = await _getHeaders();

      print('🔍 [DEBUG FORMATO] Probando formato de token...');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔍 [DEBUG FORMATO] Status: ${response.statusCode}');
      print('🔍 [DEBUG FORMATO] Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ FORMATO DE TOKEN IDENTIFICADO:');
        print('   🎯 User ID: ${result['user_id_location']}');
        print('   📋 Todos los campos: ${result['all_fields']}');
        print('   🔑 Secret key match: ${result['secret_key_match']}');
      }
    } catch (error) {
      print('❌ [DEBUG FORMATO] Error: $error');
    }
  }
  // ===== MÉTODOS LOCALES/UTILITARIOS =====

  static Map<String, String> getHorariosAreas() {
    return {
      'salon': 'Lunes a Domingo: 8:00 - 22:00',
      'piscina': 'Martes a Domingo: 9:00 - 19:00',
      'gimnasio': 'Lunes a Sábado: 6:00 - 22:00',
      'parqueo': 'Todos los días: 24 horas',
    };
  }

  static bool validarFecha(String area, DateTime fecha) {
    final diaSemana = fecha.weekday;
    switch (area) {
      case 'piscina':
        return diaSemana != DateTime.monday;
      case 'gimnasio':
        return diaSemana != DateTime.sunday;
      default:
        return true;
    }
  }

  static String getMensajeValidacionFecha(String area, DateTime fecha) {
    final diaSemana = fecha.weekday;
    switch (area) {
      case 'piscina':
        if (diaSemana == DateTime.monday) {
          return '❌ La piscina no está disponible los Lunes';
        }
        break;
      case 'gimnasio':
        if (diaSemana == DateTime.sunday) {
          return '❌ El gimnasio no está disponible los Domingos';
        }
        break;
    }
    return '✅ Fecha disponible';
  }

  static double calcularPrecioTotal(String areaId, int horas) {
    switch (areaId) {
      case 'salon':
        return 350.00;
      case 'piscina':
        return 200.00;
      case 'gimnasio':
        return 25.00 * horas;
      case 'parqueo':
        return 10.00;
      default:
        return 0.00;
    }
  }

  static String formatearPrecio(String areaId, int horas) {
    switch (areaId) {
      case 'salon':
        return '350 Bs';
      case 'piscina':
        return '200 Bs';
      case 'gimnasio':
        return '${25 * horas} Bs (${horas}h)';
      case 'parqueo':
        return '10 Bs/día';
      default:
        return '0 Bs';
    }
  }

  static String getIconoArea(String areaId) {
    switch (areaId) {
      case 'salon':
        return 'celebration';
      case 'piscina':
        return 'pool';
      case 'gimnasio':
        return 'fitness_center';
      case 'parqueo':
        return 'local_parking';
      default:
        return 'place';
    }
  }

  static int getColorArea(String areaId) {
    switch (areaId) {
      case 'salon':
        return 0xFF264653;
      case 'piscina':
        return 0xFF2A9D8F;
      case 'gimnasio':
        return 0xFFE9C46A;
      case 'parqueo':
        return 0xFFF4A261;
      default:
        return 0xFF264653;
    }
  }
// Agrega esto al final de tu ReservaService en reservas_service.dart

  // ===== MÉTODOS PRIVADOS/HELPERS =====

  static List<dynamic> _getAreasPorDefecto() {
    return [
      {
        'id': 'salon',
        'nombre': 'Salón de Eventos',
        'descripcion':
            'Capacidad: 50 personas. Ideal para celebraciones y reuniones.',
        'precio': 350.00,
        'precio_texto': '350 Bs',
        'horario': 'Lun-Dom: 8:00-22:00',
        'capacidad': 'Máx. 50 personas',
        'disponible': true,
        'icono': 'celebration'
      },
      {
        'id': 'piscina',
        'nombre': 'Piscina',
        'descripcion':
            'Área recreativa con capacidad para 30 personas simultáneamente.',
        'precio': 200.00,
        'precio_texto': '200 Bs',
        'horario': 'Mar-Dom: 9:00-19:00',
        'capacidad': 'Máx. 30 personas',
        'disponible': true,
        'icono': 'pool'
      },
      {
        'id': 'gimnasio',
        'nombre': 'Gimnasio SincroHome',
        'descripcion': 'Equipo completo de ejercicio. Uso por horas.',
        'precio': 25.00,
        'precio_texto': '25 Bs/hora',
        'horario': 'Lun-Sáb: 6:00-22:00',
        'capacidad': 'Máx. 15 personas',
        'disponible': true,
        'icono': 'fitness_center'
      },
      {
        'id': 'parqueo',
        'nombre': 'Parqueo de Visitantes',
        'descripcion': 'Espacios adicionales para visitantes del residente.',
        'precio': 10.00,
        'precio_texto': '10 Bs/día',
        'horario': 'Todos los días: 24h',
        'capacidad': '1 vehículo por reserva',
        'disponible': true,
        'icono': 'local_parking'
      }
    ];
  }

  static int min(int a, int b) => a < b ? a : b;
}
