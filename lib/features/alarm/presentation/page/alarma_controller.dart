import 'package:aleralarma/features/alarm/data/repository/alarma_repository_imp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aleralarma/features/alarm/domain/entities/alarma_entitie.dart';
import 'package:aleralarma/features/alarm/domain/repository/alarm_repository.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Enumeración para los diferentes estados de la alarma
enum AlarmStatus {
  loading,  // Estado inicial o de carga
  secure,   // Estado seguro (verde)
  panic     // Estado de pánico (rojo)
}

// Estado para el controlador de alarma
class AlarmState {
  final AlarmStatus status;
  final String statusText;
  final bool isActive;
  final String? errorMessage;
  final bool isLoading;
  final bool isAnimating;
  final bool isCompleted;
  final double animationProgress;

  AlarmState({
    this.status = AlarmStatus.loading,
    this.statusText = 'Cargando...',
    this.isActive = false,
    this.errorMessage,
    this.isLoading = false,
    this.isAnimating = false,
    this.isCompleted = false,
    this.animationProgress = 0.0,
  });

  AlarmState copyWith({
    AlarmStatus? status,
    String? statusText,
    bool? isActive,
    String? errorMessage,
    bool? isLoading,
    bool? isAnimating,
    bool? isCompleted,
    double? animationProgress,
  }) {
    return AlarmState(
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      isActive: isActive ?? this.isActive,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isAnimating: isAnimating ?? this.isAnimating,
      isCompleted: isCompleted ?? this.isCompleted,
      animationProgress: animationProgress ?? this.animationProgress,
    );
  }
}

// Provider para el controlador de alarma
final alarmControllerProvider = StateNotifierProvider<AlarmController, AlarmState>((ref) {
  final repository = ref.watch(alarmaRepositoryImp);
  return AlarmController(repository, ref);
}, name: 'alarmController');

class AlarmController extends StateNotifier<AlarmState> {
  final AlarmRepository _repository;
  final Ref _ref;

  AlarmController(this._repository, this._ref) : super(AlarmState()) {
    _init();
  }

  Future<void> _init() async {
    await refreshAlarmStatus();
  }
  
  // Métodos para controlar la animación
  void startAnimation() {
    state = state.copyWith(isAnimating: true);
  }
  
  void cancelAnimation() {
    state = state.copyWith(isAnimating: false, animationProgress: 0.0);
  }
  
  // Add a simple debounce mechanism
  DateTime _lastUpdate = DateTime.now();
  void updateAnimationProgress(double progress) {
    final now = DateTime.now();
    if (now.difference(_lastUpdate).inMilliseconds > 50) { // Update at most every 50ms
      _lastUpdate = now;
      state = state.copyWith(animationProgress: progress);
    }
  }
  
  void completeAnimation() {
    state = state.copyWith(isCompleted: true);
    
    // Activar/desactivar alarma al completar la animación
    toggleAlarm();
    
    // Reiniciar la animación después de un tiempo
    Future.delayed(const Duration(seconds: 1), () {
      state = state.copyWith(
        isCompleted: false,
        isAnimating: false,
        animationProgress: 0.0
      );
    });
  }

  // Método para obtener la ubicación actual
  Future<Map<String, String>> _getCurrentLocation() async {
    try {
      // Verificar los permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente');
      }
      
      // Obtener posición actual
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Convertir coordenadas a dirección
      String direccion = "Dirección desconocida";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          direccion = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
        }
      } catch (e) {
        print('Error al obtener dirección: $e');
      }
      
      // Coordenadas en formato "latitud,longitud"
      final coordenadas = '${position.latitude},${position.longitude}';
      
      return {
        'direccion': direccion,
        'coordenadas': coordenadas,
      };
    } catch (e) {
      print('Error al obtener ubicación: $e');
      return {
        'direccion': 'Dirección del usuario',
        'coordenadas': '0.0,0.0',
      };
    }
  }

  Future<void> refreshAlarmStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final statusList = await _repository.OBTENERSTATUSALARMA();
      
      if (statusList.isNotEmpty) {
        final alarmStatus = statusList[0];
        
        // Procesar el status_alarma a minúsculas para comparación
        final statusText = alarmStatus.status_alarma.toLowerCase();
        
        // Determinar el estado de la alarma según la respuesta del servidor
        AlarmStatus newStatus;
        if (statusText.contains("seguro") && alarmStatus.status == false) {
          newStatus = AlarmStatus.secure;
        } else if (statusText.contains("panico") && alarmStatus.status == true) {
          newStatus = AlarmStatus.panic;
        } else {
          // Usar el valor booleano de status para determinar
          newStatus = alarmStatus.status ? AlarmStatus.panic : AlarmStatus.secure;
        }
        
        // Actualizar el estado con los valores del servidor
        state = state.copyWith(
          status: newStatus,
          statusText: alarmStatus.status_alarma,
          isActive: alarmStatus.status,
          isLoading: false,
          errorMessage: null, // Limpiar mensajes de error previos
        );
      } else {
        // Mantener el estado seguro si no hay datos
        state = state.copyWith(
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: "Error al actualizar: $e",
        isLoading: false,
      );
    }
  }

  // Método para activar la alarma
  Future<void> activateAlarm() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Obtener datos del usuario actual
      final authState = _ref.read(authProvider);
      final userId = authState.userOrAdmin?.uuid ?? '';
      
      // Obtener ubicación actual
      final locationData = await _getCurrentLocation();
      
      // Crear la entidad para activar la alarma
      final alarmaEntitie = AlarmaEntitie(
        id_usuario: userId,
        id_grupo: '',
        tipo_usuario: authState.persona?.tipoPersona ?? "Usuario",
        direccion: locationData['direccion'] ?? "Dirección del usuario",
        coordenadas: locationData['coordenadas'] ?? "0.0,0.0",
        tipo_reporte: "Panico",
      );
      
      // Actualizar inmediatamente el estado para mejorar la experiencia de usuario
      state = state.copyWith(
        status: AlarmStatus.panic,
        statusText: 'Pánico',
        isActive: true,
      );
      
      // Llamar al método del repositorio para activar la alarma
      await _repository.ACTIVARALARMA(alarmaEntitie);
      
      // Actualizar estado final
      state = state.copyWith(isLoading: false);
      
      // Verificar estado después de un tiempo breve
      await Future.delayed(const Duration(milliseconds: 500));
      await refreshAlarmStatus();
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      // Refrescar estado en caso de error
      await refreshAlarmStatus();
    }
  }
  
  // Método para desactivar la alarma
  Future<void> deactivateAlarm() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final authState = _ref.read(authProvider);
      final userId = authState.userOrAdmin?.uuid ?? '';
      
      final locationData = await _getCurrentLocation();
      
      // Crear la entidad  desactivar la alarma
      final alarmaEntitie = AlarmaEntitie(
        id_usuario: userId,
        id_grupo: '',
        tipo_usuario: authState.persona?.tipoPersona ?? "Usuario",
        direccion: locationData['direccion'] ?? "Dirección del usuario",
        coordenadas: locationData['coordenadas'] ?? "0.0,0.0",
        tipo_reporte: "Seguro",
      );
      
      // Actualizar inmediatamente el estado para mejorar la experiencia de usuario
      state = state.copyWith(
        status: AlarmStatus.secure,
        statusText: 'Seguro',
        isActive: false,
      );
      
      // Llamar al método del repositorio para desactivar la alarma
      await _repository.DESACTIVARALARMA(alarmaEntitie);
      
      // Actualizar estado final
      state = state.copyWith(isLoading: false);
      
      // Verificar estado después de un tiempo breve
      await Future.delayed(const Duration(milliseconds: 500));
      await refreshAlarmStatus();
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      // Refrescar estado en caso de error
      await refreshAlarmStatus();
    }
  }
  
  // Método para cambiar el estado de la alarma según el estado actual
  Future<void> toggleAlarm() async {
    if (state.isActive) {
      await deactivateAlarm();
    } else {
      await activateAlarm();
    }
  }
}