import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'hotel_management_screen.dart'; 

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final data = await AdminService().getDashboardStats();
    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _exportCsv() async {
    final csvData = await AdminService().downloadReport();
    if (csvData != null && mounted) {
      // Karena keterbatasan permission di tutorial singkat, 
      // kita tampilkan CSV di Dialog agar bisa di-copy admin.
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Data CSV Berhasil Diambil"),
          content: SingleChildScrollView(
            child: SelectableText(csvData), // Bisa dicopy
          ),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Tutup"))
          ],
        ),
      );
    }
  }

  void _logout() {
    AuthService().logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _exportCsv, icon: const Icon(Icons.download), tooltip: "Export Laporan"),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text("Gagal memuat data"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. KARTU RINGKASAN
                      Row(
                        children: [
                          _buildStatCard("Pendapatan", "Rp ${_formatCurrency(_stats!['summary']['totalRevenue'])}", Colors.green),
                          const SizedBox(width: 10),
                          _buildStatCard("Booking", "${_stats!['summary']['totalBookings']}", Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildStatCard("User", "${_stats!['summary']['totalUsers']}", Colors.orange),
                          const SizedBox(width: 10),
                          _buildStatCard("Hotel", "${_stats!['summary']['totalHotels']}", Colors.purple),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // 2. TOMBOL MANAJEMEN
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.hotel),
                          label: const Text("KELOLA DATA HOTEL & KAMAR"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white),
                          onPressed: () {
                             // Pindah ke halaman List Hotel (Code lama AdminHomeScreen dipindah ke sini)
                             Navigator.push(context, MaterialPageRoute(builder: (c) => const HotelManagementScreen()));
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 3. GRAFIK PENDAPATAN
                      const Text("Grafik Pendapatan (Tahun Ini)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxY(), // Fungsi hitung tinggi grafik
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    const style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold);
                                    List<String> labels = List<String>.from(_stats!['chartData']['labels']);
                                    if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                      return Text(labels[value.toInt()], style: style);
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y axis numbers for clean look
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: _generateChartGroups(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // --- HELPER FUNCTIONS ---
  
  String _formatCurrency(dynamic value) {
    if (value == null) return "0";
    final format = NumberFormat.compact(locale: 'id_ID'); // Format 1.2M, 500K
    return format.format(value);
  }

  double _getMaxY() {
    List<dynamic> revenues = _stats!['chartData']['revenue'];
    // Cari nilai tertinggi untuk skala grafik
    double max = 0;
    for(var r in revenues) {
      if ((r as num).toDouble() > max) max = r.toDouble();
    }
    return max == 0 ? 100 : max * 1.2; // Tambah buffer 20%
  }

  List<BarChartGroupData> _generateChartGroups() {
    List<dynamic> revenues = _stats!['chartData']['revenue'];
    List<BarChartGroupData> groups = [];
    
    for (int i = 0; i < revenues.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (revenues[i] as num).toDouble(),
              color: Colors.redAccent,
              width: 15,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        )
      );
    }
    return groups;
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}