import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final List<dynamic> _songs = [];
  bool _isLoading = false;
  String? _serverUrl;
  int? _coupleId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrl = prefs.getString('server_url');
      _coupleId = prefs.getInt('coupleId');
      _token = prefs.getString('token');
    });
    if (_coupleId != null) _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/api/music/$_coupleId'),
        headers: {'x-access-token': _token ?? ''},
      );
      if (response.statusCode == 200) {
        setState(() => _songs.assignAll(jsonDecode(response.body)));
      }
    } catch (e) {
      print(e);
    }
    setState(() => _isLoading = false);
  }

  void _showAddSongDialog() {
    final titleController = TextEditingController();
    final artistController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yeni Şarkı Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Şarkı Adı")),
            TextField(controller: artistController, decoration: const InputDecoration(labelText: "Sanatçı")),
            TextField(controller: urlController, decoration: const InputDecoration(labelText: "Link (Spotify/YT)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              await http.post(
                Uri.parse('$_serverUrl/api/music/add'),
                headers: {
                  'Content-Type': 'application/json',
                  'x-access-token': _token ?? ''
                },
                body: jsonEncode({
                  'title': titleController.text,
                  'artist': artistController.text,
                  'url': urlController.text,
                  'coupleId': _coupleId
                }),
              );
              Navigator.pop(context);
              _fetchSongs();
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_coupleId == null) {
      return const Center(child: Text("Önce bir partnerle eşleşmelisiniz."));
    }

    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _songs.length,
            itemBuilder: (context, index) {
              final song = _songs[index];
              return ListTile(
                leading: const Icon(Icons.music_note, color: Colors.pinkAccent),
                title: Text(song['title']),
                subtitle: Text(song['artist'] ?? 'Bilinmeyen Sanatçı'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    await http.delete(
                      Uri.parse('$_serverUrl/api/music/${song['id']}'),
                      headers: {'x-access-token': _token ?? ''},
                    );
                    _fetchSongs();
                  },
                ),
                onTap: () {
                  // Linke tıklandığında tarayıcıda açma eklenebilir
                },
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSongDialog,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

extension ListExtension on List {
  void assignAll(Iterable<dynamic> iterable) {
    clear();
    addAll(iterable);
  }
}
