import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/hotel_model.dart';
import '../../services/hotel_service.dart';
import '../../services/room_service.dart';
import 'add_edit_room_screen.dart'; 

class AdminRoomListScreen extends StatefulWidget {
  final Hotel hotel; 

  const AdminRoomListScreen({super.key, required this.hotel});

  @override
  State<AdminRoomListScreen> createState() => _AdminRoomListScreenState();
}

class _AdminRoomListScreenState extends State<AdminRoomListScreen> {
  late Future<Hotel> _futureHotelDetail; 

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _futureHotelDetail = HotelService().getHotelById(widget.hotel.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kamar - ${widget.hotel.name}")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Ke halaman Tambah Kamar
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditRoomScreen(hotelId: widget.hotel.id),
            ),
          );
          _refreshData();
        },
      ),
      body: FutureBuilder<Hotel>(
        future: _futureHotelDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData) return const Center(child: Text("Error loading data"));

          final rooms = snapshot.data!.rooms; 

          if (rooms == null || rooms.isEmpty) {
            return const Center(child: Text("Belum ada kamar di hotel ini."));
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.bed),
                  title: Text(room.type),
                  subtitle: Text("${currencyFormatter.format(room.price)} - Kap: ${room.capacity} org"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditRoomScreen(hotelId: widget.hotel.id, room: room),
                            ),
                          );
                          _refreshData();
                        },
                      ),
                      // Delete
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                           bool confirm = await showDialog(
                             context: context,
                             builder: (ctx) => AlertDialog(
                               title: const Text("Hapus Kamar?"),
                               actions: [
                                 TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: const Text("Batal")),
                                 TextButton(onPressed: ()=>Navigator.pop(ctx, true), child: const Text("Hapus")),
                               ],
                             )
                           );
                           
                           if(confirm) {
                             await RoomService().deleteRoom(room.id);
                             _refreshData();
                           }
                        },
                      ),
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