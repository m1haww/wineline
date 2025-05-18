import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:wineline/pages/add_bottle.dart';
import 'package:wineline/pages/add_bottle2.dart';
import 'package:wineline/pages/add_bottles_details.dart';
import '../models/wine_bottle.dart';
import 'package:provider/provider.dart';
import '../providers/bottle_provider.dart';
import 'add_bottle.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  List<WineBottle> bottles = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBottles();
  }

  Future<void> _loadBottles() async {
    try {
      final String response = await rootBundle.loadString('assets/bottle.json');
      final data = await json.decode(response);
      setState(() {
        bottles =
            (data['bottles'] as List)
                .map((item) => WineBottle.fromJson(item))
                .toList();
      });
    } catch (e) {
      print('Error loading bottles: $e');
    }
  }

  // Function to remove diacritics from a string
  String _normalize(String input) {
    return input
        .replaceAll(RegExp(r'[âǎáàäãåāăą]'), 'a')
        .replaceAll(RegExp(r'[ÂǍÁÀÄÃÅĀĂĄ]'), 'A')
        .replaceAll(RegExp(r'[éèêëěēĕėę]'), 'e')
        .replaceAll(RegExp(r'[ÉÈÊËĚĒĔĖĘ]'), 'E')
        .replaceAll(RegExp(r'[íìîïǐīĭįı]'), 'i')
        .replaceAll(RegExp(r'[ÍÌÎÏǏĪĬĮİ]'), 'I')
        .replaceAll(RegExp(r'[óòôöõőōŏǒ]'), 'o')
        .replaceAll(RegExp(r'[ÓÒÔÖÕŐŌŎǑ]'), 'O')
        .replaceAll(RegExp(r'[úùûüůūŭűų]'), 'u')
        .replaceAll(RegExp(r'[ÚÙÛÜŮŪŬŰŲ]'), 'U')
        .replaceAll(RegExp(r'[çćčĉċ]'), 'c')
        .replaceAll(RegExp(r'[ÇĆČĈĊ]'), 'C')
        .replaceAll(RegExp(r'[ñńňņŋ]'), 'n')
        .replaceAll(RegExp(r'[ÑŃŇŅŊ]'), 'N')
        .replaceAll(RegExp(r'[ýÿŷ]'), 'y')
        .replaceAll(RegExp(r'[ÝŸŶ]'), 'Y')
        .replaceAll(RegExp(r'[žźż]'), 'z')
        .replaceAll(RegExp(r'[ŽŹŻ]'), 'Z')
        .replaceAll(RegExp(r'[śšşŝ]'), 's')
        .replaceAll(RegExp(r'[ŚŠŞŜ]'), 'S')
        .replaceAll(RegExp(r'[łľĺļŀ]'), 'l')
        .replaceAll(RegExp(r'[ŁĽĹĻĿ]'), 'L')
        .replaceAll(RegExp(r'[řŗŕ]'), 'r')
        .replaceAll(RegExp(r'[ŘŖŔ]'), 'R')
        .replaceAll(RegExp(r'[ťţŧ]'), 't')
        .replaceAll(RegExp(r'[ŤŢŦ]'), 'T')
        .replaceAll(RegExp(r'[ďđ]'), 'd')
        .replaceAll(RegExp(r'[ĎĐ]'), 'D')
        .replaceAll(RegExp(r'[ğĝġģ]'), 'g')
        .replaceAll(RegExp(r'[ĞĜĠĢ]'), 'G');
  }

  @override
  Widget build(BuildContext context) {
    final providerBottles = Provider.of<BottleProvider>(context).bottles;
    final allBottles = [...bottles, ...providerBottles];
    final filteredBottles =
        allBottles
            .where(
              (bottle) => _normalize(
                bottle.name.toLowerCase(),
              ).contains(_normalize(searchQuery.toLowerCase())),
            )
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Orange header with search and add button
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE86F1C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search bottles',
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFFE86F1C)),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddBottle2()),
                            );
                            setState(() {}); // Refresh after returning
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // List of bottles
            Expanded(
              child:
                  filteredBottles.isEmpty
                      ? const Center(
                        child: Text(
                          'No match',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        itemCount: filteredBottles.length,
                        itemBuilder: (context, index) {
                          final bottle = filteredBottles[index];
                          return Card(
                            color: const Color(0xFFE86F1C),
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder:
                                        (context) =>
                                            AddBottlesDetails(bottle: bottle),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        bottle.image,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            width: 90,
                                            height: 90,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.wine_bar,
                                              color: Colors.white54,
                                              size: 40,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bottle.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${bottle.region.split(',').last.trim()} ${bottle.year}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getStatusText(index),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _getDateText(index),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Bottom action section
          ],
        ),
      ),
    );
  }

  String _getStatusText(int index) {
    // Example status cycling for demo
    if (index % 3 == 0) return 'In cellar';
    if (index % 3 == 1) return 'Drunk';
    return 'In transit';
  }

  String _getDateText(int index) {
    // Example date cycling for demo
    if (index % 3 == 0) return 'Jun 2027';
    if (index % 3 == 1) return 'Jun 2027';
    return 'Dec 2028';
  }
}
