import 'dart:convert';

import 'package:duxbe/features/auth/auth.dart';
// Import your Freezed models (adjust path if you put them in a separate file)
import 'package:duxbe/shared/shared.dart'; // Or 'your_path/socket_notifier.dart' if in the same file
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_socket_provider.g.dart'; // For Riverpod generator

// Assuming your supabaseProvider gives access to user and session
// final supabaseProvider = Provider((ref) => Supabase.instance.client);
// const String WEBSOCKET_BASE_URL = "ws://localhost:1337"; // DEV
const String WEBSOCKET_BASE_URL = 'wss://dashboard.duxbe.com'; // PROD

@Riverpod(keepAlive: true)
class SocketNotifier extends _$SocketNotifier {
  WebSocketChannel? _channel;
  String? _userId;
  String? _accessToken;
  String? _businessId;
  bool _isDisposed = false;
  final Uuid _uuid = const Uuid();

  @override
  List<ChatMessage> build() {
    // State is now List<ChatMessage>
    // Assuming supabaseProvider is available and provides user details synchronously.
    // If not, you'll need an AsyncValue state and initialize later.
    // _userId = ref.watch(supabaseProvider).auth.currentUser?.id;
    // _accessToken = ref.watch(supabaseProvider).auth.currentSession?.accessToken;

    // Placeholder for userId and accessToken - replace with your actual auth logic
    _userId = ref.watch(authStateProvider).value?.session?.user.id; // Example static user ID
    _accessToken = ref.watch(authStateProvider).value?.session?.accessToken; // Example token
    _businessId = ref.watch(businessNotifierProvider)?.businessId;
    if (_userId != null) {
      state = [];
      _initializeSocket();
    } else {
      debugPrint('SocketNotifier: User ID is null. WebSocket not initialized.');
      // Optionally add a system message if you want to show this in UI immediately
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   _addSystemMessage("Connection failed: User not identified.");
      // });
    }

    ref.onDispose(() {
      debugPrint('SocketNotifier: Disposing.');
      _isDisposed = true;
      _channel?.sink.close();
    });
    return [];
  }

  void _initializeSocket() {
    if (_userId == null) {
      debugPrint('SocketNotifier: Cannot initialize, userId is null.');
      _addSystemMessage('Connection failed: User not identified.');
      return;
    }
    if (_channel != null && _channel?.closeCode == null) {
      debugPrint('SocketNotifier: Already connected or connecting.');
      return;
    }

    _isDisposed = false;

    // --- DETAILED URL LOGGING ---
    debugPrint('SocketNotifier: --- URL Construction Details ---');
    debugPrint("SocketNotifier: 1. WEBSOCKET_BASE_URL: '$WEBSOCKET_BASE_URL'");
    debugPrint("SocketNotifier: 2. _userId: '$_userId'");

    final rawWsUrlString = '$WEBSOCKET_BASE_URL/ws/$_userId';
    debugPrint("SocketNotifier: 3. Raw constructed URL string: '$rawWsUrlString'");

    Uri? parsedUri;
    try {
      parsedUri = Uri.parse(rawWsUrlString);
      debugPrint('SocketNotifier: 4. Uri.parse successful.');
      debugPrint('SocketNotifier:    - Scheme: ${parsedUri.scheme}');
      debugPrint('SocketNotifier:    - Host: ${parsedUri.host}');
      debugPrint('SocketNotifier:    - Port: ${parsedUri.port}'); // <<< THIS IS KEY
      debugPrint('SocketNotifier:    - Path: ${parsedUri.path}');
      debugPrint('SocketNotifier:    - Query: ${parsedUri.query}');
      debugPrint('SocketNotifier:    - Fragment: ${parsedUri.fragment}');
      debugPrint('SocketNotifier:    - userInfo: ${parsedUri.userInfo}');
      debugPrint('SocketNotifier:    - hasPort: ${parsedUri.hasPort}');
      // debugPrint("SocketNotifier:    - origin: ${parsedUri.origin}");
      debugPrint('SocketNotifier:    - authority: ${parsedUri.authority}');
    } catch (e) {
      debugPrint('SocketNotifier: 4. Uri.parse FAILED: $e');
      _addSystemMessage('Error: Invalid WebSocket URL format.');
      state = List.from(state);
      _channel?.sink.close();
      _channel = null;
      _reconnect(); // Or handle more gracefully
      return;
    }
    debugPrint('SocketNotifier: --- End URL Construction Details ---');
    // --- END DETAILED URL LOGGING ---

    final wsUrlForConnect = parsedUri; // Use the parsed URI object

    debugPrint('SocketNotifier: Connecting to URI object: $wsUrlForConnect');

    try {
      // Use the Uri object directly with IOWebSocketChannel.connect
      _channel = WebSocketChannel.connect(
        wsUrlForConnect, // Pass the Uri object
        // headers: { if (_accessToken != null) 'Authorization': 'Bearer $_accessToken' },
      );

      _addSystemMessage('Connecting to chat server...');

      _channel!.stream.listen(
        (data) {
          // ... (rest of your listen logic)
          debugPrint('SocketNotifier: WebSocketChannel Stream Data: $data');
          _addReceivedMessage(json.decode(data.toString()) as Map<String, dynamic>);
        },
        onError: (error) {
          if (_isDisposed) return;
          // Log the error as it comes from the channel
          debugPrint('SocketNotifier: WebSocketChannel Stream Error: $error');
          _addSystemMessage(
            'Connection error: ${error.toString().substring(0, (error.toString().length > 100 ? 100 : error.toString().length))}...',
          );
          state = List.from(state);
          _reconnect();
        },
        onDone: () {
          // ... (rest of your onDone logic)
        },
      );
      _addSystemMessage('Connection attempt initiated...');
    } catch (e) {
      // This catch block is for synchronous errors during IOWebSocketChannel.connect setup
      debugPrint('SocketNotifier: Failed to establish WebSocket connection (synchronous error): $e');
      _addSystemMessage('Failed to establish connection.');
      state = List.from(state);
      _reconnect();
    }
  }

  void _reconnect() {
    if (_isDisposed) {
      debugPrint('SocketNotifier: Not reconnecting, already disposed.');
      return;
    }
    _addSystemMessage('Attempting to reconnect...');
    debugPrint('SocketNotifier: Attempting to reconnect in 3 seconds...');
    _channel?.sink.close();
    _channel = null;
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isDisposed) {
        _initializeSocket();
      }
    });
  }

  void _addSystemMessage(String text) {
    final systemMessage = ChatMessage(
      id: _uuid.v4(),
      source: MessageSource.system,
      text: text,
      timestamp: DateTime.now(),
    );
    state = [...state, systemMessage];
  }

  void _addReceivedMessage(Map<String, dynamic> responseData) {
    // --- Crucial part: Mapping server JSON to your Freezed models ---
    // This needs to align perfectly with what your Python backend sends.

    // Extract buttons carefully
    List<ChatMessageButton>? buttons;
    if (responseData['buttons'] is List) {
      buttons = (responseData['buttons'] as List)
          .map((b) {
            if (b is Map<String, dynamic>) {
              // Handle the case where button data might be nested or have 'text' as alias for 'title'
              var title = b['title'] as String?;
              if (title == null && b['text'] is String) {
                title = b['text'] as String;
              }
              if (b['id'] is String && title != null) {
                return ChatMessageButton(id: b['id'] as String, title: title);
              }
            }
            return null; // Or throw error, or return a default button
          })
          .whereType<ChatMessageButton>()
          .toList(); // Filter out nulls
      if (buttons.isEmpty) buttons = null; // Set back to null if no valid buttons
    }

    // Extract document carefully
    ChatMessageDocument? document;
    if (responseData['document'] is Map<String, dynamic>) {
      try {
        document = ChatMessageDocument.fromJson(responseData['document'] as Map<String, dynamic>);
      } catch (e) {
        debugPrint("Error parsing document: $e. Document data: ${responseData['document']}");
      }
    }

    final receivedMessage = ChatMessage(
      id: responseData['id'] as String? ?? _uuid.v4(), // Use server ID if provided
      source: MessageSource.received,
      text: responseData['text'] as String? ?? responseData['message'] as String? ?? '',
      buttons: buttons,
      document: document,
      fileUrl: responseData['file_url'] as String?,
      messageType: responseData['message_type'] as String?,
      timestamp: DateTime.now(), // Or parse from server if timestamp is sent
    );
    state = [...state, receivedMessage];
  }

  void sendMessage(String messageText) {
    if (_channel == null || _channel!.closeCode != null) {
      debugPrint('SocketNotifier: Socket not connected. Attempting to reconnect.');
      _addSystemMessage('Not connected. Please wait...');
      if (!_isDisposed) _reconnect();
      return;
    }
    if (_userId == null) {
      debugPrint('SocketNotifier: Cannot send message, userId is null.');
      _addSystemMessage('Error: User not identified. Cannot send message.');
      return;
    }

    final messageData = {
      'message': messageText,
      'user_id': _userId,
      'business_id': _businessId,
      'message_type': 'text',
      'metadata': {},
    };

    _channel!.sink.add(json.encode(messageData));

    final sentMessage = ChatMessage(
      id: _uuid.v4(),
      source: MessageSource.sent,
      text: messageText,
      timestamp: DateTime.now(),
    );
    state = [...state, sentMessage];
  }

  void sendButtonClick(ChatMessageButton button) {
    if (_channel == null || _channel!.closeCode != null) {
      debugPrint('SocketNotifier: Socket not connected for button click.');
      _addSystemMessage('Not connected. Please wait...');
      if (!_isDisposed) _reconnect();
      return;
    }
    if (_userId == null) {
      debugPrint('SocketNotifier: Cannot send button click, userId is null.');
      _addSystemMessage('Error: User not identified. Cannot send message.');
      return;
    }

    final messageData = {
      'message': button.id.isNotEmpty ? button.id : button.title,
      'user_id': _userId,
      'business_id': _businessId,
      'message_type': 'button_click',
      'metadata': {'button_id': button.id, 'button_title': button.title},
    };

    _channel!.sink.add(json.encode(messageData));

    final sentMessage = ChatMessage(
      id: _uuid.v4(),
      source: MessageSource.sent,
      text: '[Button Clicked: ${button.title}]',
      timestamp: DateTime.now(),
    );
    state = [...state, sentMessage];
  }

  void disconnectManual() {
    debugPrint('SocketNotifier: Manual disconnect called.');
    _isDisposed = true;
    _channel?.sink.close(1000, 'User logged out');
    _channel = null;
    _addSystemMessage('Disconnected by user.');
  }

  void ensureConnected() {
    // Re-fetch or confirm _userId and _accessToken if necessary
    // _userId = ref.read(supabaseProvider).auth.currentUser?.id;
    // _accessToken = ref.read(supabaseProvider).auth.currentSession?.accessToken;
    _userId = '6baaf025-a270-45b6-8b8d-cbbdd73b2f8e'; // Ensure it's set
    _accessToken = 'your_dummy_access_token';

    if (_userId != null && (_channel == null || _channel!.closeCode != null) && !_isDisposed) {
      debugPrint('SocketNotifier: ensureConnected - User ID available, ensuring connection.');
      _initializeSocket();
    } else if (_userId == null) {
      debugPrint('SocketNotifier: ensureConnected - User ID still null.');
      _addSystemMessage('Cannot connect: User not identified.');
    } else {
      debugPrint('SocketNotifier: ensureConnected - Already connected or attempting.');
    }
  }
}
