import 'package:aleralarma/features/alarm/domain/entities/obtener_status_alarma_entitie.dart';
import 'package:flutter/foundation.dart';

class ObtenerStatusAlarmaModel extends ObtenerStatusAlarmaEntitie {
  final String status_alarma;
  final bool status;

  ObtenerStatusAlarmaModel({
    required this.status_alarma,
    required this.status,
  }) : super(status: status, status_alarma: status_alarma);

  factory ObtenerStatusAlarmaModel.fromJson(Map<String, dynamic> json) {
  return ObtenerStatusAlarmaModel(
    status_alarma: json['status_alarma'] ?? '',
    status: json['status'] is bool ? json['status'] : false,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'status_alarma': status_alarma,
      'status': status,
    };
  }

  factory ObtenerStatusAlarmaModel.fromEntity(ObtenerStatusAlarmaEntitie entity) {
    return ObtenerStatusAlarmaModel(
      status_alarma: entity.status_alarma,
      status: entity.status,
    );
  }
}
