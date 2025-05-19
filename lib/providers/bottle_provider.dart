import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/wine_bottle.dart';

class BottleProvider extends ChangeNotifier {
  final List<WineBottle> _bottles = [];

  List<WineBottle> get bottles => List.unmodifiable(_bottles);

  BottleProvider() {
    _loadBottles();
  }

  Future<void> _loadBottles() async {
    final prefs = await SharedPreferences.getInstance();
    final bottlesString = prefs.getString('bottles');
    if (bottlesString != null) {
      final List<dynamic> decoded = json.decode(bottlesString);
      _bottles.clear();
      _bottles.addAll(decoded.map((e) => WineBottle.fromJson(e)));
      notifyListeners();
    }
  }

  Future<void> _saveBottles() async {
    final prefs = await SharedPreferences.getInstance();
    final bottlesString = json.encode(_bottles.map((b) => b.toJson()).toList());
    await prefs.setString('bottles', bottlesString);
  }

  Future<String> _saveImageToTemp(File imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'bottle_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final savedImage = await imageFile.copy('${tempDir.path}/$fileName');
    return savedImage.path;
  }

  Future<void> addBottle(WineBottle bottle, {File? imageFile}) async {
    String imagePath = bottle.image;
    if (imageFile != null) {
      imagePath = await _saveImageToTemp(imageFile);
    }
    
    final newBottle = WineBottle(
      id: bottle.id,
      name: bottle.name,
      type: bottle.type,
      year: bottle.year,
      region: bottle.region,
      price: bottle.price,
      description: bottle.description,
      image: imagePath,
      isOwnBottle: true,
    );
    
    _bottles.add(newBottle);
    await _saveBottles();
    notifyListeners();
  }
}
