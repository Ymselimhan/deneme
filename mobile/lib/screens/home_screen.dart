import 'package:flutter/material.dart';
import '../services/date_service.dart';
import '../models/special_date.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateService _dateService = DateService();
  List<SpecialDate> _dates = [];
  bool _isLoading = true;
  Timer? _timer;
  Duration _timeLeft = const Duration();
  SpecialDate? _nextDate;

  @override
  void initState() {
    super.initState();
    _loadDates();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextDate != null) {
        setState(() {
          _timeLeft = _nextDate!.date.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDates() async {
    try {
      final dates = await _dateService.getSpecialDates();
      setState(() {
        _dates = dates;
        _isLoading = false;
        _findNextDate();
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _findNextDate() {
    if (_dates.isEmpty) return;
    final now = DateTime.now();
    final futureDates = _dates.where((d) => d.date.isAfter(now)).toList();
    if (futureDates.isNotEmpty) {
      futureDates.sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        _nextDate = futureDates.first;
      });
    }
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return "00:00:00:00";
    int days = d.inDays;
    int hours = d.inHours.remainder(24);
    int minutes = d.inMinutes.remainder(60);
    int seconds = d.inSeconds.remainder(60);
    return "${days.toString().padLeft(2, '0')}g ${hours.toString().padLeft(2, '0')}s ${minutes.toString().padLeft(2, '0')}d ${seconds.toString().padLeft(2, '0')}sn";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDates,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildCountdownHeader(),
                    _buildDatesList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDateDialog,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCountdownHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.orangeAccent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Sıradaki Özel Gün",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 8),
          Text(
            _nextDate?.title ?? "Özel Gün Ayarlanmadı",
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formatDuration(_timeLeft),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.mono,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_nextDate != null)
            Text(
              "${_nextDate!.date.day}.${_nextDate!.date.month}.${_nextDate!.date.year}",
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildDatesList() {
    if (_dates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("Henüz özel bir gün eklemediniz.", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tüm Özel Günler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final date = _dates[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: _getTypeColor(date.type).withOpacity(0.1),
                    child: Icon(_getTypeIcon(date.type), color: _getTypeColor(date.type)),
                  ),
                  title: Text(date.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${date.date.day}/${date.date.month}/${date.date.year}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _deleteDate(date.id),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'anniversary': return Colors.redAccent;
      case 'birthday': return Colors.blueAccent;
      default: return Colors.orangeAccent;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'anniversary': return Icons.favorite;
      case 'birthday': return Icons.cake;
      default: return Icons.star;
    }
  }

  void _deleteDate(int id) async {
    try {
      await _dateService.deleteSpecialDate(id);
      _loadDates();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showAddDateDialog() {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'anniversary';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Özel Gün Ekle", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Başlık (örn: Tanışma Yıldönümü)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text("Tarih: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setModalState(() => selectedDate = picked);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'anniversary', child: Text("Yıldönümü")),
                  DropdownMenuItem(value: 'birthday', child: Text("Doğum Günü")),
                  DropdownMenuItem(value: 'other', child: Text("Diğer")),
                ],
                onChanged: (v) => setModalState(() => selectedType = v!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty) return;
                    await _dateService.createSpecialDate(titleController.text, selectedDate, selectedType, null);
                    Navigator.pop(context);
                    _loadDates();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white),
                  child: const Text("Kaydet"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
