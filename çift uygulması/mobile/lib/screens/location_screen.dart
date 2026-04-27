import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/socket_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  final SocketService _socketService = SocketService();
  
  LatLng? _myLocation;
  LatLng? _partnerLocation;
  String? _partnerName;
  
  int? _userId;
  int? _coupleId;
  String? _serverUrl;
  String? _token;
  
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _loadDataAndInit();
  }

  Future<void> _loadDataAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    _coupleId = prefs.getInt('coupleId');
    _serverUrl = prefs.getString('server_url');
    _token = prefs.getString('token');

    if (_coupleId != null) {
      await _socketService.initSocket();
      _socketService.socket.emit('join_room', _coupleId);

      _socketService.socket.on('location_updated', (data) {
        if (data['senderId'] != _userId.toString() && mounted) {
          setState(() {
            _partnerLocation = LatLng(data['lat'], data['lng']);
          });
        }
      });

      _fetchPartnerInitialLocation();
      _startLocationTracking();
    }
  }

  Future<void> _fetchPartnerInitialLocation() async {
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/api/user/partner-location/$_coupleId'),
        headers: {'x-access-token': _token ?? ''},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _partnerName = data['username'];
          if (data['lastLat'] != null && data['lastLng'] != null) {
            _partnerLocation = LatLng(data['lastLat'], data['lastLng']);
          }
        });
      }
    } catch (e) {
      print("Partner konumu çekilemedi: $e");
    }
  }

  void _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _myLocation = LatLng(position.latitude, position.longitude);
        });

        _socketService.socket.emit('update_location', {
          'room': _coupleId,
          'lat': position.latitude,
          'lng': position.longitude,
          'senderId': _userId
        });
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_coupleId == null) {
      return const Center(child: Text("Önce bir partnerle eşleşmelisiniz."));
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _myLocation ?? const LatLng(41.0082, 28.9784),
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ciftapp.app',
            ),
            MarkerLayer(
              markers: [
                if (_myLocation != null)
                  Marker(
                    point: _myLocation!,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                  ),
                if (_partnerLocation != null)
                  Marker(
                    point: _partnerLocation!,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.favorite, color: Colors.pink, size: 40),
                  ),
              ],
            ),
          ],
        ),
        if (_partnerLocation == null)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: const Text("Partnerinizin konumu bekleniyor...", textAlign: TextAlign.center),
            ),
          ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              if (_myLocation != null) {
                _mapController.move(_myLocation!, 15);
              }
            },
            child: const Icon(Icons.my_location),
          ),
        )
      ],
    );
  }
}
