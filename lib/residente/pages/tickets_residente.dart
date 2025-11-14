import 'package:flutter/material.dart';
import '../services/tickets_service.dart';
import '../widgets/menu_residente.dart';

class TicketsResidentePage extends StatefulWidget {
  const TicketsResidentePage({Key? key}) : super(key: key);

  @override
  _TicketsResidentePageState createState() => _TicketsResidentePageState();
}

class _TicketsResidentePageState extends State<TicketsResidentePage> {
  List<Ticket> _tickets = [];
  List<Ticket> _ticketsFiltrados = [];
  EstadisticasTickets? _estadisticas;
  bool _cargando = true;
  bool _error = false;
  String _mensajeError = '';

  // Filtros
  String _filtroEstado = '';
  String _filtroPrioridad = '';

  @override
  void initState() {
    super.initState();
    _cargarTickets();
  }

  Future<void> _cargarTickets() async {
    setState(() {
      _cargando = true;
      _error = false;
    });

    try {
      print('🎫 [TICKETS PAGE] Iniciando carga de tickets...');

      final resultado = await TicketsService.obtenerTickets();

      if (resultado['success'] == true) {
        setState(() {
          _tickets = resultado['tickets'];
          _ticketsFiltrados = _tickets;
          _estadisticas = resultado['estadisticas'];
          _cargando = false;
        });
        print('✅ [TICKETS PAGE] Tickets cargados: ${_tickets.length}');
      } else {
        setState(() {
          _error = true;
          _mensajeError = resultado['message'];
          _cargando = false;
        });
        print('❌ [TICKETS PAGE] Error: ${resultado['message']}');
      }
    } catch (e) {
      setState(() {
        _error = true;
        _mensajeError = 'Error: $e';
        _cargando = false;
      });
      print('❌ [TICKETS PAGE] Error exception: $e');
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _ticketsFiltrados = _tickets.where((ticket) {
        bool coincideEstado =
            _filtroEstado.isEmpty || ticket.estado == _filtroEstado;
        bool coincidePrioridad =
            _filtroPrioridad.isEmpty || ticket.prioridad == _filtroPrioridad;
        return coincideEstado && coincidePrioridad;
      }).toList();
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _filtroEstado = '';
      _filtroPrioridad = '';
      _ticketsFiltrados = _tickets;
    });
  }

  Future<void> _crearNuevoTicket() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearTicketPage(),
      ),
    );

    if (result == true) {
      _cargarTickets();
    }
  }

  Future<void> _verDetallesTicket(Ticket ticket) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleTicketPage(
          ticketId: ticket.idTicket,
        ),
      ),
    );

    _cargarTickets();
  }

  Future<void> _cancelarTicket(Ticket ticket) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Ticket'),
        content: Text('¿Está seguro de cancelar este ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      final resultado = await TicketsService.cancelarTicket(ticket.idTicket);

      if (resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket cancelado exitosamente')),
        );
        _cargarTickets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['message'])),
        );
      }
    }
  }

  Widget _buildEstadisticas() {
    if (_estadisticas == null) return SizedBox();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Tickets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTarjetaEstadistica(
                  'Total',
                  _estadisticas!.total.toString(),
                  Colors.blue,
                  Icons.receipt,
                ),
                SizedBox(width: 8),
                _buildTarjetaEstadistica(
                  'Abiertos',
                  _estadisticas!.abiertos.toString(),
                  Colors.orange,
                  Icons.pending_actions,
                ),
                SizedBox(width: 8),
                _buildTarjetaEstadistica(
                  'En Progreso',
                  _estadisticas!.enProgreso.toString(),
                  Colors.purple,
                  Icons.build,
                ),
                SizedBox(width: 8),
                _buildTarjetaEstadistica(
                  'Cerrados',
                  _estadisticas!.cerrados.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                SizedBox(width: 8),
                _buildTarjetaEstadistica(
                  'Urgentes',
                  _estadisticas!.urgentes.toString(),
                  Colors.red,
                  Icons.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaEstadistica(
      String titulo, String valor, Color color, IconData icon) {
    return Container(
      width: 100, // 🔥 ANCHO FIJO PARA EVITAR OVERFLOW
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // 🔥 CORRECCIÓN: DROPDOWNS EN COLUMNA PARA EVITAR OVERFLOW
          Column(
            children: [
              DropdownButtonFormField<String>(
                value: _filtroEstado.isEmpty ? null : _filtroEstado,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  isDense: true, // 🔥 REDUCIR ALTURA
                ),
                items: [
                  DropdownMenuItem(value: '', child: Text('Todos los estados')),
                  DropdownMenuItem(value: 'abierto', child: Text('🟡 Abierto')),
                  DropdownMenuItem(
                      value: 'en_progreso', child: Text('🔵 En Progreso')),
                  DropdownMenuItem(value: 'cerrado', child: Text('🟢 Cerrado')),
                  DropdownMenuItem(
                      value: 'cancelado', child: Text('🔴 Cancelado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filtroEstado = value ?? '';
                  });
                  _aplicarFiltros();
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _filtroPrioridad.isEmpty ? null : _filtroPrioridad,
                decoration: InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  isDense: true, // 🔥 REDUCIR ALTURA
                ),
                items: [
                  DropdownMenuItem(
                      value: '', child: Text('Todas las prioridades')),
                  DropdownMenuItem(value: 'baja', child: Text('📗 Baja')),
                  DropdownMenuItem(value: 'media', child: Text('📘 Media')),
                  DropdownMenuItem(value: 'alta', child: Text('📙 Alta')),
                  DropdownMenuItem(value: 'urgente', child: Text('📕 Urgente')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filtroPrioridad = value ?? '';
                  });
                  _aplicarFiltros();
                },
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _limpiarFiltros,
              icon: Icon(Icons.clear_all, size: 18),
              label: Text('Limpiar Filtros'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaTickets() {
    if (_cargando) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando tickets...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_error) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error al cargar tickets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _mensajeError,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargarTickets,
                icon: Icon(Icons.refresh),
                label: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ticketsFiltrados.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No hay tickets',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _filtroEstado.isNotEmpty || _filtroPrioridad.isNotEmpty
                    ? 'No se encontraron tickets con los filtros aplicados'
                    : 'No has creado ningún ticket aún',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 20),
              if (_filtroEstado.isNotEmpty || _filtroPrioridad.isNotEmpty)
                ElevatedButton(
                  onPressed: _limpiarFiltros,
                  child: Text('Limpiar Filtros'),
                )
              else
                ElevatedButton.icon(
                  onPressed: _crearNuevoTicket,
                  icon: Icon(Icons.add),
                  label: Text('Crear Primer Ticket'),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarTickets,
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: _ticketsFiltrados.length,
        itemBuilder: (context, index) {
          final ticket = _ticketsFiltrados[index];
          return _buildTarjetaTicket(ticket);
        },
      ),
    );
  }

  Widget _buildTarjetaTicket(Ticket ticket) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _verDetallesTicket(ticket),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 CORRECCIÓN: CONTENIDO PRINCIPAL
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.descripcion,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getColorPrioridad(ticket.prioridad)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: _getColorPrioridad(ticket.prioridad)
                                        .withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(ticket.iconoPrioridad,
                                      style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 4),
                                  Text(
                                    ticket.prioridadTexto,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          _getColorPrioridad(ticket.prioridad),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getColorEstado(ticket.estado)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: _getColorEstado(ticket.estado)
                                        .withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(ticket.iconoEstado,
                                      style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 4),
                                  Text(
                                    ticket.estadoTexto,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getColorEstado(ticket.estado),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey[400]),
                ],
              ),

              // 🔥 CORRECCIÓN: INFORMACIÓN ADICIONAL
              SizedBox(height: 8),
              if (ticket.areaNombre.isNotEmpty &&
                  ticket.areaNombre != 'General')
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.place, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ticket.areaNombre,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              if (ticket.fechaEmision != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatearFecha(ticket.fechaEmision!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // 🔥 CORRECCIÓN: BOTONES RESPONSIVOS
              SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;

                  if (screenWidth < 360) {
                    // Pantallas muy pequeñas
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _verDetallesTicket(ticket),
                            child: Text('Ver Detalles'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        if (ticket.estado == 'abierto') ...[
                          SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _cancelarTicket(ticket),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: Text('Cancelar'),
                            ),
                          ),
                        ],
                      ],
                    );
                  } else {
                    // Pantallas normales
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _verDetallesTicket(ticket),
                            child: Text('Ver Detalles'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        if (ticket.estado == 'abierto') ...[
                          SizedBox(width: 8),
                          Container(
                            width: screenWidth < 400
                                ? 120
                                : 100, // 🔂 ANCHO ADAPTATIVO
                            child: ElevatedButton(
                              onPressed: () => _cancelarTicket(ticket),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                    fontSize: screenWidth < 400 ? 12 : 14),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'baja':
        return Colors.green;
      case 'media':
        return Colors.blue;
      case 'alta':
        return Colors.orange;
      case 'urgente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'abierto':
        return Colors.orange;
      case 'en_progreso':
        return Colors.blue;
      case 'cerrado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatearFecha(String fecha) {
    try {
      final dateTime = DateTime.parse(fecha);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Mis Tickets'),
        backgroundColor: Color(0xFF264653),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarTickets,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: MenuResidente(
        onItemSelected: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          _buildEstadisticas(),
          _buildFiltros(),
          Expanded(child: _buildListaTickets()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearNuevoTicket,
        child: Icon(Icons.add),
        tooltip: 'Nuevo Ticket',
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

// 🔥 MANTENER LAS CLASES CrearTicketPage y DetalleTicketPage IGUALES
class CrearTicketPage extends StatefulWidget {
  const CrearTicketPage({Key? key}) : super(key: key);

  @override
  _CrearTicketPageState createState() => _CrearTicketPageState();
}

class _CrearTicketPageState extends State<CrearTicketPage> {
  final _formKey = GlobalKey<FormState>();
  String _descripcion = '';
  String _prioridad = 'media';
  int? _idArea;
  List<Area> _areas = [];
  bool _cargandoAreas = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargarAreas();
  }

  Future<void> _cargarAreas() async {
    final resultado = await TicketsService.obtenerAreas();
    if (resultado['success'] == true) {
      setState(() {
        _areas = resultado['areas'];
        _cargandoAreas = false;
      });
    } else {
      setState(() {
        _cargandoAreas = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al cargar áreas: ${resultado['message']}')),
      );
    }
  }

  Future<void> _crearTicket() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _enviando = true;
      });

      final resultado = await TicketsService.crearTicket(
        descripcion: _descripcion,
        prioridad: _prioridad,
        idArea: _idArea,
      );

      setState(() {
        _enviando = false;
      });

      if (resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Ticket creado exitosamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${resultado['message']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Ticket'),
        backgroundColor: Color(0xFF264653),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Ticket',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Descripción *',
                          border: OutlineInputBorder(),
                          hintText: 'Describe el problema o solicitud...',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La descripción es obligatoria';
                          }
                          if (value.length < 10) {
                            return 'La descripción debe tener al menos 10 caracteres';
                          }
                          return null;
                        },
                        onSaved: (value) => _descripcion = value!,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _prioridad,
                        decoration: InputDecoration(
                          labelText: 'Prioridad *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem(
                              value: 'baja', child: Text('📗 Baja')),
                          DropdownMenuItem(
                              value: 'media', child: Text('📘 Media')),
                          DropdownMenuItem(
                              value: 'alta', child: Text('📙 Alta')),
                          DropdownMenuItem(
                              value: 'urgente', child: Text('📕 Urgente')),
                        ],
                        onChanged: (value) =>
                            setState(() => _prioridad = value!),
                      ),
                      SizedBox(height: 16),
                      _cargandoAreas
                          ? Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<int?>(
                              value: _idArea,
                              decoration: InputDecoration(
                                labelText: 'Área (Opcional)',
                                border: OutlineInputBorder(),
                                hintText: 'Selecciona un área relacionada',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                isDense: true,
                              ),
                              items: [
                                DropdownMenuItem(
                                    value: null,
                                    child: Text('🏠 Sin área específica')),
                                ..._areas.map((area) => DropdownMenuItem(
                                      value: area.idArea,
                                      child: Text('📍 ${area.nombre}'),
                                    )),
                              ],
                              onChanged: (value) =>
                                  setState(() => _idArea = value),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              _enviando
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _crearTicket,
                        child: Text('Crear Ticket',
                            style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Color(0xFF264653),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetalleTicketPage extends StatefulWidget {
  final int ticketId;
  const DetalleTicketPage({Key? key, required this.ticketId}) : super(key: key);
  @override
  _DetalleTicketPageState createState() => _DetalleTicketPageState();
}

class _DetalleTicketPageState extends State<DetalleTicketPage> {
  TicketDetalle? _ticket;
  bool _cargando = true;
  String _mensajeError = '';
  final TextEditingController _comentarioController = TextEditingController();
  bool _enviandoComentario = false;

  @override
  void initState() {
    super.initState();
    _cargarDetalles();
  }

  Future<void> _cargarDetalles() async {
    final resultado =
        await TicketsService.obtenerDetalleTicket(widget.ticketId);
    if (resultado['success'] == true) {
      setState(() {
        _ticket = resultado['ticket'];
        _cargando = false;
      });
    } else {
      setState(() {
        _mensajeError = resultado['message'];
        _cargando = false;
      });
    }
  }

  Future<void> _agregarComentario() async {
    if (_comentarioController.text.isEmpty) return;
    setState(() {
      _enviandoComentario = true;
    });

    final resultado = await TicketsService.agregarComentario(
      ticketId: widget.ticketId,
      comentario: _comentarioController.text,
    );

    setState(() {
      _enviandoComentario = false;
    });

    if (resultado['success'] == true) {
      _comentarioController.clear();
      _cargarDetalles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Comentario agregado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ${resultado['message']}')),
      );
    }
  }

  // ... (mantener los métodos _buildInfoTicket, _buildComentarios, etc.)
  Widget _buildInfoTicket() {
    if (_ticket == null) return SizedBox();
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket #${_ticket!.idTicket}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(_ticket!.descripcion, style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                    label: Text(_ticket!.prioridad,
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: _getColorPrioridad(_ticket!.prioridad)),
                Chip(label: Text(_ticket!.estado)),
              ],
            ),
            SizedBox(height: 8),
            if (_ticket!.fechaEmision != null)
              Text('Creado: ${_formatearFecha(_ticket!.fechaEmision!)}'),
            if (_ticket!.fechaFinalizacion != null)
              Text(
                  'Finalizado: ${_formatearFecha(_ticket!.fechaFinalizacion!)}'),
            if (_ticket!.empleadoAsignado != null)
              Text('Empleado: ${_ticket!.empleadoAsignado}'),
            if (_ticket!.areaNombre.isNotEmpty)
              Text('Área: ${_ticket!.areaNombre}'),
          ],
        ),
      ),
    );
  }

  Widget _buildComentarios() {
    if (_ticket == null || _ticket!.comentarios.isEmpty) {
      return Card(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No hay comentarios'))));
    }
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comentarios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ..._ticket!.comentarios
                .map((comentario) => _buildComentario(comentario)),
          ],
        ),
      ),
    );
  }

  Widget _buildComentario(Comentario comentario) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(comentario.autor,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_formatearFecha(comentario.fecha),
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]),
          SizedBox(height: 8),
          Text(comentario.mensaje),
        ],
      ),
    );
  }

  Widget _buildAgregarComentario() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agregar Comentario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              controller: _comentarioController,
              decoration: InputDecoration(
                  hintText: 'Escribe tu comentario...',
                  border: OutlineInputBorder()),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            _enviandoComentario
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agregarComentario,
                      child: Text('Enviar Comentario'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF264653)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Color _getColorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'baja':
        return Colors.green;
      case 'media':
        return Colors.blue;
      case 'alta':
        return Colors.orange;
      case 'urgente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatearFecha(String fecha) {
    try {
      final dateTime = DateTime.parse(fecha);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Detalle del Ticket'),
          backgroundColor: Color(0xFF264653),
          foregroundColor: Colors.white),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : _ticket == null
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error al cargar el ticket'),
                      SizedBox(height: 8),
                      Text(_mensajeError),
                      SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _cargarDetalles,
                          child: Text('Reintentar')),
                    ]))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [
                    _buildInfoTicket(),
                    SizedBox(height: 16),
                    _buildComentarios(),
                    SizedBox(height: 16),
                    _buildAgregarComentario(),
                  ]),
                ),
    );
  }
}
