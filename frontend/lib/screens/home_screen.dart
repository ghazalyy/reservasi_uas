import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../services/hotel_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'hotel_detail_screen.dart';
import 'my_bookings_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Hotel> _allHotels = [];   
  List<Hotel> _foundHotels = []; 
  bool _isLoading = true;        
  String _errorMessage = '';     

  @override
  void initState() {
    super.initState();
    _fetchHotels(); 
  }

  // Fungsi Ambil Data dari API
  Future<void> _fetchHotels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final hotels = await HotelService().getHotels();
      if (mounted) {
        setState(() {
          _allHotels = hotels;
          _foundHotels = hotels; 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _runFilter(String keyword) {
    List<Hotel> results = [];
    if (keyword.isEmpty) {
      results = _allHotels;
    } else {
      results = _allHotels
          .where((hotel) =>
              hotel.name.toLowerCase().contains(keyword.toLowerCase()) ||
              hotel.address.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundHotels = results;
    });
  }

  // Fungsi Logout
  void _logout() {
    AuthService().logout();
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Hotel"),
        actions: [
          // 1. TOMBOL RIWAYAT BOOKING
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Riwayat Booking",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
              );
            },
          ),
          // 2. TOMBOL LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Keluar",
            onPressed: _logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- 1. SEARCH BAR ---
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                labelText: 'Cari nama atau lokasi...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. LIST HOTEL ---
            Expanded(
              child: _buildListContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 10),
            Text("Error: $_errorMessage", textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _fetchHotels, child: const Text("Coba Lagi"))
          ],
        ),
      );
    }

    if (_foundHotels.isEmpty) {
      return const Center(child: Text("Hotel tidak ditemukan."));
    }

    return RefreshIndicator(
      onRefresh: _fetchHotels,
      child: ListView.builder(
        itemCount: _foundHotels.length,
        itemBuilder: (context, index) {
          final hotel = _foundHotels[index];
          return _buildHotelCard(hotel);
        },
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    String? imageUrl = hotel.imageUrl;
    if (imageUrl != null) {
      imageUrl = HotelService.fixImageUrl(imageUrl);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigasi ke Detail Hotel
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailScreen(hotelId: hotel.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Hotel
            if (imageUrl != null)
              Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stack) => 
                  Container(height: 180, width: double.infinity, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
              )
            else
              Container(
                height: 180, 
                width: double.infinity, 
                color: Colors.grey[300], 
                child: const Icon(Icons.hotel, size: 50, color: Colors.grey)
              ),
            
            // Info Hotel
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(hotel.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.address,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}