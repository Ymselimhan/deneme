import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketService {
  late IO.Socket socket;

  Future<void> initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final String? serverUrl = prefs.getString('server_url');
    
    if (serverUrl == null) return;

    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Bağlantı başarılı: ${socket.id}');
    });

    socket.onDisconnect((_) => print('Bağlantı kesildi'));
  }

  void sendMessage(String room, String message, String sender) {
    socket.emit('send_message', {
      'room': room,
      'message': message,
      'sender': sender,
    });
  }

  void updateLocation(String room, double lat, double lng, String sender) {
    socket.emit('update_location', {
      'room': room,
      'lat': lat,
      'lng': lng,
      'sender': sender,
    });
  }
}
