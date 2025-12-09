import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../services/booking_service.dart';
import 'add_review_screen.dart'; 

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<dynamic>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _futureBookings = BookingService().getMyBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Booking Saya")),
      body: FutureBuilder<List<dynamic>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada riwayat booking."));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              
              // Akses data nested
              final hotelName = booking['room']['hotel']['name'] ?? 'Hotel';
              final status = booking['status'];
              final totalPrice = booking['totalPrice'];
              final hotelId = booking['room']['hotel']['id'];

              // --- PERBAIKAN DI SINI: FORMATTER RUPIAH ---
              final currencyFormatter = NumberFormat.currency(
                locale: 'id_ID', 
                symbol: 'Rp ', 
                decimalDigits: 0
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      
                      const SizedBox(height: 5),
                      
                      Text(
                        "Status: $status", 
                        style: TextStyle(
                          color: status == 'CONFIRMED' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      
                      // Gunakan formatter di sini
                      Text(
                        "Total: ${currencyFormatter.format(totalPrice)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Tombol Review hanya muncul jika CONFIRMED
                      if (status == 'CONFIRMED')
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.star, size: 16),
                            label: const Text("Beri Review"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber, 
                              foregroundColor: Colors.black
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddReviewScreen(hotelId: hotelId, hotelName: hotelName),
                                )
                              );
                            },
                          ),
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