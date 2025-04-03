import 'package:aleralarma/features/alarm/domain/entities/alarma_entitie.dart';
import 'package:aleralarma/features/alarm/domain/entities/obtener_status_alarma_entitie.dart';

abstract class AlarmRepository {
  Future<List<ObtenerStatusAlarmaEntitie>> OBTENERSTATUSALARMA();
  Future<void> DESACTIVARALARMA(AlarmaEntitie alarmaEntitie);

 Future<void> ACTIVARALARMA(AlarmaEntitie alarmaEntitie);
}