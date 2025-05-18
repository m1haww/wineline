class WineBottle {
  final int id;
  final String name;
  final String type;
  final int year;
  final String region;
  final double price;
  final String description;
  final String image;

  WineBottle({
    required this.id,
    required this.name,
    required this.type,
    required this.year,
    required this.region,
    required this.price,
    required this.description,
    required this.image,
  });

  factory WineBottle.fromJson(Map<String, dynamic> json) {
    return WineBottle(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      year: json['year'],
      region: json['region'],
      price: json['price'].toDouble(),
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'year': year,
      'region': region,
      'price': price,
      'description': description,
      'image': image,
    };
  }
}
