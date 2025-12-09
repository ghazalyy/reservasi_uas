import 'package:flutter/material.dart';
import '../services/review_service.dart';

class AddReviewScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;

  const AddReviewScreen({super.key, required this.hotelId, required this.hotelName});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int _rating = 5; // Default bintang 5
  final _commentCtrl = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_commentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi komentar dulu")));
      return;
    }

    setState(() => _isLoading = true);

    bool success = await ReviewService().createReview(
      widget.hotelId,
      _rating,
      _commentCtrl.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terima kasih atas review Anda!")));
      Navigator.pop(context); // Tutup halaman
    } else {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal kirim review. Mungkin Anda sudah mereview hotel ini?")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tulis Review")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Review untuk ${widget.hotelName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            const Text("Rating:"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            
            const SizedBox(height: 20),
            TextField(
              controller: _commentCtrl,
              decoration: const InputDecoration(
                labelText: "Pengalaman Anda",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator() : const Text("KIRIM REVIEW"),
              ),
            )
          ],
        ),
      ),
    );
  }
}