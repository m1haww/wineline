import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  void addBottle(WineBottle bottle) {
    _bottles.add(bottle);
    _saveBottles();
    notifyListeners();
  }
}
