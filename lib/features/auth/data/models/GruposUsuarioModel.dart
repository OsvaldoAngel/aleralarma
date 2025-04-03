class GruposUsuarioModel {
  final List<GrupoModel> grupos;

  GruposUsuarioModel({
    required this.grupos,
  });

  factory GruposUsuarioModel.fromJson(Map<String, dynamic> json) {
    List<GrupoModel> gruposList = [];
    
    if (json['grupos'] != null) {
      json['grupos'].forEach((v) {
        gruposList.add(GrupoModel.fromJson(v));
      });
    }
    
    return GruposUsuarioModel(grupos: gruposList);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['grupos'] = grupos.map((v) => v.toJson()).toList();
    return data;
  }
}

class GrupoModel {
  final String grupoId;
  final String idAdministradorRegional;
  final String idAdministradorColonial;
  final String urlAlarma;
  final String grupoLugar;
  final String estadoEnGrupo;
  final String grupoUsuarioId;
  final String idAdmin;
  final String alarmaId;

  GrupoModel({
    required this.grupoId,
    required this.idAdministradorRegional,
    required this.idAdministradorColonial,
    required this.urlAlarma,
    required this.grupoLugar,
    required this.estadoEnGrupo,
    required this.grupoUsuarioId,
    required this.idAdmin,
    required this.alarmaId,
  });

  factory GrupoModel.fromJson(Map<String, dynamic> json) {
    return GrupoModel(
      grupoId: json['grupo_id'] ?? '',
      idAdministradorRegional: json['id_administrador_regional'] ?? '',
      idAdministradorColonial: json['id_administrador_colonial'] ?? '',
      urlAlarma: json['url_alarma'] ?? '',
      grupoLugar: json['grupo_lugar'] ?? '',
      estadoEnGrupo: json['estado_en_grupo'] ?? '',
      grupoUsuarioId: json['grupo_usuario_id'] ?? '',
      idAdmin: json['id_admin'] ?? '',
      alarmaId: json['alarma_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grupo_id': grupoId,
      'id_administrador_regional': idAdministradorRegional,
      'id_administrador_colonial': idAdministradorColonial,
      'url_alarma': urlAlarma,
      'grupo_lugar': grupoLugar,
      'estado_en_grupo': estadoEnGrupo,
      'grupo_usuario_id': grupoUsuarioId,
      'id_admin': idAdmin,
      'alarma_id': alarmaId,
    };
  }
}