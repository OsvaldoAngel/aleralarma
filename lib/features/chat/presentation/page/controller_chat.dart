import 'dart:async';

import 'package:aleralarma/features/auth/data/models/GruposUsuarioModel.dart';
import 'package:aleralarma/features/auth/data/provite/provite.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_controller.dart';
import 'package:aleralarma/features/chat/data/models/chat_model.dart';
import 'package:aleralarma/features/chat/data/repositories/chat_repository_imp.dart';
import 'package:aleralarma/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Modelo para el estado del controlador del chat
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingMessages; // Nuevo estado para controlar la carga de mensajes
  final String? currentUserId;
  final GruposUsuarioModel? gruposData;
  final String? currentGroupId;
  final String? currentGroupName;
  final String? errorMessage;

  ChatState({
    this.messages = const [],
    this.isLoading = true,
    this.isLoadingMessages = true, // Por defecto, asumimos que los mensajes están cargando
    this.currentUserId,
    this.gruposData,
    this.currentGroupId,
    this.currentGroupName,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingMessages,
    String? currentUserId,
    GruposUsuarioModel? gruposData,
    String? currentGroupId,
    String? currentGroupName,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      currentUserId: currentUserId ?? this.currentUserId,
      gruposData: gruposData ?? this.gruposData,
      currentGroupId: currentGroupId ?? this.currentGroupId,
      currentGroupName: currentGroupName ?? this.currentGroupName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Provider para el repositorio
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImp(ref);
});

// Provider para el controlador con el nuevo estado
final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatController(repository, ref);
});

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final Ref _ref;
  StreamSubscription? _messageSubscription;
  bool _isInitialized = false;
  
  // Set para rastrear mensajes ya recibidos y evitar duplicados
  final Set<String> _processedMessageIds = {};

  ChatController(this._repository, this._ref) : super(ChatState()) {
    _init();
  }
Future<void> _init() async {
  if (_isInitialized) return;
  
  try {
    // Iniciamos la inicialización
    state = state.copyWith(isLoading: true, isLoadingMessages: true);
    
    // Intentamos obtener el ID del usuario actual
    await _initializeUserId();
    
    // Intentamos obtener la información de grupos
    await _initializeGroupData();
    
    // Conectamos el socket para los mensajes
    await _repository.connectSocket();
    
    // Cancelar cualquier suscripción previa para evitar duplicados
    _messageSubscription?.cancel();
    
    // Suscribirse a los mensajes nuevos
    _messageSubscription = _repository.messageStream.listen(_handleNewMessage);
    
    // Completamos la inicialización de la UI principal
    state = state.copyWith(isLoading: false);
    
    // Intentar cargar mensajes históricos si están disponibles
    try {
      // Aquí puedes añadir una llamada para cargar mensajes históricos si tienes esa función
      // await _loadHistoricalMessages();
      
      // Después de un breve retraso o después de cargar los mensajes, marcamos que terminó la carga
      // Este retraso simula la carga de mensajes si no tienes una función real
      await Future.delayed(Duration(seconds: 1));
      
      // Finalizar la carga de mensajes
      state = state.copyWith(isLoadingMessages: false);
    } catch (e) {
      print('Error al cargar mensajes históricos: $e');
      state = state.copyWith(isLoadingMessages: false);
    }
    
    print('ChatController inicializado correctamente');
    _isInitialized = true;
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      isLoadingMessages: false,
      errorMessage: 'Error al inicializar chat: $e',
    );
    print('Error al inicializar ChatController: $e');
  }
}
  
  // Método para inicializar el ID del usuario
  Future<void> _initializeUserId() async {
    // Obtener el ID del usuario
    final authState = _ref.read(authProvider);
    if (authState.userOrAdmin != null) {
      state = state.copyWith(currentUserId: authState.userOrAdmin!.uuid);
      print('ID de usuario actual inicializado: ${state.currentUserId}');
    } else {
      // Si userOrAdmin es null, intenta obtener los datos del usuario
      final authNotifier = _ref.read(authProvider.notifier);
      await authNotifier.checkAuthStatus();
      
      // Ahora verificamos nuevamente si tenemos el ID
      final updatedAuthState = _ref.read(authProvider);
      if (updatedAuthState.userOrAdmin != null) {
        state = state.copyWith(currentUserId: updatedAuthState.userOrAdmin!.uuid);
        print('ID de usuario recuperado después de checkAuthStatus: ${state.currentUserId}');
      } else {
        print('ADVERTENCIA: No se pudo obtener el ID de usuario');
      }
    }
  }
  
  // Método para inicializar los datos del grupo
  Future<void> _initializeGroupData() async {
    try {
      // Obtener el ID de grupo actual
      final authRepository = _ref.read(authRepositoryProvider);
      final grupos = await authRepository.getGruposData();

      if (grupos != null && grupos.grupos.isNotEmpty) {
        state = state.copyWith(
          gruposData: grupos,
          currentGroupId: grupos.grupos.first.grupoId,
          currentGroupName: grupos.grupos.first.grupoLugar.toUpperCase(),
        );
        
        // Actualizar el grupo en el chat repository si es necesario
        if (state.currentGroupId != null) {
          _repository.updateGroupId(state.currentGroupId!);
        }
        
        print('Grupo inicializado: ${state.currentGroupName} (${state.currentGroupId})');
      }
    } catch (e) {
      print('Error al inicializar datos de grupo: $e');
    }
  }
  
  void _handleNewMessage(ChatMessage message) {
  // Verificar si el mensaje tiene contenido
  if (message.message.isEmpty) {
    print('Mensaje recibido vacío, ignorando');
    return;
  }
  
  // Generamos un ID único para el mensaje basado en su contenido y remitente
  final messageId = '${message.userId}-${message.message}-${message.timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';
  
  // Verificar si ya procesamos este mensaje
  if (_processedMessageIds.contains(messageId)) {
    print('Mensaje duplicado ignorado: $messageId');
    return;
  }
  
  // Comprobar si el mensaje es mío (enviado por el usuario actual)
  final isMyMessage = state.currentUserId != null && message.userId == state.currentUserId;
  
  // Si es mi propio mensaje y viene del servidor, podemos ignorarlo
  // ya que ya lo mostramos localmente cuando el usuario lo envió
  if (isMyMessage) {
    // Verificamos si ya existe un mensaje con el mismo texto y autor en el estado
    final messageExists = state.messages.any((existingMsg) => 
      existingMsg.userId == message.userId && 
      existingMsg.message == message.message &&
      (existingMsg.timestamp?.difference(message.timestamp ?? DateTime.now()).inSeconds ?? 0).abs() < 5
    );
    
    if (messageExists) {
      print('Mensaje propio ya existente, se ignora el duplicado del servidor');
      _processedMessageIds.add(messageId);
      return;
    }
  }
  
  print('Nuevo mensaje recibido: ${message.message} de ${message.username} (ID: ${message.userId})');
  
  // Añadimos timestamp si no existe
  final updatedMessage = message.timestamp == null
      ? message.copyWith(timestamp: DateTime.now())
      : message;
  
  // Registrar que hemos procesado este mensaje
  _processedMessageIds.add(messageId);
  
  // Limitar el tamaño del conjunto para evitar fugas de memoria
  if (_processedMessageIds.length > 100) {
    final oldest = _processedMessageIds.first;
    _processedMessageIds.remove(oldest);
  }
  
  // Añadir el mensaje al estado
  state = state.copyWith(
    messages: [...state.messages, updatedMessage]
  );
}
void sendMessage(String message) {
  if (message.trim().isEmpty) return;
  
  try {
    // Obtenemos información del usuario actual para el mensaje
    final authState = _ref.read(authProvider);
    String? username;
    String userId = 'unknown_user';
    
    if (authState.userOrAdmin != null) {
      userId = authState.userOrAdmin!.uuid;
      // Actualizar el ID del usuario actual en el estado
      if (state.currentUserId != userId) {
        state = state.copyWith(currentUserId: userId);
      }
    }
    
    if (authState.persona != null) {
      username = '${authState.persona!.nombre} ${authState.persona!.primerApellido}';
    } else if (authState.userOrAdmin != null) {
      username = authState.userOrAdmin!.uuid ?? 'Usuario';
    }
    
    print('Enviando mensaje como: $username (ID: $userId) en grupo: ${state.currentGroupId}');
    
    // Crear un mensaje local con una marca de tiempo precisa
    final timestamp = DateTime.now();
    
    final newMessage = ChatMessage(
      userId: userId,
      username: username,
      message: message,
      timestamp: timestamp,
      groupId: state.currentGroupId,
    );
    
    // Generar un ID único para este mensaje (incluyendo la marca de tiempo precisa)
    final messageId = '${userId}-${message}-${timestamp.millisecondsSinceEpoch}';
    
    // Registrar que ya hemos procesado este mensaje
    _processedMessageIds.add(messageId);
    
    // Añadir el mensaje al estado para mostrar inmediatamente
    state = state.copyWith(
      messages: [...state.messages, newMessage]
    );
    
    // Enviar el mensaje al servidor
    _repository.sendMessage(message);
  } catch (e) {
    print('Error al enviar mensaje: $e');
  }
}
  
  // Método para cambiar de grupo
  void changeGroup(String groupId) {
  // Buscar el grupo seleccionado
  final selectedGroup = state.gruposData?.grupos.firstWhere(
    (g) => g.grupoId == groupId,
    orElse: () => state.gruposData!.grupos.first,
  );
  
  // Actualizar el estado con el nuevo grupo y marcar que estamos cargando mensajes
  // IMPORTANTE: Mantenemos los mensajes existentes vacíos mientras se carga
  state = state.copyWith(
    currentGroupId: groupId,
    currentGroupName: selectedGroup?.grupoLugar.toUpperCase() ?? 'GRUPO',
    isLoadingMessages: true,
    messages: [] // Limpiamos los mensajes inmediatamente
  );
  
  // Ya no necesitamos llamar a clearMessages aquí porque ya limpiamos los mensajes arriba
  // Eliminamos la llamada a clearMessages();
  
  // Actualizar el ID de grupo en el repositorio
  _repository.updateGroupId(groupId);
  
  print('Grupo cambiado a: ${state.currentGroupName} (${state.currentGroupId})');
  
  // Como antes, después de un tiempo prudencial, si no han llegado mensajes,
  // desactivamos el estado de carga
  Future.delayed(Duration(seconds: 2), () {
    // Solo cambiamos a false si aún no han llegado mensajes
    if (state.messages.isEmpty && state.isLoadingMessages) {
      state = state.copyWith(isLoadingMessages: false);
    }
  });
}

  
  // Método para verificar si un mensaje es mío
  bool isMyMessage(String userId) {
    return state.currentUserId != null && userId == state.currentUserId;
  }
  
  // Método para formatear la hora del mensaje
  String formatMessageTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    // Para mensajes de hoy, solo mostrar la hora
    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else {
      // Para otros días, incluir la fecha
      return DateFormat('dd/MM/yy HH:mm').format(timestamp);
    }
  }
  
  // Método para verificar si dos fechas corresponden al mismo día
  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  // Método para formatear la fecha en los separadores
  String formatDateForSeparator(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Hoy';
    } else if (messageDate == yesterday) {
      return 'Ayer';
    } else {
      return DateFormat('EEEE d MMMM', 'es').format(timestamp);
    }
  }
  
  // Método para limpiar los mensajes
  void clearMessages() {
    _processedMessageIds.clear();
    state = state.copyWith(messages: []);
    print('Mensajes limpiados');
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}