import 'package:socket_io_client/socket_io_client.dart' as io;
import 'token_storage.dart';

class ChatSocket {
  ChatSocket._();
  static final ChatSocket instance = ChatSocket._();

  io.Socket? _socket;

  Future<io.Socket> connect() async {
    if (_socket != null && _socket!.connected) return _socket!;

    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Missing access token");
    }

    final socket = io.io(
      'http://localhost:4000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    socket.connect();
    _socket = socket;
    return socket;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
