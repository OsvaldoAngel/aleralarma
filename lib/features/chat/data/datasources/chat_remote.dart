import 'dart:async';
import 'dart:convert';
import 'package:aleralarma/common/constants/constants.dart';
import 'package:aleralarma/features/chat/data/models/chat_model.dart';
import 'package:aleralarma/framework/preferences_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;
  final _messageController = StreamController<ChatMessage>.broadcast();
  
  String? _userId;
  String? _groupId;
  bool _isInitialized = false;
  bool _isConnecting = false;
  bool _socketInitialized = false;
  
  String get defaultApiServer => AppConstants.serverBase;
  
  SocketService() {
  }
  
  Future<void> _initVariables() async {
    if (_isInitialized) return;
    
    _isInitialized = true; 
    
    final prefs = PreferencesUser();
    
    String? userDataJson = await prefs.loadPrefs(type: String, key: AppConstants.prefUserData);
    if (userDataJson != null && userDataJson.isNotEmpty) {
      try {
        final userData = jsonDecode(userDataJson);
        _userId = userData['uuid'];
        print('UserID cargado de preferencias: $_userId');
      } catch (e) {
        print('Error al decodificar datos de usuario: $e');
      }
    }
    
    // Cargar ID de grupo
    _groupId = await prefs.loadPrefs(type: String, key: AppConstants.prefGrupoId);
    print('GroupID cargado de preferencias: $_groupId');
    
  }

  void _initSocket() {
    if (_socketInitialized && socket != null) {
      print('Socket ya inicializado, no se creará uno nuevo');
      return;
    }
    
    _socketInitialized = true;
    
    socket = IO.io(defaultApiServer, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'forceNew': false, // Evitar crear nuevas conexiones
    });
    
    socket!.onConnect((_) {
      print('🟢 Conectado al socket');
      print('Uniéndose al grupo con userId: $_userId, groupId: $_groupId');
      joinGroup();
    });
    
    // Eliminar listeners anteriores para evitar duplicados
    socket!.off('recibir_mensaje');
    socket!.off('historial_mensajes');
    
    socket!.on('recibir_mensaje', (data) {
      print('📩 Mensaje recibido: $data');
      try {
        final message = ChatMessage.fromJson(data);
        _messageController.add(message);
      } catch (e) {
        print('❌ Error al procesar mensaje recibido: $e');
      }
    });
    
    socket!.on('historial_mensajes', (data) {
      print('📚 Historial recibido con ${data.length} mensajes');
      try {
        for (var msg in data) {
          final message = ChatMessage.fromJson(msg);
          _messageController.add(message);
        }
      } catch (e) {
        print('❌ Error al procesar historial: $e');
      }
    });
    
    socket!.on('error', (error) {
      print('❌ Error de socket: $error');
    });
    
    socket!.on('disconnect', (_) {
      print('🔴 Desconectado del socket');
    });
    
    socket!.on('connect_error', (error) {
      print('❌ Error de conexión: $error');
    });
  }
  
  void joinGroup() {
    if (socket != null && socket!.connected && _userId != null && _groupId != null) {
      print('👥 Uniendo al grupo: $_groupId');
      socket!.emit('unirse_grupo', {
        'id_usuario': _userId,
        'id_grupo': _groupId,
      });
    } else {
      print('⚠️ No se pudo unir al grupo: Socket o IDs no disponibles');
    }
  }

  Future<void> connect() async {
    if (_isConnecting) {
      print('⚠️ Ya hay una conexión en progreso');
      return;
    }
    
    _isConnecting = true;
    
    try {
      // Asegurarse de que los IDs estén cargados antes de conectar
      if (!_isInitialized) {
        await _initVariables();
      }
      
      // Inicializar socket si es necesario
      if (!_socketInitialized || socket == null) {
        _initSocket();
      }
      
      if (socket != null && !socket!.connected) {
        print('🔄 Conectando socket con userId: $_userId, groupId: $_groupId');
        socket!.connect();
      } else if (socket != null && socket!.connected) {
        print('👌 Socket ya conectado');
        // Asegurarse de que estamos en el grupo correcto
        joinGroup();
      }
    } finally {
      _isConnecting = false;
    }
  }

  void disconnect() {
    if (socket != null) {
      print('🔴 Desconectando socket');
      socket!.disconnect();
    }
  }

  void emitMessage(String message) {
    if (socket == null) {
      print('⚠️ Socket no inicializado');
      _initSocket();
    }
    
    if (socket != null && !socket!.connected) {
      print('🔄 Socket no conectado. Intentando reconectar...');
      socket!.connect();
    }
    
    if (socket != null && socket!.connected && _userId != null && _groupId != null) {
      print('📤 Enviando mensaje: $message');
      socket!.emit('enviar_mensaje', {
        'id_usuario': _userId,
        'id_grupo': _groupId,
        'mensaje': message,
      });
    } else {
      print('❌ No se pudo enviar el mensaje: ${socket?.connected}');
    }
  }

  Stream<ChatMessage> get messageStream => _messageController.stream;
  
  void updateUserId(String newUserId) {
    print('🔄 Actualizando ID de usuario: $newUserId');
    _userId = newUserId;
    _reconnectWithNewSettings();
  }
  
  void updateGroupId(String newGroupId) {
    print('🔄 Actualizando ID de grupo: $newGroupId');
    _groupId = newGroupId;
    _reconnectWithNewSettings();
  }
  
  void _reconnectWithNewSettings() {
    if (socket != null && socket!.connected) {
      print('🔄 Reconectando con nuevos ajustes');
      socket!.disconnect();
      
      // Pequeño retraso para asegurar desconexión completa
      Future.delayed(Duration(milliseconds: 300), () {
        socket!.connect();
      });
    }
  }
  
  void dispose() {
    print('🧹 Limpiando recursos de socket');
    disconnect();
    _messageController.close();
    socket = null;
    _socketInitialized = false;
    _isInitialized = false;
  }
}