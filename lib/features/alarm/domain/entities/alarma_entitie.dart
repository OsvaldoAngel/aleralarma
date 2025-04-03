class AlarmaEntitie {
  final String id_usuario;
  final String id_grupo;
  final String tipo_usuario;
  final String direccion;
  final String coordenadas;
   String? tipo_reporte;

  AlarmaEntitie({
    required this.id_usuario,
    required this.id_grupo,
    required this.tipo_usuario,
    required this.direccion,
    required this.coordenadas,
     this.tipo_reporte,
  });
}