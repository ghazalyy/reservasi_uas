import 'package:flutter/material.dart';
import '../../models/hotel_model.dart';
import '../../services/hotel_service.dart';
import 'add_hotel_screen.dart';
import 'edit_hotel_screen.dart';
import 'admin_room_list_screen.dart'; 

class HotelManagementScreen extends StatefulWidget {
  const HotelManagementScreen({super.key});

  @override
  State<HotelManagementScreen> createState() => _HotelManagementScreenState();
}

class _HotelManagementScreenState extends State<HotelManagementScreen> {
  late Future<List<Hotel>> _futureHotels;

  @override
  void initState() {
    super.initState();
    _refreshData(); 
  }

  // Fungsi untuk mengambil ulang data dari server (Refresh)
  void _refreshData() {
    setState(() {
      _futureHotels = HotelService().getHotels();
    });
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
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); 
              
              // Panggil Service Delete
              bool success = await HotelService().deleteHotel(hotel.id);
              
              if (success) {
                _refreshData(); 
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
        title: const Text("Kelola Data Hotel"),
        backgroundColor: Colors.redAccent, 
        foregroundColor: Colors.white,
      ),
      
      // Tombol Tambah Hotel (+)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
           await Navigator.push(
             context, 
             MaterialPageRoute(builder: (context) => const AddHotelScreen())
           );
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

                      // --- TOMBOL AKSI (ROOMS, EDIT, DELETE) ---
                      Column(
                        children: [
                          // 1. Tombol Kelola Kamar (Baru)
                          IconButton(
                            icon: const Icon(Icons.bed, color: Colors.blue),
                            tooltip: "Kelola Kamar",
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              // Navigasi ke List Kamar
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AdminRoomListScreen(hotel: hotel)),
                              );
                            },
                          ),

                          // 2. Tombol Edit
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditHotelScreen(hotel: hotel)),
                              );
                              if (result == true) {
                                _refreshData();
                              }
                            },
                          ),

                          // 3. Tombol Delete
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