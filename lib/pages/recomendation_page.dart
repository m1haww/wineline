import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wineline/models/base.dart';

class RecomendationPage extends StatefulWidget {
  const RecomendationPage({super.key});

  @override
  State<RecomendationPage> createState() => _RecomendationPageState();
}

class _RecomendationPageState extends State<RecomendationPage> {
  late Future<List<dynamic>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = _loadCollections();
  }

  Future<List<dynamic>> _loadCollections() async {
    final String jsonString = await rootBundle.loadString('assets/data.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData['wineCollections'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _collectionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No recommendations found.'));
            }
            final collections = snapshot.data!;
            // For demo, split into two sections
            final recommendations = collections.take(3).toList();
            final userRatings = collections.skip(3).take(3).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                const Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ...recommendations.map((c) => RecommendationCard(item: c)),
                const SizedBox(height: 32),
                const Text(
                  'User ratinds & sommelier tips',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ...userRatings.map((c) => RecommendationCard(item: c)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const RecommendationCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final int places =
        item['wineList'] != null
            ? (item['wineList'] as List).length
            : (item['locations'] != null
                ? (item['locations'] as List).length
                : 0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationDetailPage(item: item),
          ),
        );
      },
      child: Container(
        height: height * 0.17,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4570C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  item['image'],
                  width: width * 0.34,
                  height: height * 0.17,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Texts
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildtext(context, item['title']),
                    const SizedBox(height: 4),
                    buildsubttext(context, item['description']),
                  ],
                ),
              ),
            ),
            // Places count
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '$places Places',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendationDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  const RecommendationDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item['title'] ?? 'Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  item['image'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              item['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              item['description'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (item['rating'] != null && item['reviews'] != null)
              Row(
                children: [
                  Text(
                    '${item['rating']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ...List.generate(
                    5,
                    (i) =>
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item['reviews']} reviews',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            const Divider(height: 32),
            const Text(
              'Wine List',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (item['wineList'] != null)
              ...List.generate(item['wineList'].length, (i) {
                final wine = item['wineList'][i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wine['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            wine['desc'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        ' 24${wine['price']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 16),
            const Text(
              'Best picks',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            if (item['address'] != null)
              Text(
                item['address'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (item['city'] != null) Text(item['city']),
            if (item['phone'] != null)
              Text(
                item['phone'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (item['website'] != null) Text(item['website']),
          ],
        ),
      ),
    );
  }
}
