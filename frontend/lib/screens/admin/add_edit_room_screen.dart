import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import '../../models/room_model.dart';
import '../../services/room_service.dart';
import '../../services/hotel_service.dart'; 
class AddEditRoomScreen extends StatefulWidget {
  final int hotelId;
  final Room? room; 

  const AddEditRoomScreen({super.key, required this.hotelId, this.room});

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  
  File? _imageFile;
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _typeCtrl.text = widget.room!.type;
      _priceCtrl.text = widget.room!.price.toStringAsFixed(0);
      _capacityCtrl.text = widget.room!.capacity.toString();
    }
  }

  // Fungsi Ambil Gambar
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    bool success;
    if (widget.room == null) {
      // MODE TAMBAH
      success = await RoomService().createRoom(
        widget.hotelId,
        _typeCtrl.text,
        double.parse(_priceCtrl.text),
        int.parse(_capacityCtrl.text),
        _imageFile
      );
    } else {
      // MODE EDIT
      success = await RoomService().updateRoom(
        widget.room!.id,
        _typeCtrl.text,
        double.parse(_priceCtrl.text),
        int.parse(_capacityCtrl.text),
        _imageFile
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.room == null ? "Kamar Berhasil Ditambah" : "Kamar Berhasil Diupdate"),
          backgroundColor: Colors.green,
        )
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan data"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logika Tampilan Gambar
    Widget imageWidget;
    if (_imageFile != null) {
      imageWidget = Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity);
    } else if (widget.room?.imageUrl != null) {
      imageWidget = Image.network(
        HotelService.fixImageUrl(widget.room!.imageUrl!), 
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    } else {
      imageWidget = const Icon(Icons.camera_alt, size: 50, color: Colors.grey);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.room == null ? "Tambah Kamar" : "Edit Kamar")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- GAMBAR PICKER ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageWidget,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(child: Text("Ketuk gambar untuk mengubah foto", style: TextStyle(color: Colors.grey, fontSize: 12))),
              const SizedBox(height: 20),

              // --- FORM INPUT ---
              TextFormField(
                controller: _typeCtrl,
                decoration: const InputDecoration(labelText: "Tipe Kamar (e.g. Deluxe)", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: "Harga per Malam", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _capacityCtrl,
                decoration: const InputDecoration(labelText: "Kapasitas (Orang)", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              
              const SizedBox(height: 30),
              
              // --- TOMBOL SIMPAN ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.room == null ? Colors.blue : Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(widget.room == null ? "SIMPAN" : "UPDATE"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}