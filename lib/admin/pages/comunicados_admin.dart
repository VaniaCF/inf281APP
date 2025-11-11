import 'package:flutter/material.dart';
import '../services/comunicados_service.dart';

class ComunicadosAdmin extends StatefulWidget {
  const ComunicadosAdmin({super.key});

  @override
  State<ComunicadosAdmin> createState() => _ComunicadosAdminState();
}

class _ComunicadosAdminState extends State<ComunicadosAdmin> {
  final ComunicadosService _comunicadosService = ComunicadosService();
  List<dynamic> _comunicados = []; // Cambiado a dynamic
  bool _cargando = true;
  String _error = '';
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  final TextEditingController _destinatarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarComunicados();
  }

  Future<void> _cargarComunicados() async {
    try {
      setState(() {
        _cargando = true;
        _error = '';
      });

      final comunicados = await _comunicadosService.obtenerComunicados();
      setState(() {
        _comunicados = comunicados;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar comunicados: $e';
        _cargando = false;
      });
      print('Error cargando comunicados: $e');
    }
  }

  Future<void> _crearComunicado() async {
    try {
      final nuevoComunicado = {
        'titulo': _tituloController.text,
        'mensaje': _mensajeController.text,
        'destinatario': _destinatarioController.text,
        'fecha': DateTime.now().toIso8601String(),
      };

      // CORREGIDO: Pasar el nuevoComunicado como parámetro
      await _comunicadosService.crearComunicado(nuevoComunicado);
      
      // Limpiar campos
      _tituloController.clear();
      _mensajeController.clear();
      _destinatarioController.clear();
      
      // Recargar lista
      _cargarComunicados();
      
      // Cerrar diálogo
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comunicado creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear comunicado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarComunicado(String id) async {
    try {
      await _comunicadosService.eliminarComunicado(id);
      _cargarComunicados();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comunicado eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar comunicado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoCrearComunicado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Comunicado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mensajeController,
                decoration: const InputDecoration(
                  labelText: 'Mensaje',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _destinatarioController,
                decoration: const InputDecoration(
                  labelText: 'Destinatario (Todos, Residentes, etc.)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _crearComunicado,
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Widget _buildComunicadoCard(Map<String, dynamic> comunicado) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.announcement, color: Color(0xFF264653)),
        title: Text(
          comunicado['titulo'] ?? 'Sin título',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comunicado['mensaje'] ?? 'Sin mensaje'),
            const SizedBox(height: 4),
            Text(
              'Para: ${comunicado['destinatario'] ?? 'Todos'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Fecha: ${_formatearFecha(comunicado['fecha'])}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _mostrarDialogoEliminar(comunicado);
          },
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar(Map<String, dynamic> comunicado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Comunicado'),
        content: Text('¿Estás seguro de eliminar el comunicado "${comunicado['titulo']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Usar 'id' o '_id' dependiendo de tu API
              final id = comunicado['id'] ?? comunicado['_id'] ?? '';
              if (id.isNotEmpty) {
                _eliminarComunicado(id);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(dynamic fecha) {
    try {
      if (fecha == null) return 'Fecha no disponible';
      final dateTime = DateTime.parse(fecha.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Comunicados'),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarComunicados,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _error,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarComunicados,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Resumen
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.announcement, size: 40, color: Color(0xFF264653)),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total de Comunicados',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _comunicados.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF264653),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Lista de comunicados
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _cargarComunicados,
                        child: _comunicados.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.announcement_outlined, size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No hay comunicados',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _comunicados.length,
                                itemBuilder: (context, index) {
                                  final comunicado = _comunicados[index];
                                  return _buildComunicadoCard(comunicado);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrearComunicado,
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
    _destinatarioController.dispose();
    super.dispose();
  }
}