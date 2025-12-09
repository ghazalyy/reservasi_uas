import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({super.key});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  File? _imageFile; // Variabel untuk menyimpan file gambar yang dipilih
  final _picker = ImagePicker();
  bool _isLoading = false;

  // Fungsi Pilih Gambar dari Galeri
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
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih gambar hotel!")),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Setup Multipart Request (Wajib untuk upload file)
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/hotels'));
    
    // Header
    request.headers['Authorization'] = 'Bearer $token';
    
    // Fields (Teks)
    request.fields['name'] = _nameCtrl.text;
    request.fields['address'] = _addressCtrl.text;
    request.fields['description'] = _descCtrl.text;
    
    // File (Gambar) - 'image' harus sesuai dengan key di backend (upload.single('image'))
    request.files.add(await http.MultipartFile.fromPath(
      'image', 
      _imageFile!.path
    ));
    
    try {
      var response = await request.send();
      
      // Kita perlu baca response stream untuk tahu status pastinya
      final respStr = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        if(!mounted) return;
        Navigator.pop(context); // Tutup halaman
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hotel Berhasil Ditambahkan"), backgroundColor: Colors.green)
        );
      } else {
        print("Gagal: ${response.statusCode} - $respStr");
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${response.statusCode}"), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      print("Error Upload: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Hotel Baru")),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            Text("Ketuk untuk upload gambar"),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // --- FORM INPUT ---
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Nama Hotel", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("SIMPAN HOTEL"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}