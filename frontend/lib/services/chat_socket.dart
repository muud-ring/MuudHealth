import 'package:socket_io_client/socket_io_client.dart' as io;
import 'token_storage.dart';

class ChatSocket {
  ChatSocket._();
  static final ChatSocket instance = ChatSocket._();

  // ✅ same pattern used in APIs
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.muudhealth.com',
  );

  io.Socket? _socket;

  Future<io.Socket> connect() async {
    if (_socket != null && _socket!.connected) return _socket!;

    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Missing access token");
    }

    final socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    socket.connect();
    _socket = socket;
    return socket;
  }

  io.Socket? get socket => _socket;

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
