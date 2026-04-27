import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<dynamic> _memories = [];
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
    if (_coupleId != null) _fetchMemories();
  }

  Future<void> _fetchMemories() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/api/memories/$_coupleId'),
        headers: {'x-access-token': _token ?? ''},
      );
      if (response.statusCode == 200) {
        setState(() {
          _memories.clear();
          _memories.addAll(jsonDecode(response.body));
        });
      }
    } catch (e) {
      print(e);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final titleController = TextEditingController();
      
      // Başlık için küçük bir dialog göster
      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Anıya Başlık Ekle"),
          content: TextField(controller: titleController, decoration: const InputDecoration(hintText: "Örn: İlk Tatilimiz")),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yükle")),
          ],
        ),
      );

      if (confirm == true) {
        setState(() => _isLoading = true);
        var request = http.MultipartRequest('POST', Uri.parse('$_serverUrl/api/memories/add'));
        request.headers['x-access-token'] = _token ?? '';
        request.fields['title'] = titleController.text;
        request.fields['coupleId'] = _coupleId.toString();
        request.files.add(await http.MultipartFile.fromPath('image', image.path));

        var response = await request.send();
        if (response.statusCode == 201) {
          _fetchMemories();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yükleme başarısız.")));
        }
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_coupleId == null) {
      return const Center(child: Text("Önce bir partnerle eşleşmelisiniz."));
    }

    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.network(
                          '$_serverUrl${memory['imageUrl']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          memory['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadImage,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
