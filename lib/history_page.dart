// File: lib/history_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/sensor_data_model.dart'; // Impor model data Anda

enum HistoryFilter { h1, h6, h24, d7, d30 }

class HistoryPage extends StatefulWidget {
  final String userId;
  const HistoryPage({super.key, required this.userId});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryFilter _selectedFilter = HistoryFilter.h24; // Filter default
  Stream<QuerySnapshot>? _historyStream;

  @override
  void initState() {
    super.initState();
    _updateHistoryStream();
  }

  void _updateHistoryStream() {
    DateTime startTime;
    final now = DateTime.now();

    switch (_selectedFilter) {
      case HistoryFilter.h1:
        startTime = now.subtract(const Duration(hours: 1));
        break;
      case HistoryFilter.h6:
        startTime = now.subtract(const Duration(hours: 6));
        break;
      case HistoryFilter.h24:
        startTime = now.subtract(const Duration(hours: 24));
        break;
      case HistoryFilter.d7:
        startTime = now.subtract(const Duration(days: 7));
        break;
      case HistoryFilter.d30:
        startTime = now.subtract(const Duration(days: 30));
        break;
    }

    setState(() {
      // Query sekarang merujuk ke sub-collection di bawah UID pengguna.
      _historyStream = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('history_data')
          .where('timestamp', isGreaterThanOrEqualTo: startTime)
          .orderBy('timestamp', descending: true)
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _historyStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Tidak ada data untuk rentang waktu ini."));
                }
                final List<SensorData> historyList = snapshot.data!.docs.map((doc) => SensorData.fromFirestore(doc)).toList();
                return Column(
                  children: [
                    _buildAverageCard(historyList),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Divider(color: Colors.grey[300]),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 0),
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryTile(historyList[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: HistoryFilter.values.map((filter) {
            final bool isSelected = _selectedFilter == filter;
            String label;
            switch(filter) {
              case HistoryFilter.h1: label = '1 Jam'; break;
              case HistoryFilter.h6: label = '6 Jam'; break;
              case HistoryFilter.h24: label = '24 Jam'; break;
              case HistoryFilter.d7: label = '7 Hari'; break;
              case HistoryFilter.d30: label = '30 Hari'; break;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      _selectedFilter = filter;
                      _updateHistoryStream();
                    });
                  }
                },
                selectedColor: Color(0xFF1976D2),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                backgroundColor: Colors.grey[200],
                shape: StadiumBorder(side: BorderSide(color: isSelected ? Color(0xFF1976D2) : Colors.grey.shade400)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // PERUBAHAN DI SINI: Kartu rata-rata sekarang menampilkan status
  Widget _buildAverageCard(List<SensorData> data) {
    if (data.isEmpty) return SizedBox.shrink();

    double totalTurbidity = data.fold(0, (sum, item) => sum + item.turbidity);
    double averageTurbidity = totalTurbidity / data.length;

    // Tentukan status dari nilai rata-rata
    final averageStatusData = SensorData(turbidity: averageTurbidity, timestamp: DateTime.now());
    Color statusColor;
    String statusText;
    switch (averageStatusData.status) {
      case WaterStatus.jernih:
        statusColor = Colors.blue.shade600;
        statusText = "Jernih";
        break;
      case WaterStatus.sedang:
        statusColor = Colors.orange.shade700;
        statusText = "Sedang";
        break;
      case WaterStatus.keruh:
        statusColor = Colors.brown.shade600;
        statusText = "Keruh";
        break;
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rata-rata Kekeruhan', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    Text('${averageTurbidity.toStringAsFixed(2)} NTU', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                Icon(Icons.query_stats, color: Colors.white, size: 40),
              ],
            ),
            Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kondisi Rata-rata:', style: TextStyle(fontSize: 16, color: Colors.white70)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(SensorData data) {
    Color statusColor;
    IconData statusIcon;
    switch (data.status) {
      case WaterStatus.jernih:
        statusColor = Colors.blue.shade600;
        statusIcon = Icons.check_circle;
        break;
      case WaterStatus.sedang:
        statusColor = Colors.orange.shade700;
        statusIcon = Icons.warning;
        break;
      case WaterStatus.keruh:
        statusColor = Colors.brown.shade600;
        statusIcon = Icons.dangerous;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(statusIcon, color: statusColor, size: 40),
        title: Text('${data.turbidity.toStringAsFixed(2)} NTU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('${data.timestamp.toLocal().day}/${data.timestamp.toLocal().month}/${data.timestamp.toLocal().year} - ${data.timestamp.toLocal().hour}:${data.timestamp.toLocal().minute.toString().padLeft(2, '0')}'),
        trailing: Text(data.status.name.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 12)),
      ),
    );
  }
}
