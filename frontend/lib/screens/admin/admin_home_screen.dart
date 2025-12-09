import 'package:flutter/material.dart';
import '../../models/hotel_model.dart';
import '../../services/hotel_service.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'add_hotel_screen.dart';
import 'edit_hotel_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Variable untuk menampung data hotel dari API
  late Future<List<Hotel>> _futureHotels;

  @override
  void initState() {
    super.initState();
    _refreshData(); // Load data saat layar pertama dibuka
  }

  // Fungsi untuk mengambil ulang data dari server (Refresh)
  void _refreshData() {
    setState(() {
      _futureHotels = HotelService().getHotels();
    });
  }

  // Fungsi Logout
  void _logout() {
    AuthService().logout();
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (c) => const LoginScreen())
    );
  }

  // Fungsi Konfirmasi & Hapus Hotel
  void _confirmDelete(Hotel hotel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Hotel?"),
        content: Text("Yakin ingin menghapus '${hotel.name}'?\n\nPERINGATAN: Semua kamar dan review terkait hotel ini juga akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Tutup dialog
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog dulu
              
              // Panggil Service Delete
              bool success = await HotelService().deleteHotel(hotel.id);
              
              if (success) {
                _refreshData(); // Refresh list jika berhasil
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data hotel berhasil dihapus"), backgroundColor: Colors.green)
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal menghapus data"), backgroundColor: Colors.red)
                );
              }
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.redAccent, 
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _logout, 
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          )
        ],
      ),
      
      // Tombol Tambah Hotel (+)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
           // Tunggu sampai user kembali dari halaman AddHotel
           await Navigator.push(
             context, 
             MaterialPageRoute(builder: (context) => const AddHotelScreen())
           );
           // Setelah kembali, refresh data agar hotel baru muncul
           _refreshData(); 
        },
      ),

      body: FutureBuilder<List<Hotel>>(
        future: _futureHotels,
        builder: (context, snapshot) {
          // 1. State Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          // 2. State Error
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } 
          // 3. State Kosong
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data hotel."));
          }

          final hotels = snapshot.data!;

          // 4. State Ada Data (List)
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              
              // Fix URL Gambar (Localhost -> 10.0.2.2)
              String? imageUrl = hotel.imageUrl;
              if (imageUrl != null) {
                imageUrl = HotelService.fixImageUrl(imageUrl);
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- GAMBAR THUMBNAIL ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null
                          ? Image.network(
                              imageUrl, 
                              width: 80, 
                              height: 80, 
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(width: 80, height: 80, color: Colors.grey, child: const Icon(Icons.broken_image)),
                            )
                          : Container(
                              width: 80, 
                              height: 80, 
                              color: Colors.grey[300], 
                              child: const Icon(Icons.hotel, color: Colors.grey)
                            ),
                      ),
                      
                      const SizedBox(width: 12),

                      // --- INFO HOTEL ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.name, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hotel.address, 
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // --- TOMBOL AKSI (EDIT & DELETE) ---
                      Column(
                        children: [
                          // Tombol Edit
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              // Pindah ke halaman Edit & bawa data hotel
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditHotelScreen(hotel: hotel)),
                              );
                              // Jika update sukses (result == true), refresh list
                              if (result == true) {
                                _refreshData();
                              }
                            },
                          ),
                          // Tombol Delete
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _confirmDelete(hotel),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}