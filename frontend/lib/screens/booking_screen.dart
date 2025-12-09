import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../models/room_model.dart';
import '../services/booking_service.dart';
import 'home_screen.dart';

class BookingScreen extends StatefulWidget {
  final Room room; // Kita butuh data kamar yang dipilih

  const BookingScreen({super.key, required this.room});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  double _totalPrice = 0;
  bool _isLoading = false;

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Fungsi Pilih Tanggal
  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Reset checkout jika checkin berubah agar logika valid
          _checkOutDate = null; 
        } else {
          _checkOutDate = picked;
        }
        _calculateTotal();
      });
    }
  }

  // Hitung Total Hari & Harga
  void _calculateTotal() {
    if (_checkInDate != null && _checkOutDate != null) {
      // Pastikan checkout setelah checkin
      if (_checkOutDate!.isAfter(_checkInDate!)) {
        final duration = _checkOutDate!.difference(_checkInDate!).inDays;
        // Minimal 1 hari meskipun selisih jam sedikit
        final days = duration > 0 ? duration : 1; 
        
        setState(() {
          _totalPrice = days * widget.room.price;
        });
      } else {
        setState(() {
          _totalPrice = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tanggal Check-out harus setelah Check-in")),
        );
      }
    }
  }

  // Fungsi Submit ke Backend
  void _submitBooking() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih tanggal Check-in dan Check-out dulu!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await BookingService().createBooking(
      widget.room.id,
      _checkInDate!,
      _checkOutDate!,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      // Tampilkan dialog sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Berhasil!"),
          content: const Text("Booking Anda telah disimpan."),
          actions: [
            TextButton(
              onPressed: () {
                // Kembali ke Home dan hapus semua history route sebelumnya
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Gagal, silakan coba lagi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konfirmasi Booking")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Kamar Singkat
            Text("Kamar: ${widget.room.type}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Harga per malam: ${currencyFormatter.format(widget.room.price)}", style: const TextStyle(color: Colors.grey)),
            const Divider(height: 30),

            // Input Tanggal
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Check-In"),
                      const SizedBox(height: 5),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_checkInDate == null 
                            ? "Pilih Tanggal" 
                            : DateFormat('dd/MM/yyyy').format(_checkInDate!)),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Check-Out"),
                      const SizedBox(height: 5),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(_checkOutDate == null 
                            ? "Pilih Tanggal" 
                            : DateFormat('dd/MM/yyyy').format(_checkOutDate!)),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Rincian Pembayaran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Bayar:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    currencyFormatter.format(_totalPrice),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Confirm
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("KONFIRMASI BOOKING", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}