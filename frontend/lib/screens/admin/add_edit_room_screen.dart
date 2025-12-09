import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/room_model.dart';
import '../../services/room_service.dart';

class AddEditRoomScreen extends StatefulWidget {
  final int hotelId;
  final Room? room; // Jika null = Tambah Baru, Jika ada = Edit

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jika mode edit, isi form
    if (widget.room != null) {
      _typeCtrl.text = widget.room!.type;
      _priceCtrl.text = widget.room!.price.toStringAsFixed(0);
      _capacityCtrl.text = widget.room!.capacity.toString();
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
      Navigator.pop(context); // Kembali ke list
    }
  }

  // ... Widget Build Form mirip dengan Hotel Form (Type, Price, Capacity, Image) ...
  // Silakan implementasikan build mirip AddHotelScreen tapi fieldnya beda
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.room == null ? "Tambah Kamar" : "Edit Kamar")),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: ListView(children: [
                    // Gambar Picker (Opsional, copy dari AddHotel)
                    // ...
                    TextFormField(
                        controller: _typeCtrl,
                        decoration: const InputDecoration(labelText: "Tipe Kamar (e.g. Deluxe)"),
                    ),
                    TextFormField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(labelText: "Harga"),
                        keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                        controller: _capacityCtrl,
                        decoration: const InputDecoration(labelText: "Kapasitas (Orang)"),
                        keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: Text(widget.room == null ? "SIMPAN" : "UPDATE"),
                    )
                ])
            )
        )
    );
  }
}