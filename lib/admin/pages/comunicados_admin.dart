import '../services/comunicados_service.dart';
import 'package:flutter/material.dart';
// ELIMINAR esta línea: import '../models/comunicado_model.dart' as modelo;

class ComunicadosAdmin extends StatefulWidget {
  @override
  _ComunicadosAdminState createState() => _ComunicadosAdminState();
}

class _ComunicadosAdminState extends State<ComunicadosAdmin> {
  final ComunicadosService _comunicadosService = ComunicadosService();
  List<Comunicado> comunicados = []; // Comunicado viene del servicio

  @override
  void initState() {
    super.initState();
    _cargarComunicados();
  }

  Future<void> _cargarComunicados() async {
    try {
      final lista = await _comunicadosService.obtenerComunicados();
      setState(() => comunicados = lista);
    } catch (e) {
      print('Error cargando comunicados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Comunicados')),
      body: ListView.builder(
        itemCount: comunicados.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(comunicados[index].titulo),
          subtitle: Text(comunicados[index].fechaPublicacion),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoNuevoComunicado(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoNuevoComunicado() {
    // Implementar aquí
  }
}