import 'package:aleralarma/features/alarm/domain/entities/alarma_entitie.dart';

class AlarmaModel extends AlarmaEntitie {
  final String id_usuario;
  final String id_grupo;
  final String tipo_usuario;
  final String direccion;
  final String coordenadas;
  String? tipo_reporte;

  AlarmaModel({
    required this.id_usuario,
    required this.id_grupo,
    required this.tipo_usuario,
    required this.direccion,
    required this.coordenadas,
    required this.tipo_reporte,
  }) : super(
          id_usuario: id_usuario,
          id_grupo: id_grupo,
          tipo_usuario: tipo_usuario,
          direccion: direccion,
          coordenadas: coordenadas,
          tipo_reporte: tipo_reporte,
        );

  factory AlarmaModel.fromJson(Map<String, dynamic> json) {
    return AlarmaModel(
      id_usuario: json['id_usuario'],
      id_grupo: json['id_grupo'],
      tipo_usuario: json['tipo_usuario'],
      direccion: json['direccion'],
      coordenadas: json['coordenadas'],
      tipo_reporte: json['tipo_reporte'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': id_usuario,
      'id_grupo': id_grupo,
      'tipo_usuario': tipo_usuario,
      'direccion': direccion,
      'coordenadas': coordenadas,
      'tipo_reporte': tipo_reporte,
    };
  }

  factory AlarmaModel.fromEntity(AlarmaEntitie entity) {
    return AlarmaModel(
      id_usuario: entity.id_usuario,
      id_grupo: entity.id_grupo,
      tipo_usuario: entity.tipo_usuario,
      direccion: entity.direccion,
      coordenadas: entity.coordenadas,
      tipo_reporte: entity.tipo_reporte,
    );
  }
}
