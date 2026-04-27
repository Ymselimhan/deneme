import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/server_config_screen.dart';
import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/music_screen.dart';
import 'screens/location_screen.dart';
import 'screens/gallery_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? serverUrl = prefs.getString('server_url');
  final String? token = prefs.getString('token');

  runApp(CouplesApp(
    initialUrl: serverUrl,
    isAuthenticated: token != null,
  ));
}

class CouplesApp extends StatefulWidget {
  final String? initialUrl;
  final bool isAuthenticated;

  const CouplesApp({super.key, this.initialUrl, this.isAuthenticated = false});

  @override
  State<CouplesApp> createState() => _CouplesAppState();
}

class _CouplesAppState extends State<CouplesApp> {
  late String? _serverUrl;
  late bool _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _serverUrl = widget.initialUrl;
    _isAuthenticated = widget.isAuthenticated;
  }

  void _refreshState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrl = prefs.getString('server_url');
      _isAuthenticated = prefs.getString('token') != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çift Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_serverUrl == null) {
      return ServerConfigScreen(onConfigured: _refreshState);
    }
    if (!_isAuthenticated) {
      return LoginScreen(onLoginSuccess: _refreshState);
    }
    return const MainDashboard();
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Anasayfa / Pano', style: TextStyle(fontSize: 24))),
    ChatScreen(),
    MusicScreen(),
    LocationScreen(),
    GalleryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💑 Çiftimiz'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Ayarlar"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text("Çıkış Yap"),
                        onTap: () async {
                          await AuthService().logout();
                          main();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Pano',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Müzik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Konum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Anılar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
