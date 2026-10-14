import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart'; 
import '../../app_assets.dart';

class AddSholatPage extends StatefulWidget {
  final DocumentSnapshot? document;
  const AddSholatPage({Key? key, this.document}) : super(key: key);

  @override
  State<AddSholatPage> createState() => _AddSholatPageState();
}

class _AddSholatPageState extends State<AddSholatPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  String _selectedImage = ''; 
  String _selectedCategory = 'sholat_subuh';
  bool _isLoading = false;
  List<String> _filteredImages = [];

  // --- PALET WARNA TEMA ANAK SHOLEH ---
  final Color primaryColor = const Color(0xFF4FB3FF); // Biru Langit
  final Color accentColor = const Color(0xFFFFD54F);  // Kuning Cerah
  final Color backgroundColor = const Color(0xFFF4F8FB); // Putih Kebiruan
  final Color textDark = const Color(0xFF1A237E);     // Biru Tua

  final List<Map<String, String>> _sholatCategories = [
    {'value': 'sholat_subuh', 'label': 'Sholat Subuh'},
    {'value': 'sholat_dzuhur', 'label': 'Sholat Dzuhur'},
    {'value': 'sholat_ashar', 'label': 'Sholat Ashar'},
    {'value': 'sholat_maghrib', 'label': 'Sholat Maghrib'},
    {'value': 'sholat_isya', 'label': 'Sholat Isya'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Filter gambar: Ambil semua, KECUALI 'wudhu' agar variatif
    _filteredImages = AppAssets.allImages.where((img) => !img.toLowerCase().contains('wudhu')).toList();
    if (_filteredImages.isEmpty) {
        _filteredImages = AppAssets.allImages;
    }
    
    if (_filteredImages.isNotEmpty) _selectedImage = _filteredImages.first;

    if (widget.document != null) {
      _titleController.text = widget.document!['title'];
      _descController.text = widget.document!['description'];
      
      String oldCategory = widget.document!['category'];
      if (_sholatCategories.any((e) => e['value'] == oldCategory)) {
        _selectedCategory = oldCategory;
      }

      String oldImage = widget.document!['imageUrl'] ?? '';
      if (oldImage.isNotEmpty) {
        if (!_filteredImages.contains(oldImage)) {
          _filteredImages.add(oldImage);
        }
        _selectedImage = oldImage;
      }
    }
  }

  Future<void> _saveData() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan Deskripsi wajib diisi!"), backgroundColor: Colors.redAccent)
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> data = {
        "title": _titleController.text,
        "description": _descController.text,
        "category": _selectedCategory,
        "imageUrl": _selectedImage,
      };

      if (widget.document == null) {
        data["createdAt"] = DateTime.now();
        await FirebaseFirestore.instance.collection('contents').add(data);
      } else {
        await FirebaseFirestore.instance.collection('contents').doc(widget.document!.id).update(data);
      }
      if(mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil menyimpan data sholat!"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.document != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          isEdit ? "Ubah Data Sholat" : "Tambah Data Sholat", 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PILIH WAKTU SHOLAT ---
            Text("Pilih Waktu Sholat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
                  items: _sholatCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat['value'], 
                      child: Text(cat['label']!, style: TextStyle(color: textDark))
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- INPUT JUDUL ---
            Text("Judul Bacaan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _titleController, 
              hint: "Contoh: Niat, Takbir, Al-Fatihah",
              icon: Icons.title_rounded
            ),
            const SizedBox(height: 20),

            // --- INPUT BACAAN ---
            Text("Isi Bacaan (Arab & Arti)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _descController, 
              hint: "Tulis teks arab, latin, dan terjemahan...",
              maxLines: 5,
              icon: Icons.menu_book_rounded
            ),
            const SizedBox(height: 25),

            // --- PILIH GAMBAR ---
            Text("Pilih Ilustrasi (Opsional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedImage,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
                  items: _filteredImages.map((e) => DropdownMenuItem(
                    value: e, 
                    child: Row(
                      children: [
                        Icon(Icons.image_rounded, size: 20, color: primaryColor.withOpacity(0.6)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(e.split('/').last, overflow: TextOverflow.ellipsis, style: TextStyle(color: textDark))),
                      ],
                    )
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedImage = val!),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // --- PREVIEW GAMBAR ---
            if (_selectedImage.isNotEmpty) 
              Center(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SmartImage(_selectedImage, fit: BoxFit.contain),
                  ),
                ),
              ),
            
            const SizedBox(height: 40),
            
            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor, // Tombol Kuning
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  shadowColor: accentColor.withOpacity(0.4),
                ),
                onPressed: _isLoading ? null : _saveData, 
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_rounded, color: Color(0xFF1A237E)),
                        const SizedBox(width: 10),
                        Text(
                          isEdit ? "SIMPAN PERUBAHAN" : "TAMBAH BACAAN", 
                          style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Text Field
  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: textDark),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Icon(icon, color: primaryColor),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}