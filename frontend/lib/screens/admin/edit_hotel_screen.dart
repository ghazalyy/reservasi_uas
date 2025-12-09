import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/hotel_model.dart';
import '../../services/hotel_service.dart';

class EditHotelScreen extends StatefulWidget {
  final Hotel hotel; 

  const EditHotelScreen({super.key, required this.hotel});

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _descCtrl;
  
  File? _newImageFile; 
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi form dengan data lama (Pre-fill)
    _nameCtrl = TextEditingController(text: widget.hotel.name);
    _addressCtrl = TextEditingController(text: widget.hotel.address);
    _descCtrl = TextEditingController(text: widget.hotel.description);
  }

  // Fungsi Ambil Gambar
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi Submit Update
  Future<void> _submit() async {
    // 1. Cek Validasi Form
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    // 2. Panggil Service Update
    final success = await HotelService().updateHotel(
      widget.hotel.id,
      _nameCtrl.text,
      _addressCtrl.text,
      _descCtrl.text,
      _newImageFile, 
    );

    setState(() => _isLoading = false);

    // 3. Feedback ke User
    if (success) {
      if(!mounted) return;
      Navigator.pop(context, true); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hotel Berhasil Diupdate"), backgroundColor: Colors.green)
      );
    } else {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal update hotel"), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) { 
    Widget imageWidget;
    if (_newImageFile != null) {
      imageWidget = Image.file(
        _newImageFile!, 
        fit: BoxFit.cover, 
        width: double.infinity
      );
    } else if (widget.hotel.imageUrl != null) {
      imageWidget = Image.network(
        HotelService.fixImageUrl(widget.hotel.imageUrl!), 
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    } else {
      imageWidget = const Icon(Icons.camera_alt, size: 50, color: Colors.grey);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Hotel")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- AREA GAMBAR ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], 
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageWidget,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Ketuk gambar di atas untuk mengubah foto", 
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),

              // --- INPUT FIELDS ---
              TextFormField(
                controller: _nameCtrl, 
                decoration: const InputDecoration(labelText: "Nama Hotel", border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _addressCtrl, 
                decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? "Alamat wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _descCtrl, 
                decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder()),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? "Deskripsi wajib diisi" : null,
              ),
              
              const SizedBox(height: 30),
              
              // --- TOMBOL UPDATE ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, 
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("UPDATE HOTEL", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}