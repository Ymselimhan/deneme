import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/socket_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final SocketService _socketService = SocketService();
  int? _userId;
  int? _coupleId;
  String? _serverUrl;

  @override
  void initState() {
    super.initState();
    _loadDataAndInitSocket();
  }

  Future<void> _loadDataAndInitSocket() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    _coupleId = prefs.getInt('coupleId');
    _serverUrl = prefs.getString('server_url');

    if (_coupleId != null) {
      await _socketService.initSocket();
      _socketService.socket.emit('join_room', _coupleId);

      _socketService.socket.on('receive_message', (data) {
        if (mounted) {
          setState(() {
            _messages.add(data);
          });
        }
      });

      _fetchHistory();
    }
  }

  Future<void> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final response = await http.get(
      Uri.parse('$_serverUrl/api/chat/history/$_coupleId'),
      headers: {'x-access-token': token ?? ''},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _messages.clear();
        _messages.addAll(data.map((m) => {
          'text': m['text'],
          'senderId': m['senderId'],
        }));
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && _coupleId != null) {
      _socketService.sendMessage(
        _coupleId.toString(),
        _controller.text,
        _userId!.toString(),
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_coupleId == null) {
      return const Center(child: Text("Önce bir partnerle eşleşmelisiniz."));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isMe = msg['senderId'] == _userId;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.pinkAccent : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    msg['text'] ?? msg['message'] ?? '',
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Mesaj yazın...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.pinkAccent),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
