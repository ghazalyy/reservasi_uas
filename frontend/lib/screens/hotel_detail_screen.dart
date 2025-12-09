import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../models/hotel_model.dart';
import '../models/room_model.dart';
import '../services/hotel_service.dart';
import 'booking_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  final int hotelId; 

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  late Future<Hotel> _futureHotelDetail;

  @override
  void initState() {
    super.initState();
    _futureHotelDetail = HotelService().getHotelById(widget.hotelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Hotel>(
        future: _futureHotelDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Hotel tidak ditemukan"));
          }

          final hotel = snapshot.data!;
          String? mainImage = hotel.imageUrl;
          if (mainImage != null) mainImage = HotelService.fixImageUrl(mainImage);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(hotel.name, style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                  background: mainImage != null
                      ? Image.network(mainImage, fit: BoxFit.cover)
                      : Container(color: Colors.grey, child: const Icon(Icons.hotel, size: 50)),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.blue),
                                const SizedBox(width: 4),
                                Expanded(child: Text(hotel.address, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text(hotel.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(hotel.description, style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(height: 24),
                      
                      const Text("Pilih Kamar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      if (hotel.rooms == null || hotel.rooms!.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: Text("Belum ada kamar tersedia di hotel ini.")),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true, 
                          physics: const NeverScrollableScrollPhysics(), 
                          itemCount: hotel.rooms!.length,
                          itemBuilder: (context, index) {
                            return _buildRoomCard(hotel.rooms![index]);
                          },
                        ),
                      
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    String? roomImage = room.imageUrl;
    if (roomImage != null) roomImage = HotelService.fixImageUrl(roomImage);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: roomImage != null
                ? Image.network(roomImage, width: 80, height: 80, fit: BoxFit.cover)
                : Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.bed)),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Kapasitas: ${room.capacity} Orang", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(room.price), 
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: room.isAvailable ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(room: room),
                  ),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Pilih"),
            )
          ],
        ),
      ),
    );
  }
}