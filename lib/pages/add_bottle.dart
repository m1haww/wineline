import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/wine_bottle.dart';
import '../providers/bottle_provider.dart';

class AddBottle extends StatefulWidget {
  const AddBottle({super.key});

  @override
  State<AddBottle> createState() => _AddBottleState();
}

class _AddBottleState extends State<AddBottle> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _countryController = TextEditingController();
  final _vintageController = TextEditingController();
  final _drinkByController = TextEditingController();
  File? _imagePath;

  @override
  void initState() {
    super.initState();
    _clearForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _countryController.dispose();
    _vintageController.dispose();
    _drinkByController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _countryController.clear();
    _vintageController.clear();
    _drinkByController.clear();
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = File(pickedFile.path);
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFE86F1C),
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bottle Saved!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE86F1C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearForm();
                  },
                  child: const Text('Add Another Bottle'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Bottle',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Add Photo Button
              GestureDetector(
                onTap: _pickImage,
                child:
                    _imagePath == null
                        ? Container(
                          width: 140,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add, size: 36, color: Colors.black),
                              SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imagePath!,
                            width: 140,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wine Name
                    const Text(
                      'Wine Name',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Enter wine name'),
                      cursorColor: const Color(0xFFE86F1C),
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    // Wine Type
                    const Text(
                      'Wine Type',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _typeController,
                      decoration: _inputDecoration('Enter wine type'),
                      cursorColor: const Color(0xFFE86F1C),
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    // Country
                    const Text(
                      'Country',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _countryController,
                      decoration: _inputDecoration('Enter country'),
                      cursorColor: const Color(0xFFE86F1C),
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    // Vintage
                    const Text(
                      'Vintage',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _vintageController,
                      decoration: _inputDecoration('Enter vintage'),
                      cursorColor: const Color(0xFFE86F1C),
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    // Drink by
                    const Text(
                      'Drink by',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _drinkByController,
                      decoration: _inputDecoration('Optional'),
                      cursorColor: const Color(0xFFE86F1C),
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE86F1C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final newBottle = WineBottle(
                                id: DateTime.now().millisecondsSinceEpoch,
                                name: _nameController.text,
                                type: _typeController.text,
                                year:
                                    int.tryParse(_vintageController.text) ?? 0,
                                region: _countryController.text,
                                price: 0,
                                description: '',
                                image: _imagePath?.path ?? '',
                              );
                              Provider.of<BottleProvider>(
                                context,
                                listen: false,
                              ).addBottle(newBottle);
                              _showSuccessDialog();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please complete all fields'),
                                  backgroundColor: Color(0xFFE86F1C),
                                ),
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE86F1C), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
