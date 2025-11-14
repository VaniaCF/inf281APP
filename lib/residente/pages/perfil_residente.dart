// lib/screens/residente/perfil_residente.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/perfil_service.dart';
import '../widgets/menu_residente.dart';

class PerfilResidenteScreen extends StatefulWidget {
  const PerfilResidenteScreen({Key? key}) : super(key: key);

  @override
  State<PerfilResidenteScreen> createState() => _PerfilResidenteScreenState();
}

class _PerfilResidenteScreenState extends State<PerfilResidenteScreen> {
  Map<String, dynamic> _usuario = {};
  Map<String, dynamic> _departamento = {};
  Map<String, dynamic> _residente = {};

  Map<String, bool> _preferencias = {
    'notifPagos': true,
    'notifTickets': true,
    'notifReservas': true,
  };

  bool _isLoading = true;
  bool _isRefreshing = false;

  // PALETA DE COLORES
  final Color _azulProfundo = const Color(0xFF264653);
  final Color _verdeOliva = const Color(0xFF7A8C6E);
  final Color _duraznoSuave = const Color(0xFFE3A78C);
  final Color _beigeSuave = const Color(0xFFEDE6E0);
  final Color _grisClaro = const Color(0xFFF5F5F5);
  final Color _marronOscuro = const Color(0xFF2F241F);
  final Color _celesteClaro = const Color(0xFFA3C8D6);

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
    _cargarPreferencias();
  }

  Future<void> _cargarDatosPerfil() async {
    setState(() {
      _isLoading = true;
    });

    final response = await PerfilService.obtenerPerfil();

    if (response['success'] == true && mounted) {
      final data = response['data'];
      setState(() {
        _usuario = data['usuario'] ?? {};
        _departamento = data['departamento'] ?? {};
        _residente = data['residente'] ?? {};
      });
    } else if (mounted) {
      _mostrarSnackBar(response['message'] ?? 'Error al cargar el perfil');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _preferencias['notifPagos'] = prefs.getBool('notifPagos') ?? true;
      _preferencias['notifTickets'] = prefs.getBool('notifTickets') ?? true;
      _preferencias['notifReservas'] = prefs.getBool('notifReservas') ?? true;
    });
  }

  Future<void> _guardarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifPagos', _preferencias['notifPagos']!);
    await prefs.setBool('notifTickets', _preferencias['notifTickets']!);
    await prefs.setBool('notifReservas', _preferencias['notifReservas']!);

    // También guardar en el servidor
    await PerfilService.actualizarPreferencias(_preferencias);
  }

  void _mostrarSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.toLowerCase().contains('éxito') ||
                message.toLowerCase().contains('correctamente')
            ? _verdeOliva
            : Colors.red,
      ),
    );
  }

  void _abrirEditarPerfil() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _grisClaro,
      builder: (context) => _buildEditarPerfilModal(),
    );
  }

  void _abrirCambiarPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _grisClaro,
      builder: (context) => _buildCambiarPasswordModal(),
    );
  }

  Future<void> _cerrarOtrasSesiones() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _grisClaro,
        title: const Text('Cerrar otras sesiones'),
        content: const Text(
            '¿Estás seguro de que quieres cerrar todas las demás sesiones activas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesiones'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await PerfilService.cerrarOtrasSesiones();
      _mostrarSnackBar(response['message'] ?? 'Operación completada');
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: _marronOscuro.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : 'No especificado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _marronOscuro,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPreferenciaItem(String key, String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: _marronOscuro,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: _marronOscuro.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _preferencias[key] ?? false,
          onChanged: (value) {
            setState(() {
              _preferencias[key] = value;
            });
            _guardarPreferencias();
          },
          activeColor: _azulProfundo,
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Card(
      elevation: 2,
      color: _beigeSuave,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: _azulProfundo, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _marronOscuro,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuResidente(
        onItemSelected: () {
          // Callback cuando se selecciona un item del menú
        },
      ),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: _azulProfundo,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing
                ? null
                : () async {
                    setState(() => _isRefreshing = true);
                    await _cargarDatosPerfil();
                    setState(() => _isRefreshing = false);
                  },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: _azulProfundo,
              ),
            )
          : RefreshIndicator(
              color: _azulProfundo,
              onRefresh: _cargarDatosPerfil,
              child: Container(
                color: _grisClaro,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _celesteClaro.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _celesteClaro),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _azulProfundo,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: _beigeSuave,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${_usuario['nombre'] ?? ''} ${_usuario['ap_paterno'] ?? ''} ${_usuario['ap_materno'] ?? ''}'
                                  .trim(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _marronOscuro,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _usuario['correo'] ?? '',
                              style: TextStyle(
                                color: _marronOscuro.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Información Personal
                      _buildCard(
                        title: 'Información Personal',
                        icon: Icons.person,
                        child: Column(
                          children: [
                            _buildInfoItem(
                              'Nombre Completo',
                              '${_usuario['nombre'] ?? ''} ${_usuario['ap_paterno'] ?? ''} ${_usuario['ap_materno'] ?? ''}'
                                  .trim(),
                            ),
                            _buildInfoItem(
                              'Correo Electrónico',
                              _usuario['correo'] ?? '',
                            ),
                            _buildInfoItem(
                              'Teléfono',
                              _usuario['telefono'] ?? 'No especificado',
                            ),
                            _buildInfoItem(
                              'Cédula de Identidad',
                              _usuario['ci'] ?? 'No especificado',
                            ),
                            _buildInfoItem(
                              'Rol',
                              _usuario['rol_nombre'] ?? 'Residente',
                            ),

                            // Botones de acción
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _abrirEditarPerfil,
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Editar Información'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      backgroundColor: _azulProfundo,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _abrirCambiarPassword,
                                    icon: const Icon(Icons.lock, size: 18),
                                    label: const Text('Cambiar Contraseña'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      foregroundColor: _azulProfundo,
                                      side: BorderSide(color: _azulProfundo),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Información del Departamento
                      _buildCard(
                        title: 'Mi Departamento',
                        icon: Icons.home,
                        child: _departamento.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Datos de Residencia',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: _marronOscuro,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.apartment,
                                          color:
                                              _marronOscuro.withOpacity(0.7)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Piso ${_departamento['piso'] ?? 'N/A'}',
                                        style: TextStyle(color: _marronOscuro),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.door_front_door,
                                          color:
                                              _marronOscuro.withOpacity(0.7)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Departamento ${_departamento['nro'] ?? 'N/A'}',
                                        style: TextStyle(color: _marronOscuro),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color:
                                              _marronOscuro.withOpacity(0.7)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ingreso: ${_residente['fecha_ingreso'] ?? 'N/A'}',
                                        style: TextStyle(color: _marronOscuro),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Icon(Icons.home,
                                      size: 48,
                                      color: _marronOscuro.withOpacity(0.5)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No hay información de departamento disponible',
                                    style: TextStyle(
                                        color: _marronOscuro.withOpacity(0.6)),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                      ),

                      // Preferencias de Notificación
                      _buildCard(
                        title: 'Preferencias de Notificación',
                        icon: Icons.notifications,
                        child: Column(
                          children: [
                            _buildPreferenciaItem(
                              'notifPagos',
                              'Notificaciones de Pagos',
                              'Alertas sobre facturas y vencimientos',
                            ),
                            const SizedBox(height: 16),
                            _buildPreferenciaItem(
                              'notifTickets',
                              'Notificaciones de Tickets',
                              'Actualizaciones de mis solicitudes',
                            ),
                            const SizedBox(height: 16),
                            _buildPreferenciaItem(
                              'notifReservas',
                              'Notificaciones de Reservas',
                              'Recordatorios y confirmaciones',
                            ),
                          ],
                        ),
                      ),

                      // Seguridad
                      _buildCard(
                        title: 'Seguridad',
                        icon: Icons.security,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.device_hub,
                                    color: _marronOscuro.withOpacity(0.7),
                                    size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sesión activa',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _marronOscuro),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Iniciada: ${DateTime.now().toString()}',
                                        style: TextStyle(
                                            color:
                                                _marronOscuro.withOpacity(0.6),
                                            fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Dispositivo: Móvil',
                                        style: TextStyle(
                                            color:
                                                _marronOscuro.withOpacity(0.6),
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _cerrarOtrasSesiones,
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Cerrar Otras Sesiones'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Modal para editar perfil
  Widget _buildEditarPerfilModal() {
    final nombreController =
        TextEditingController(text: _usuario['nombre'] ?? '');
    final apPaternoController =
        TextEditingController(text: _usuario['ap_paterno'] ?? '');
    final apMaternoController =
        TextEditingController(text: _usuario['ap_materno'] ?? '');
    final telefonoController =
        TextEditingController(text: _usuario['telefono'] ?? '');
    final ciController = TextEditingController(text: _usuario['ci'] ?? '');

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: _grisClaro,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Editar Información Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _marronOscuro,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: _marronOscuro),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Form(
            child: Column(
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: _marronOscuro),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                  ),
                  style: TextStyle(color: _marronOscuro),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: apPaternoController,
                  decoration: InputDecoration(
                    labelText: 'Apellido Paterno',
                    labelStyle: TextStyle(color: _marronOscuro),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                  ),
                  style: TextStyle(color: _marronOscuro),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: apMaternoController,
                  decoration: InputDecoration(
                    labelText: 'Apellido Materno',
                    labelStyle: TextStyle(color: _marronOscuro),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                  ),
                  style: TextStyle(color: _marronOscuro),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    labelStyle: TextStyle(color: _marronOscuro),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                  ),
                  style: TextStyle(color: _marronOscuro),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ciController,
                  decoration: InputDecoration(
                    labelText: 'Cédula de Identidad',
                    labelStyle: TextStyle(color: _marronOscuro),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                  ),
                  style: TextStyle(color: _marronOscuro),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _azulProfundo,
                          side: BorderSide(color: _azulProfundo),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final datos = {
                            'nombre': nombreController.text,
                            'ap_paterno': apPaternoController.text,
                            'ap_materno': apMaternoController.text,
                            'telefono': telefonoController.text,
                            'ci': ciController.text,
                          };

                          final response =
                              await PerfilService.actualizarPerfil(datos);

                          if (mounted) {
                            Navigator.of(context).pop();
                            _mostrarSnackBar(
                                response['message'] ?? 'Operación completada');

                            if (response['success'] == true) {
                              await _cargarDatosPerfil();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _azulProfundo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Guardar Cambios'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modal para cambiar contraseña
  Widget _buildCambiarPasswordModal() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: _grisClaro,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cambiar Contraseña',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _marronOscuro,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: _marronOscuro),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Form(
            child: Column(
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña Actual',
                    labelStyle: TextStyle(color: _marronOscuro),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                  ),
                  style: TextStyle(color: _marronOscuro),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    labelStyle: TextStyle(color: _marronOscuro),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                  ),
                  style: TextStyle(color: _marronOscuro),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                    labelStyle: TextStyle(color: _marronOscuro),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _azulProfundo),
                    ),
                  ),
                  style: TextStyle(color: _marronOscuro),
                  obscureText: true,
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _azulProfundo,
                          side: BorderSide(color: _azulProfundo),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            _mostrarSnackBar('Las contraseñas no coinciden');
                            return;
                          }

                          if (newPasswordController.text.length < 6) {
                            _mostrarSnackBar(
                                'La contraseña debe tener al menos 6 caracteres');
                            return;
                          }

                          final response = await PerfilService.cambiarPassword(
                            currentPassword: currentPasswordController.text,
                            newPassword: newPasswordController.text,
                          );

                          if (mounted) {
                            Navigator.of(context).pop();
                            _mostrarSnackBar(
                                response['message'] ?? 'Operación completada');

                            if (response['success'] == true) {
                              currentPasswordController.clear();
                              newPasswordController.clear();
                              confirmPasswordController.clear();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _azulProfundo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cambiar Contraseña'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
