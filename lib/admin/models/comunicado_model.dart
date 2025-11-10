// models/comunicado_model.dart
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
}