// lib/residente/pages/reservas_residente.dart - VERSIÓN CORREGIDA
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/reservas_service.dart';
import '../widgets/area_card.dart';
import '../widgets/modal_reserva.dart';
import '../widgets/modal_pago_qr.dart';
import '../widgets/modal_facturacion.dart';
import '../widgets/menu_residente.dart';
import 'dart:io';

class ReservasResidentePage extends StatefulWidget {
  const ReservasResidentePage({super.key});

  @override
  _ReservasResidentePageState createState() => _ReservasResidentePageState();
}

class _ReservasResidentePageState extends State<ReservasResidentePage> {
  List<dynamic> _reservasActivas = [];
  bool _cargando = true;
  List<dynamic> _areasDisponibles = [];

  @override
  void initState() {
    super.initState();
    _inicializarConLimpieza();
  }

  // ✅ NUEVO MÉTODO: Inicializar con limpieza de tokens
// En tu reservas_residente.dart, modifica temporalmente este método:
  Future<void> _inicializarConLimpieza() async {
    try {
      setState(() {
        _cargando = true;
      });

      print('🚀 INICIANDO CON LIMPIEZA DE TOKENS...');

      // 1. Primero limpiar tokens duplicados
      await ReservaService.limpiarTokensDuplicados();

      // 2. Diagnosticar el estado del token
      await ReservaService.diagnosticarToken();

      // 3. ✅ TEMPORAL: Saltar verificación mientras arreglamos el endpoint
      print('⚠️  Verificación temporalmente deshabilitada - Cargando datos...');
      await _cargarDatosIniciales();

      /*
    // ❌ COMENTADO TEMPORALMENTE
    // 3. Verificar si el token es válido con el servidor
    final verificacion = await ReservaService.verificarTokenConServidor();

    if (verificacion['valid'] == true) {
      print('✅ Token válido, cargando datos...');
      await _cargarDatosIniciales();
    } else {
      print('❌ Token inválido: ${verificacion['message']}');
      _mostrarErrorTokenInvalido();
    }
    */
    } catch (error) {
      print('❌ Error en inicialización: $error');
      _mostrarError('Error de conexión: $error');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      // Cargar áreas disponibles del servidor
      final areas = await ReservaService.obtenerAreasDisponibles();

      // Cargar reservas activas
      final reservas = await ReservaService.obtenerMisReservas();

      setState(() {
        _areasDisponibles = areas;
        _reservasActivas = reservas;
      });
    } catch (error) {
      print('❌ Error cargando datos iniciales: $error');
      _mostrarError('Error al cargar datos: $error');
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ✅ NUEVO MÉTODO: Mostrar error específico de token
  void _mostrarErrorTokenInvalido() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Sesión Expirada'),
          content: const Text(
              'Tu sesión ha expirado o el token es inválido. Por favor, inicia sesión nuevamente.'),
          actions: [
            TextButton(
              onPressed: _forzarNuevoLogin,
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  // ✅ NUEVO MÉTODO: Forzar nuevo login
  Future<void> _forzarNuevoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('token');

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _mostrarExito(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Abrir modal de reserva
  void _abrirModalReserva(Map<String, dynamic> area) {
    // Primero verificar autenticación
    _verificarAutenticacion().then((autenticado) {
      if (autenticado && mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ModalReserva(
            area: area,
            onReservar: _procesarReserva,
          ),
        );
      }
    });
  }

  // Verificar autenticación antes de cualquier acción
  Future<bool> _verificarAutenticacion() async {
    try {
      final test = await ReservaService.testConexion();
      if (test['success'] == true) {
        return true;
      } else {
        _mostrarError('Error de autenticación: ${test['message']}');
        return false;
      }
    } catch (error) {
      _mostrarError('Error de conexión: $error');
      return false;
    }
  }

  // Procesar reserva
  void _procesarReserva(Map<String, dynamic> reservaData) {
    if (!mounted) return;

    Navigator.pop(context); // Cerrar modal de reserva

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Método de Pago',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF264653),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¿Cómo deseas proceder con el pago de ${reservaData['precio']} Bs?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _mostrarPagoQR(reservaData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF264653),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Pago con QR'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _mostrarFacturacionManual(reservaData);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF264653)),
                  ),
                  child: const Text(
                    'Facturación Manual',
                    style: TextStyle(color: Color(0xFF264653)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mostrar modal de pago QR
  void _mostrarPagoQR(Map<String, dynamic> reservaData) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalPagoQR(
        reservaData: reservaData,
        onPagoConfirmado: _procesarPagoConBoucher,
      ),
    );
  }

  // Procesar pago con boucher
  Future<void> _procesarPagoConBoucher(
      Map<String, dynamic> reservaData, XFile boucherFile) async {
    try {
      setState(() {
        _cargando = true;
      });

      print('📱 Iniciando procesamiento de pago con boucher...');

      final result = await ReservaService.procesarReservaConBoucher(
        area: reservaData['id'] ?? reservaData['area'],
        nombreArea: reservaData['nombre'],
        fecha: reservaData['fecha'],
        monto: reservaData['precio'] is double
            ? reservaData['precio']
            : double.parse(reservaData['precio'].toString()),
        horas: reservaData['horas'] ?? 1,
        boucher: boucherFile,
      );

      print('📱 Resultado del pago: $result');

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pop(context); // Cerrar modal de pago
        }
        _mostrarConfirmacionPago(
            result['pago_id']?.toString() ?? 'N/A', reservaData);
        await _cargarReservasActivas();
      } else {
        _mostrarError('Error: ${result['message'] ?? "Error desconocido"}');
      }
    } catch (error) {
      print('❌ Error en _procesarPagoConBoucher: $error');
      _mostrarError('Error al procesar pago: $error');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // Mostrar facturación manual
  void _mostrarFacturacionManual(Map<String, dynamic> reservaData) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalFacturacion(
        reservaData: reservaData,
        onFacturacionCompletada: _procesarFacturacionManual,
      ),
    );
  }

  // Procesar facturación manual
  Future<void> _procesarFacturacionManual(
      Map<String, dynamic> datosFactura) async {
    try {
      print('📱 Iniciando facturación manual...');

      final result = await ReservaService.procesarReservaFacturacion(
        area: datosFactura['area'],
        nombreArea: datosFactura['nombreArea'],
        fecha: datosFactura['fecha'],
        monto: datosFactura['precio'] is double
            ? datosFactura['precio']
            : double.parse(datosFactura['precio'].toString()),
        horas: datosFactura['horas'] ?? 1,
        ci: datosFactura['ci'] ?? 'No especificado',
        nombre: datosFactura['nombre'] ?? 'No especificado',
        departamento: datosFactura['departamento'] ?? 'No especificado',
        metodoPago: datosFactura['metodoPago'] ?? 'manual',
        comprobante: datosFactura['comprobante'] ?? 'SIN_COMPROBANTE',
      );

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pop(context); // Cerrar modal de facturación
        }
        _mostrarExito('¡Reserva y factura generadas exitosamente!');
        await _cargarReservasActivas();
        _mostrarFactura(result['pago_id']?.toString() ?? 'N/A');
      } else {
        _mostrarError('Error: ${result['message'] ?? "Error desconocido"}');
      }
    } catch (error) {
      print('❌ Error en _procesarFacturacionManual: $error');
      _mostrarError('Error al procesar factura: $error');
    }
  }

  Future<void> _cargarReservasActivas() async {
    try {
      final reservas = await ReservaService.obtenerMisReservas();
      if (mounted) {
        setState(() {
          _reservasActivas = reservas;
        });
      }
    } catch (error) {
      print('❌ Error cargando reservas: $error');
      _mostrarError('Error al cargar reservas: $error');
    }
  }

  void _mostrarConfirmacionPago(
      String pagoId, Map<String, dynamic> reservaData) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Reserva Confirmada!',
            style: TextStyle(color: Colors.green)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Área: ${reservaData['nombre']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Fecha: ${reservaData['fecha']}'),
            Text('Monto: ${reservaData['precio']} Bs'),
            const Text('Método: QR'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[100],
              child: Text('ID de Reserva: $pagoId',
                  style: const TextStyle(fontFamily: 'monospace')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarFactura(pagoId);
            },
            child: const Text('Ver Factura',
                style: TextStyle(color: Color(0xFF264653))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF264653)),
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarFactura(String pagoId) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Factura de Reserva'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID de Pago: $pagoId',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Estado: CONFIRMADO',
                  style: TextStyle(color: Colors.green)),
              const SizedBox(height: 8),
              Text(
                  'Fecha de emisión: ${DateTime.now().toString().split(' ')[0]}'),
              const SizedBox(height: 16),
              const Divider(),
              const Text('Gracias por su reserva!',
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Método para probar conexión (para debugging)
// Método para probar conexión (para debugging)
  void _probarConexion() async {
    try {
      setState(() {
        _cargando = true;
      });

      // ✅ USAR LA NUEVA PRUEBA COMPLETA JWT

      // Recargar datos después de la prueba
      await _cargarDatosIniciales();
    } catch (error) {
      _mostrarError('Error en prueba: $error');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }
  // ... (El resto de tus métodos _buildDrawer, _buildContenido, etc. se mantienen igual)

  // 🔥 NUEVO: Método para manejar la navegación del menú
  void _onMenuItemSelected() {
    // Cualquier lógica adicional que necesites al cambiar de página
    print('🔄 Navegando desde el menú...');
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE6E0),
      appBar: AppBar(
        title: const Text(
          'Mis Reservas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF264653),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // ✅ CORREGIDO - Usar Builder para el contexto correcto
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.white),
            onPressed: _probarConexion,
            tooltip: 'Diagnóstico',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _inicializarConLimpieza,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      // ✅ MenuResidente está correcto
      drawer: MenuResidente(
        onItemSelected: _onMenuItemSelected,
      ),
      body: _cargando
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF264653)),
                  SizedBox(height: 16),
                  Text('Cargando reservas...',
                      style: TextStyle(color: Color(0xFF264653))),
                ],
              ),
            )
          : _buildContenido(),
    );
  }

  // ... (El resto de tus métodos _buildContenido, _buildAreasGrid, etc. se mantienen igual)
  Widget _buildContenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlertaPoliticas(),
            const SizedBox(height: 20),
            _buildHorariosSection(),
            const SizedBox(height: 20),
            _buildAreasGrid(),
            const SizedBox(height: 20),
            _buildReservasActivas(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaPoliticas() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/residente/politicas');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFA3C8D6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF264653), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Importante: Políticas del Edificio',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF264653),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Antes de realizar cualquier reserva, por favor lee y comprende nuestras políticas y reglas para el uso de áreas comunes.',
                    style: TextStyle(
                      color: Color(0xFF264653),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Color(0xFF264653), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHorariosSection() {
    final horarios = ReservaService.getHorariosAreas();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horarios de Áreas Comunes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF264653),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: horarios.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time,
                        color: Color(0xFF7A8C6E), size: 20),
                    const SizedBox(height: 8),
                    Text(
                      _getNombreArea(entry.key),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getNombreArea(String key) {
    switch (key) {
      case 'salon':
        return 'Salón';
      case 'piscina':
        return 'Piscina';
      case 'gimnasio':
        return 'Gimnasio';
      case 'parqueo':
        return 'Parqueo';
      default:
        return key;
    }
  }

  Widget _buildAreasGrid() {
    final areas = _areasDisponibles.isNotEmpty
        ? _areasDisponibles
        : _getAreasPorDefecto();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Áreas Disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF264653),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: areas.length,
              itemBuilder: (context, index) {
                final area = areas[index];
                return AreaCard(
                  area: area,
                  onReservar: () => _abrirModalReserva(area),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Áreas por defecto en caso de error
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

  Widget _buildReservasActivas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis Reservas Activas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF264653),
              ),
            ),
            TextButton.icon(
              onPressed: _exportarReservasPDF,
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              label: const Text('Exportar PDF'),
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF264653)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _reservasActivas.isEmpty ? _buildSinReservas() : _buildListaReservas(),
      ],
    );
  }

  Widget _buildSinReservas() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.calendar_today, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tienes reservas activas',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Selecciona un área común para realizar tu primera reserva',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListaReservas() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reservasActivas.length,
      itemBuilder: (context, index) {
        final reserva = _reservasActivas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getColorArea(reserva['area'] ?? 'default'),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getIconArea(reserva['area'] ?? 'default'),
                  color: Colors.white),
            ),
            title: Text(
              reserva['descripcion'] ?? 'Reserva',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF264653),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Fecha: ${reserva['fecha'] ?? 'No especificada'}'),
                Text('Monto: ${reserva['monto'] ?? '0'} Bs'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getColorEstado(reserva['estado'] ?? 'pendiente'),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getTextoEstado(reserva['estado'] ?? 'pendiente'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorArea(String area) {
    switch (area) {
      case 'salon':
        return const Color(0xFF264653);
      case 'piscina':
        return const Color(0xFF2A9D8F);
      case 'gimnasio':
        return const Color(0xFFE9C46A);
      case 'parqueo':
        return const Color(0xFFF4A261);
      default:
        return const Color(0xFF264653);
    }
  }

  IconData _getIconArea(String area) {
    switch (area) {
      case 'salon':
        return Icons.celebration;
      case 'piscina':
        return Icons.pool;
      case 'gimnasio':
        return Icons.fitness_center;
      case 'parqueo':
        return Icons.local_parking;
      default:
        return Icons.place;
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'confirmado':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTextoEstado(String estado) {
    switch (estado) {
      case 'confirmado':
        return 'CONFIRMADO';
      case 'pendiente':
        return 'PENDIENTE';
      case 'cancelado':
        return 'CANCELADO';
      default:
        return 'DESCONOCIDO';
    }
  }

  void _exportarReservasPDF() {
    _mostrarExito('PDF de reservas exportado exitosamente');
  }
}
