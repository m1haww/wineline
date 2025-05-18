import 'package:flutter/material.dart';
import 'package:wineline/models/wine_bottle.dart';

class AddBottlesDetails extends StatefulWidget {
  final WineBottle bottle;

  const AddBottlesDetails({super.key, required this.bottle});

  @override
  State<AddBottlesDetails> createState() => _AddBottlesDetailsState();
}

class _AddBottlesDetailsState extends State<AddBottlesDetails> {
  @override
  Widget build(BuildContext context) {
    final bottle = widget.bottle;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE86F1C),
        title: Text(bottle.name, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Image.asset(
                bottle.image,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 240,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.wine_bar,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    bottle.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE86F1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Type and Year
                  Row(
                    children: [
                      Text(
                        bottle.type,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        bottle.year.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Region
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bottle.region,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    bottle.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
